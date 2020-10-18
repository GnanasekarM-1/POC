/**
    @ Name        :DCON_WO_Dependency_WS
    @ Author      :Jyothsna
    @ Created Date :31 July, 2017
    @ Description  :Class used to check whether workorder is scheduling according to workorder dependencies or not
    */
global class DCON_WO_Dependency_WS
{
    public DCON_WO_Dependency_WS ()
    {}
    public class SVMXException extends Exception {}
    public static DCON_Utils dcUtils = new DCON_Utils();
    global class Workorder_Dependency_Request 
        {
            webservice List<Event> lstSFEvent = new list<Event>();
            webservice List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>();
            webservice String timeZone{get;set;}
            webservice String userId{get;set;}
            webservice List<String> listWOIds = new List<String>();
            public Workorder_Dependency_Request(List<Event> lstSFEvent, List<SVMXC__SVMX_Event__c> lstSVMXEvent, String timeZone,String userId,List<String> listWOIds)
            {
                this.lstSFEvent = lstSFEvent; 
                this.timeZone = timeZone;
                this.lstSVMXEvent = lstSVMXEvent;
                this.userId = userId;
                this.listWOIds = listWOIds;
            }
            public Workorder_Dependency_Request() {}
        }   

    global class Workorder_Dependency_Response
        {
            webservice List<Preferrable_Workorder_Timings> woDetails= new List<Preferrable_Workorder_Timings>();
            webservice List<EventErrorMessage> eventDetails= new List<EventErrorMessage>();
            
            public Workorder_Dependency_Response(List<Preferrable_Workorder_Timings> woDetails, List<EventErrorMessage> eventDetails)
            {
                this.woDetails = woDetails;
                this.eventDetails = eventDetails;
            }
            public Workorder_Dependency_Response() {}    
        }
    global class EventErrorMessage
    {
        webservice String eventId{get;set;}
        webservice String woId{get;set;}
        webservice String errorMessage{get;set;}
        webservice String typeOfTimeDependency{get;set;}
        webservice String typeOfResourceDependency{get;set;}
        public EventErrorMessage(String eventId, String woId, String errorMessage, String typeOfTimeDependency,String typeOfResourceDependency)
            {
                this.eventId = eventId; 
                this.woId = woId;   
                this.errorMessage = errorMessage;
                this.typeOfTimeDependency = typeOfTimeDependency;
                this.typeOfResourceDependency = typeOfResourceDependency;   
            }
        
        public EventErrorMessage() {}
    }   
    global class Preferrable_Workorder_Timings 
    {
        webservice String woId{get;set;} 
        webservice String minStarttime{get;set;} 
        webservice String maxStarttime{get;set;} 
        webservice String minEndtime{get;set;} 
        webservice String maxEndtime{get;set;}
        webservice String dependencyGroupName{get;set;}
        public Preferrable_Workorder_Timings(String woId,String minStarttime,String maxStarttime,String minEndtime,String maxEndtime,String dependencyGroupName)
        {
            this.woId = woId;
            this.minStarttime = minStarttime;
            this.maxStarttime = maxStarttime;   
            this.minEndtime = minEndtime;
            this.maxEndtime = maxEndtime;
            this.dependencyGroupName = dependencyGroupName;
                        
        }
        public Preferrable_Workorder_Timings() {}    
    }
    global class Dependency_Details 
    {
        webservice String woId{get;set;}
        webservice Boolean isPrimaryWorkOrder{get;set;}
        webservice String dependencyGroup{get;set;}
        webservice String maximumDeviation{get;set;}
        webservice String maximumDeviationUnits{get;set;}
        webservice String minimumDeviation{get;set;}
        webservice String minimumDeviationUnits{get;set;}
        webservice String primaryWorkOrder{get;set;}
        webservice String secondaryWorkOrder{get;set;}
        webservice String primaryWorkOrderName{get;set;}
        webservice String secondaryWorkOrderName{get;set;}
        webservice String resourceDependency{get;set;}
        webservice String timeDependency{get;set;}
        webservice String technicianId{get;set;}
        webservice String technicianName{get;set;}
        webservice String scheduledStartTime{get;set;}
        webservice String serviceDuration{get;set;}
        webservice String breakTime{get;set;}
        webservice String driveTimeBefore{get;set;}
        webservice String driveTimeAfter{get;set;}
        webservice String overHeadTimeBefore{get;set;}
        webservice String overHeadTimeAfter{get;set;}
        webservice String primaryWOName{get;set;}
        webservice String dependencyGroupName{get;set;}
        public Dependency_Details(String woId,Boolean isPrimaryWorkOrder,String dependencyGroup,String maximumDeviation,String maximumDeviationUnits,
                                  String minimumDeviation,String minimumDeviationUnits,String primaryWorkOrder,String secondaryWorkOrder,String resourceDependency,String timeDependency) 
        {
            this.woId =woId;
            this.isPrimaryWorkOrder = isPrimaryWorkOrder;
            this.dependencyGroup = dependencyGroup;
            this.maximumDeviation = maximumDeviation;
            this.maximumDeviationUnits = maximumDeviationUnits;
            this.minimumDeviation = minimumDeviation;
            this.minimumDeviationUnits = minimumDeviationUnits;
            this.primaryWorkOrder = primaryWorkOrder;
            this.secondaryWorkOrder = secondaryWorkOrder;
            this.resourceDependency = resourceDependency;
            this.timeDependency = timeDependency;
        }
        public Dependency_Details() {}

    }  
    /**
    @ Webservice Name : DCON_WO_Dependency_Check_WS
    @ Description     : Method used to check whether workorder is scheduling according to workorder dependencies or not
    @ Input Parameter : Workorder_dependency_request req
                        lstSFEvent   - list of salesforce events going to be created
                        lstSVMXEvent - list of servicemax event going to be created
                        timezone     - timezone to maintain datetime fields in sync 
                        userId       - user Id 
    @ Output Parameter: Workorder_Dependency_Response response
                        Preferrable_Workorder_Timings (wrapper)
                            woId - workorder Id
                            minStarttime  - minimium scheduleable start time of workorder according to the dependencies exists.
                            maxStarttime  - maximium scheduleable start time of workorder according to the dependencies exists.
                            minEndtime    - minimium scheduleable end time of workorder according to the dependencies exists.
                            maxEndtime    - maximium scheduleable end time of workorder according to the dependencies exists.   
                            dependencyGroupName - dependency group where above workorder belongs
                        EventErrorMessage (Wrapper) 
                            eventId      - event Id incase of reassigning workorder
                            woId         - workorder Id for which event is going to be created
                            errorMessage - Error message if time and resource dependency are violated while scheduling workorder
                            typeOfTimeDependency     - type of time dependency that workorder belongs
                            typeOfResourceDependency - type of resource dependency that workorder belongs
                             
                        
    */  
    WebService static Workorder_Dependency_Response DCON_WO_Dependency_Check_WS(Workorder_Dependency_Request req)
        {
            Workorder_Dependency_Response response = new Workorder_Dependency_Response();
            try
            {
                 system.debug(logginglevel.warn,'Req:  '+ Req);
                 response = DCON_WO_Dependency_Check(req.lstSFEvent, req.lstSVMXEvent, req.timeZone);
                 System.Debug(logginglevel.warn,'response : '+response);
            }
            catch(DmlException ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getDmlMessage(0));
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
            return response;
        }
    /**
    @ Method Name     : DCON_WO_Dependency_Check
    @ Description     : Method used to check whether workorder is scheduling according to workorder dependencies or not
    @ Input Parameter : lstSFEvent   - list of salesforce events going to be created
                        lstSVMXEvent - list of servicemax event going to be created
                        timezone     - timezone to maintain datetime fields in sync
    @ Output Parameter: Workorder_Dependency_Response response
    */  
    
     public static Workorder_Dependency_Response DCON_WO_Dependency_Check(List<Event> lstSFEvent, List<SVMXC__SVMX_Event__c> lstSVMXEvent, String timeZone)
     {
        Workorder_Dependency_Response response = new Workorder_Dependency_Response();
        List<EventErrorMessage> lstEventErrorMsgs = new List<EventErrorMessage>();
        List<Preferrable_Workorder_Timings> lstWOtimings = new List<Preferrable_Workorder_Timings>();
        Set<String> eventWOIds = new Set<String>();
        Set<String> eventWOIds1 = new Set<String>();
        Map<String,String> mapSFEventIdWOId = new Map<String,String>();
        Map<String,String> mapSVMXEventIdWOId = new Map<String,String>();
        Map<String,String> mapWOIdGroupId = new Map<String,String>();
        String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
        Map<String,List<SVMXC__Service_Order_Dependency__c>> mapGroupWODependencies = new Map<String,List<SVMXC__Service_Order_Dependency__c>>();
        Set<String> setownerIds = new Set<String>();
        Map<String,String> mapTechSFUser = new Map<String,String>();
        Map<String, List<Datetime>> mapWOStartEndtime = new Map<String, List<Datetime>>();
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult discResUser = allObjs.get('User').getDescribe();
        List<String> lstTechnicians = new List<String>();           
        Map<String,String> mapPicklistValLable = new Map<String,String>();
        String strtimeDependacncyLabel = '';
        
        Schema.DescribeFieldResult fieldResult = SVMXC__Service_Order_Dependency__c.SVMXC__Time_Dependency__c.getDescribe();
        List<Schema.PicklistEntry> plv = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : plv)
        {
           System.debug('Field Label ' + f.getLabel());
           System.debug('Field Value ' + f.getValue());
           mapPicklistValLable.put(f.getValue(),f.getLabel());
        }
        if(lstSFEvent != null && lstSFEvent.size() > 0)
        {
            for(Event sfevt: lstSFEvent)
            {
                if(String.valueOf(sfevt.WhatId) != null && !String.isBlank(String.valueOf(sfevt.WhatId)))
                {
                    if(woKeyPrefix.equals(String.valueOf(sfevt.WhatId).substring(0,3)))
                    {
                        eventWOIds.add(String.valueOf(sfevt.whatId));
                        mapSFEventIdWOId.put(String.valueOf(sfevt.Id), String.valueOf(sfevt.whatId));
                        if(String.valueof(sfevt.OwnerId).startsWith(discResUser.getKeyPrefix()))
                        {
                            setownerIds.add(sfevt.OwnerId); 
                        }   
                        else
                        {
                            lstTechnicians.add(sfevt.OwnerId);  
                        }       
                    }   
                }
            }
        }
        
        if(lstSVMXEvent != null && lstSVMXEvent.size() > 0)
        {
            for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvent)
            {
                if(String.valueOf(svmxevt.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                {
                    if(woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
                    {
                        eventWOIds.add(String.valueOf(svmxevt.SVMXC__WhatId__c));
                        mapSVMXEventIdWOId.put(String.valueOf(svmxevt.Id), String.valueOf(svmxevt.SVMXC__WhatId__c));
                        lstTechnicians.add(svmxevt.SVMXC__Technician__c);
                    }
                }
            }
        }
        
        Map<Id,SVMXC__Service_Order__c> mapWOIdRecord1;
        if(eventWOIds != null && eventWOIds.size() > 0)
        {
            mapWOIdRecord1 = new Map<Id,SVMXC__Service_Order__c>([SELECT Id, 
                                                                    SVMXC__Dependency_Group__c,
                                                                    SVMXC__Service_Duration__c,
                                                                    SVMXC__Scheduled_Date_Time__c,
                                                                    SVMXC__Dispatch_Process__c,
                                                                    SVMXC__Driving_Time__c 
                                                                    FROM SVMXC__Service_Order__c WHERE Id IN :eventWOIds]);
        }                                                           
        
        for(SVMXC__Service_Order__c wo: mapWOIdRecord1.values())
        {
            mapWOIdGroupId.put(String.valueOf(wo.Id), String.valueOf(wo.SVMXC__Dependency_Group__c));   
        }
        
        Map<Id,SVMXC__Dependency_Management__c> mapGroupIdRecord = new Map<Id,SVMXC__Dependency_Management__c>([SELECT Id,SVMXC__Dependency_Group_Name__c,Name
                                                                    FROM SVMXC__Dependency_Management__c WHERE Id IN :mapWOIdGroupId.values()]); 
                                                                    
        Map<Id,SVMXC__Service_Order_Dependency__c> mapdependencyIdRecord = new Map<Id,SVMXC__Service_Order_Dependency__c>([SELECT Id,                                                          
                                                                    SVMXC__Dependency_Group__c,                                                           
                                                                    SVMXC__Maximum_Time_Deviation__c,
                                                                    SVMXC__Maximum_Time_Deviation_Units__c,
                                                                    SVMXC__Minimum_Time_Deviation__c,
                                                                    SVMXC__Minimum_Time_Deviation_Units__c,
                                                                    SVMXC__Primary_Work_Order__c,
                                                                    SVMXC__Resource_Dependency__c,
                                                                    SVMXC__Secondary_Work_Order__c,
                                                                    SVMXC__Time_Dependency__c 
                                                                    FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Dependency_Group__c IN :mapWOIdGroupId.values()]);
        
        eventWOIds1.addAll(eventWOIds); 
        for(SVMXC__Service_Order_Dependency__c dependency: mapdependencyIdRecord.values())
        {
            eventWOIds1.add(dependency.SVMXC__Primary_Work_Order__c);
            eventWOIds1.add(dependency.SVMXC__Secondary_Work_Order__c);
            if(mapGroupWODependencies.containsKey(dependency.SVMXC__Dependency_Group__c))
            {
                mapGroupWODependencies.get(dependency.SVMXC__Dependency_Group__c).add(dependency);
            }
            else
            {
                List<SVMXC__Service_Order_Dependency__c> tempdep = new List<SVMXC__Service_Order_Dependency__c>();
                tempdep.add(dependency);
                mapGroupWODependencies.put(String.valueOf(dependency.SVMXC__Dependency_Group__c),tempdep);
            }   
            
        }
        System.debug('mapGroupWODependencies:'+ mapGroupWODependencies);
        
        Map<Id,SVMXC__Service_Order__c> mapWOIdRecord;
        
        if(eventWOIds1 != null && eventWOIds1.size() > 0)
        {
            mapWOIdRecord = new Map<Id,SVMXC__Service_Order__c>([SELECT Id,Name,                                                           
                                                                    SVMXC__Dependency_Group__c,
                                                                    SVMXC__Service_Duration__c,
                                                                    SVMXC__Scheduled_Date_Time__c,
                                                                    SVMXC__Dispatch_Process__c,
                                                                    SVMXC__Driving_Time__c,
                                                                    SVMXC__Group_Member__c  
                                                                    FROM SVMXC__Service_Order__c WHERE Id IN :eventWOIds1]);
        }
        System.debug('mapWOIdRecord:'+ mapWOIdRecord);
        
        for(SVMXC__Service_Order_Dependency__c dependency: mapdependencyIdRecord.values())
        {
            if(mapWOIdRecord.containsKey(dependency.SVMXC__Primary_Work_Order__c)){
                lstTechnicians.add(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c);  
            }
        }   
        
        
        Map<Id,SVMXC__Service_Group_Members__c> mapTechIdRecord;
        
        if(setownerIds != null && setownerIds.size() > 0 && lstTechnicians != null && lstTechnicians.size() > 0)
        {   
            mapTechIdRecord = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds OR Id IN :lstTechnicians]);
        }
        else if(setownerIds != null && setownerIds.size() > 0)
        {
            mapTechIdRecord = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds]);   
        }
        else if(lstTechnicians != null && lstTechnicians.size() > 0)
        {
            mapTechIdRecord = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :lstTechnicians]);   
        }       
        for(SVMXC__Service_Group_Members__c tech: mapTechIdRecord.values())    
            {
                if(tech.SVMXC__Salesforce_User__c != null)
                    mapTechSFUser.put(tech.SVMXC__Salesforce_User__c,tech.Id);    
            }
        Boolean primaryWOOfDependency = false;
        Boolean secondaryWOOfDependency = false;
        Boolean isResourceDependencyPassed = true; 
        Integer serviceDuration = 0;
        Integer minDeviation = 0;
        Integer maxDeviation = 0;
        String typeOfTimeDependency = '';
        String typeOfResourceDependency = '';
        Datetime MinStartdatetime;
        Datetime MaxStartdatetime;
        Datetime MinEnddatetime;
        Datetime MaxEnddatetime;
        Boolean minGreatThanMax;
        
        if(lstSFEvent != null && lstSFEvent.size() > 0)
        {
        for(Event sfevt : lstSFEvent)
        {
            primaryWOOfDependency = false;
            secondaryWOOfDependency = false;
            typeOfTimeDependency = '';
            typeOfResourceDependency = '';
            String infoString = '';
            isResourceDependencyPassed = true; 
            
            if(sfevt.whatId != null && woKeyPrefix.equals(String.valueOf(sfevt.whatId).substring(0,3)))
            {
            
            for(SVMXC__Service_Order_Dependency__c dependency: mapGroupWODependencies.get(mapWOIdRecord.get(sfevt.whatId).SVMXC__Dependency_Group__c))
            {
                serviceDuration = 0;
                minDeviation = 0;
                maxDeviation = 0;
                if(String.isBlank(infoString))
                {   
                
                if((String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)) || (String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
                {
                    if((String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)))
                    {
                        primaryWOOfDependency = true;   
                        
                    }
                    else if((String.valueOf(sfevt.whatId)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
                    {
                        secondaryWOOfDependency = true;
                        if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c != null && mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c != null)
                        {
                            if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c != null)
                            {   
                                if(dependency.SVMXC__Resource_Dependency__c == 'Same Resource')
                                    {
                                        if(String.valueof(sfevt.OwnerId).startsWith(discResUser.getKeyPrefix()))
                                        {
                                            if(mapTechSFUser.get(sfevt.ownerId) == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c)
                                                isResourceDependencyPassed = true;  
                                            else
                                            {
                                                isResourceDependencyPassed = false; 
                                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                                infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG002 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" ' + system.label.DCON006_TAG003;
                                                /*infoString = infoString + 'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must also assign this work order to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" or remove the resource dependency of type "Same".';
                                                infoString = infoString + 'Because you assigned the primary work order in this dependency to Technician "xyz", you must also assign this work order to Technician "xyz" or remove the resource dependency of type "Same".'; */
                                            }
                                        }
                                        else
                                        {
                                            if(sfevt.ownerId == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c)
                                                isResourceDependencyPassed = true;  
                                            else
                                            {
                                                isResourceDependencyPassed = false; 
                                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                                infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG002 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" ' + system.label.DCON006_TAG003;
                                                /*infoString = infoString + 'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must also assign this work order to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" or remove the resource dependency of type "Same".'; 
                                                infoString = infoString + 'Because you assigned the primary work order in this dependency to Technician "xyz", you must also assign this work order to Technician "xyz" or remove the resource dependency of type "Same".'; */
                                            }
                                        }   
                                    }
                                
                                if(dependency.SVMXC__Resource_Dependency__c == 'Different Resource')
                                    {
                                        if(String.valueof(sfevt.OwnerId).startsWith(discResUser.getKeyPrefix()))
                                        {
                                            if(!(mapTechSFUser.get(sfevt.ownerId) == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                                isResourceDependencyPassed = true;  
                                            else
                                            {
                                                isResourceDependencyPassed = false; 
                                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                                infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG004;
                                                /*infoString = infoString +'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must assign this work order to a different technician or remove the resource dependency of type "Different".';
                                                infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must assign this work order to a different technician or remove the resource dependency of type "Different".'; */
                                            }
                                        }
                                        else
                                        {
                                            if(!(sfevt.ownerId == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                                isResourceDependencyPassed = true;  
                                            else
                                            {
                                                isResourceDependencyPassed = false; 
                                                typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                                infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG004;
                                                /*infoString = infoString +'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must assign this work order to a different technician or remove the resource dependency of type "Different".';
                                                infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must assign this work order to a different technician or remove the resource dependency of type "Different".'; */ 
                                            }
                                        }   
                                        
                                    }
                                    
                            }
                            else
                            {
                                isResourceDependencyPassed = true;
                            }   
                            
                            if(isResourceDependencyPassed)
                            {   
                                if(!mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)))
                                {
                                if(dependency.SVMXC__Maximum_Time_Deviation__c != null){
                                    if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Hours'){
                                        maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 60);
                                    }
                                    else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Days'){
                                        maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 24 *60);
                                    }
                                    else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Minutes'){
                                        maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
                                    }
                                }
                                if(dependency.SVMXC__Minimum_Time_Deviation__c != null){
                                    if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Hours'){
                                        minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 60);
                                    }
                                    else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Days'){
                                        minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 24 *60);
                                    }
                                    else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Minutes'){
                                        minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
                                    }
                                }

                                if(maxDeviation != null && minDeviation != null) {
                                    if(minDeviation > maxDeviation) {
                                        minDeviation = 0;
                                        maxDeviation = 0;
                                        minGreatThanMax = true;
                                    }
                                }
                                
                                if(dependency.SVMXC__Time_Dependency__c == 'Start to Start' || dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                                {
                                    if(dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                                    {
                                        minDeviation = 0;
                                        maxDeviation = 0;
                                    }
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c).addMinutes(minDeviation);
                                    if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Start to Start') 
                                    {
                                        maxStartdatetime = null;
                                    } else {
                                        maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c).addMinutes(maxDeviation);
                                    }           
                                }
                                else if(dependency.SVMXC__Time_Dependency__c == 'Start to Finish')
                                {
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation);
                                    if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                    {
                                        maxEnddatetime = null;
                                    } else {
                                        maxEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation);
                                    }
                                }
                                else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Start')
                                {
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                    {
                                        maxStartdatetime = null;
                                    } else {
                                        maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    }               
                                }
                                else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Finish' || dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                                {
                                    if(dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                                    {
                                        minDeviation = 0;
                                        maxDeviation = 0;
                                    }
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Finish to Finish')
                                    {
                                        maxEnddatetime = null;
                                    } else {
                                        maxEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    }                           
                                }
                                }   
                            }
                        }
                        else
                        {
                            infoString = infoString + system.label.DCON006_TAG005 + ' ' + mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).Name + ' ' + system.label.DCON006_TAG006;
                            System.debug('The primary work order <WO> has not been scheduled.  You must schedule the primary work that this depends on order before attempting to schedule this one.');
                        }
                    }
                }
            }
            }

            System.debug('wo exists:'+ mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)));
            if(!mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)))
            {   
                List<datetime> lstdatetimes = new List<datetime>();
                lstdatetimes.add(minStartdatetime);
                lstdatetimes.add(maxStartdatetime);
                lstdatetimes.add(minEnddatetime);
                lstdatetimes.add(maxEnddatetime);
                System.debug('lstdatetimes:'+lstdatetimes);
                mapWOStartEndtime.put(String.valueOf(sfevt.whatId),lstdatetimes);
            }
            System.debug('mapWOStartEndtime:'+ mapWOStartEndtime);              
            if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).size() > 0)
            {   
                if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) != null || mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) != null || mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null || mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null)
                {
                    If(sfevt.SVMXC__Overhead_Time_After__c == null)
                        sfevt.SVMXC__Overhead_Time_After__c = 0;
            
                    If(sfevt.SVMXC__Overhead_Time_Before__c == null)
                        sfevt.SVMXC__Overhead_Time_Before__c = 0;
            
                    If(sfevt.SVMXC__Break_Time_Total__c == null)
                        sfevt.SVMXC__Break_Time_Total__c = 0;
            
                    If(sfevt.SVMXC__Driving_Time_Home__c == null)
                        sfevt.SVMXC__Driving_Time_Home__c = 0;
            
                    If(sfevt.SVMXC__Driving_Time__c == null)
                        sfevt.SVMXC__Driving_Time__c = 0;
                    
                    datetime tempWOstarttime =  dcUtils.doTZConversion(((sfevt.StartDateTime.addMinutes(Integer.valueOf(sfevt.SVMXC__Driving_Time__c))).addMinutes(Integer.valueOf(sfevt.SVMXC__Overhead_Time_Before__c))),timeZone,'GMT');
                    System.debug('tempWOstarttime:'+ tempWOstarttime);
                    //calculate end time if does not exist
                    datetime tempWOendtime;
                    if(sfevt.EndDateTime != null)
                    {
                        tempWOendtime = dcUtils.doTZConversion(((sfevt.EndDateTime.addMinutes(-Integer.valueOf(sfevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(sfevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT');
                        System.debug('tempWOstarttime:'+ tempWOstarttime);
                    }
                    else
                    {
                        tempWOendtime = dcUtils.doTZConversion((((sfevt.StartDateTime.addMinutes(Integer.valueOf(sfevt.DurationInMinutes))).addMinutes(-Integer.valueOf(sfevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(sfevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT'); 
                        System.debug('tempWOstarttime:'+ tempWOstarttime);                          
                    }       
                    if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) != null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) || tempWOstarttime > mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1))
                    {
                        infoString = infoString + system.label.DCON006_TAG007;  
                    }
                    if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3) != null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) || tempWOendtime > mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3))
                    {
                        infoString = infoString + system.label.DCON006_TAG008;  
                    }
                    if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) == null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) )
                    {
                        infoString = infoString + system.label.DCON006_TAG007;  
                    }   
                    
                    if(mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) != null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3) == null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2))
                    {
                        infoString = infoString + system.label.DCON006_TAG008;  
                    }
                }
            }
            system.debug('primaryWOOfDependency:'+ primaryWOOfDependency);
            system.debug('secondaryWOOfDependency:'+ secondaryWOOfDependency);
            if(mapWOStartEndtime.containsKey(String.valueOf(sfevt.whatId)) && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(0) == null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(1) == null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(2) == null && mapWOStartEndtime.get(String.valueOf(sfevt.whatId)).get(3) == null)     
            {   
                if(primaryWOOfDependency == true && secondaryWOOfDependency == false)
                {
                    infoString = infoString + 'SUCCESSFUL';
                    System.debug('event can be created anywhere');
                }
            }
            EventErrorMessage e = new EventErrorMessage(String.valueOf(sfevt.Id),String.valueOf(sfevt.whatId),infoString,strtimeDependacncyLabel,typeOfResourceDependency);
            lstEventErrorMsgs.add(e);
            
            minStartdatetime = null;
            maxStartdatetime = null;
            minEnddatetime = null;
            maxEnddatetime = null;
            }
        }
        }
        if(lstSVMXEvent != null && lstSVMXEvent.size() > 0)
        {
        for(SVMXC__SVMX_Event__c svmxevt : lstSVMXEvent)
        {
            primaryWOOfDependency = false;
            secondaryWOOfDependency = false;
            typeOfTimeDependency = '';
            typeOfResourceDependency = '';
            String infoString = '';
            isResourceDependencyPassed = true; 
            
            if(svmxevt.SVMXC__WhatId__c != null && woKeyPrefix.equals(String.valueOf(svmxevt.SVMXC__WhatId__c).substring(0,3)))
            {
            
            for(SVMXC__Service_Order_Dependency__c dependency: mapGroupWODependencies.get(mapWOIdRecord.get(svmxevt.SVMXC__WhatId__c).SVMXC__Dependency_Group__c))
            {
                serviceDuration = 0;
                minDeviation = 0;
                maxDeviation = 0;
                if(String.isBlank(infoString))
                {   
                
                if((String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)) || (String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
                {
                    if((String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Primary_Work_Order__c)))
                    {
                        primaryWOOfDependency = true;   
                        
                    }
                    else if((String.valueOf(svmxevt.SVMXC__WhatId__c)).equals(String.valueOf(dependency.SVMXC__Secondary_Work_Order__c)))
                    {
                        secondaryWOOfDependency = true;
                        if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c != null && mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c != null)
                        {
                            if(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c != null)
                            {   
                                if(dependency.SVMXC__Resource_Dependency__c == 'Same Resource')
                                {
                                    if(dependency.SVMXC__Resource_Dependency__c == 'Same Resource' && (svmxevt.SVMXC__Technician__c == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                    {
                                        isResourceDependencyPassed = true;  
                                    }
                                    else
                                    {
                                        isResourceDependencyPassed = false; 
                                        typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                        infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG002 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" ' + system.label.DCON006_TAG003;
                                        /*infoString = infoString + 'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must also assign this work order to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '" or remove the resource dependency of type "Same".';
                                        infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must also assign this work order to Technician "xyz" or remove the resource dependency of type "Same".';  */  
                                    }
                                }
                                if(dependency.SVMXC__Resource_Dependency__c == 'Different Resource')
                                {   
                                    if(dependency.SVMXC__Resource_Dependency__c == 'Different Resource'  && !(svmxevt.SVMXC__Technician__c == mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c))
                                    {
                                        isResourceDependencyPassed = true;  
                                    }
                                    else
                                    {
                                        isResourceDependencyPassed = false; 
                                        typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                        infoString = infoString + system.label.DCON006_TAG001 + ' "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '"'+ system.label.DCON006_TAG004;
                                        /*infoString = infoString +'Since the primary work order in this dependency is assigned to Technician "' + mapTechIdRecord.get(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c).Name + '", you must assign this work order to a different technician or remove the resource dependency of type "Different".';
                                        infoString = infoString +'Because you assigned the primary work order in this dependency to Technician "xyz", you must assign this work order to a different technician or remove the resource dependency of type "Different".'; */
                                    }
                                }   
                            }
                            else
                            {
                                isResourceDependencyPassed = true;
                            }   
                            
                            if(isResourceDependencyPassed)
                            {   
                                if(!mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)))
                                {
                                if(dependency.SVMXC__Maximum_Time_Deviation__c != null){
                                    if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Hours'){
                                        maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 60);
                                    }
                                    else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Days'){
                                        maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c * 24 *60);
                                    }
                                    else if(dependency.SVMXC__Maximum_Time_Deviation_Units__c == 'Minutes'){
                                        maxDeviation = Integer.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
                                    }
                                }
                                if(dependency.SVMXC__Minimum_Time_Deviation__c != null){
                                    if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Hours'){
                                        minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 60);
                                    }
                                    else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Days'){
                                        minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c * 24 *60);
                                    }
                                    else if(dependency.SVMXC__Minimum_Time_Deviation_Units__c == 'Minutes'){
                                        minDeviation = Integer.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
                                    }
                                }
                                if(maxDeviation != null && minDeviation != null) {
                                    if(minDeviation > maxDeviation) {
                                        minDeviation = 0;
                                        maxDeviation = 0;
                                        minGreatThanMax = true;
                                    }
                                }
                                if(dependency.SVMXC__Time_Dependency__c == 'Start to Start' || dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                                {
                                    if(dependency.SVMXC__Time_Dependency__c == 'Start in Unison')
                                    {
                                        minDeviation = 0;
                                        maxDeviation = 0;
                                    }
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minStartdatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation);
                                    if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Start to Start') 
                                    {
                                        maxStartdatetime = null;
                                    } else {
                                        maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c).addMinutes(maxDeviation);
                                    }
                                }
                                else if(dependency.SVMXC__Time_Dependency__c == 'Start to Finish')
                                {
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation);
                                    if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                    {
                                        maxEnddatetime = null;
                                    } else {
                                        maxEnddatetime = mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation);
                                    }
                                }
                                else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Start')
                                {
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    if(dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) 
                                    {
                                        maxStartdatetime = null;
                                    } else {
                                        maxStartdatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    }                        
                                }
                                else if(dependency.SVMXC__Time_Dependency__c == 'Finish to Finish' || dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                                {
                                    if(dependency.SVMXC__Time_Dependency__c == 'Finish in Unison')
                                    {
                                        minDeviation = 0;
                                        maxDeviation = 0;
                                    }
                                    typeOfTimeDependency = dependency.SVMXC__Time_Dependency__c;
                                    if(!mapPicklistValLable.isempty() && mapPicklistValLable.containsKey(typeOfTimeDependency))
                                        strtimeDependacncyLabel = mapPicklistValLable.get(typeOfTimeDependency);
                                    typeOfResourceDependency = dependency.SVMXC__Resource_Dependency__c;
                                    minEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(minDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    if((dependency.SVMXC__Maximum_Time_Deviation__c == null || dependency.SVMXC__Maximum_Time_Deviation__c == 0 || minGreatThanMax == true) && dependency.SVMXC__Time_Dependency__c == 'Finish to Finish')
                                    {
                                        maxEnddatetime = null;
                                    } else {
                                        maxEnddatetime = (mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Scheduled_Date_Time__c.addMinutes(maxDeviation)).addSeconds(Integer.valueOf(mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Service_Duration__c));
                                    }                           
                                }
                                }   
                            }
                        }
                        else
                        {
                            infoString = infoString + system.label.DCON006_TAG005 + ' ' + mapWOIdRecord.get(dependency.SVMXC__Primary_Work_Order__c).Name + ' ' + system.label.DCON006_TAG006;
                            System.debug('Schedule date time and Service duration of primary work order is not available to calculate start time and end time of secondary workorder');
                        }
                    }
                }
            }
            }
            System.debug('wo exists:'+ mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)));
            System.debug('wo not exists:'+ !mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)));
            if(!mapWOStartEndtime.containsKey(String.valueOf(svmxevt.SVMXC__WhatId__c)))
            {   
                System.debug('entering:');
                List<datetime> lstdatetimes = new List<datetime>();
                lstdatetimes.add(minStartdatetime);
                lstdatetimes.add(maxStartdatetime);
                lstdatetimes.add(minEnddatetime);
                lstdatetimes.add(maxEnddatetime);
                System.debug('lstdatetimes:'+lstdatetimes);
                mapWOStartEndtime.put(String.valueOf(svmxevt.SVMXC__WhatId__c),lstdatetimes);
            }
            System.debug('mapWOStartEndtime:'+ mapWOStartEndtime);
            if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).size() > 0)
            {   
                if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) != null || mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1) != null || mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null || mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null)
                {
                    If(svmxevt.SVMXC__Overhead_Time_After__c == null)
                        svmxevt.SVMXC__Overhead_Time_After__c = 0;
            
                    If(svmxevt.SVMXC__Overhead_Time_Before__c == null)
                        svmxevt.SVMXC__Overhead_Time_Before__c = 0;
            
                    If(svmxevt.SVMXC__Break_Time_Total__c == null)
                        svmxevt.SVMXC__Break_Time_Total__c = 0;
            
                    If(svmxevt.SVMXC__Driving_Time_Home__c == null)
                        svmxevt.SVMXC__Driving_Time_Home__c = 0;
            
                    If(svmxevt.SVMXC__Driving_Time__c == null)
                        svmxevt.SVMXC__Driving_Time__c = 0;
                    
                    datetime tempWOstarttime =  dcUtils.doTZConversion(((svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueOf(svmxevt.SVMXC__Driving_Time__c))).addMinutes(Integer.valueOf(svmxevt.SVMXC__Overhead_Time_Before__c))),timeZone,'GMT');
                    //calculate end time if does not exist
                    datetime tempWOendtime;
                    if(svmxevt.SVMXC__EndDateTime__c != null)
                    {
                        tempWOendtime = dcUtils.doTZConversion(((svmxevt.SVMXC__EndDateTime__c.addMinutes(-Integer.valueOf(svmxevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(svmxevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT');
                    }
                    else
                    {
                        tempWOendtime = dcUtils.doTZConversion((((svmxevt.SVMXC__StartDateTime__c.addMinutes(Integer.valueOf(svmxevt.SVMXC__DurationInMinutes__c))).addMinutes(-Integer.valueOf(svmxevt.SVMXC__Driving_Time_Home__c))).addMinutes(-Integer.valueOf(svmxevt.SVMXC__Overhead_Time_After__c))),timeZone,'GMT');    
                    }       
                    if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1) != null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) || tempWOstarttime > mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1))
                    {
                        infoString = infoString + system.label.DCON006_TAG007;  
                    }
                    if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(3) != null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) || tempWOendtime > mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(3))
                    {
                        infoString = infoString + system.label.DCON006_TAG008;  
                    }
                    if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(1) == null && tempWOstarttime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(0) )
                    {
                        infoString = infoString + system.label.DCON006_TAG007;  
                    }   
                    
                    if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2) != null && mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(3) == null && tempWOendtime < mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).get(2))
                    {
                        infoString = infoString + system.label.DCON006_TAG008;  
                    }
                }
            }
            system.debug('primaryWOOfDependency:'+ primaryWOOfDependency);
            system.debug('secondaryWOOfDependency:'+ secondaryWOOfDependency);
            if(mapWOStartEndtime.get(String.valueOf(svmxevt.SVMXC__WhatId__c)).size() == 0) 
            {   
                if(primaryWOOfDependency == true && secondaryWOOfDependency == false)
                {
                    infoString = infoString + 'SUCCESSFUL';
                    System.debug('event can be created anywhere');
                }
            }
            EventErrorMessage e = new EventErrorMessage(String.valueOf(svmxevt.Id),String.valueOf(svmxevt.SVMXC__WhatId__c),infoString,strtimeDependacncyLabel,typeOfResourceDependency);
            lstEventErrorMsgs.add(e);
            
            minStartdatetime = null;
            maxStartdatetime = null;
            minEnddatetime = null;
            maxEnddatetime = null;
            }
        }
        }
        for(String wo: mapWOStartEndtime.keySet())
        {
            if(mapWOStartEndtime.get(wo) != null && mapWOStartEndtime.get(wo).size() > 0)
            {
                if(((mapWOStartEndtime.get(wo)).get(1)) != null || ((mapWOStartEndtime.get(wo)).get(3))!= null)
                {
                    Preferrable_Workorder_Timings tempWODetails = new Preferrable_Workorder_Timings(wo,String.valueOfGmt(dcUtils.doTZConversion(((mapWOStartEndtime.get(wo)).get(0)),'GMT',timeZone)),String.valueOfGmt(dcUtils.doTZConversion(((mapWOStartEndtime.get(wo)).get(1)),'GMT',timeZone)),String.valueOfGmt(dcUtils.doTZConversion(((mapWOStartEndtime.get(wo)).get(2)),'GMT',timeZone)),String.valueOfGmt(dcUtils.doTZConversion(((mapWOStartEndtime.get(wo)).get(3)),'GMT',timeZone)),String.valueOf(mapGroupIdRecord.get(mapWOIdRecord.get(wo).SVMXC__Dependency_Group__c).Name));
                    lstWOtimings.add(tempWODetails);
                }
                if(((mapWOStartEndtime.get(wo)).get(1)) == null && ((mapWOStartEndtime.get(wo)).get(3))== null)
                {
                    Preferrable_Workorder_Timings tempWODetails = new Preferrable_Workorder_Timings(wo,String.valueOfGmt(dcUtils.doTZConversion(((mapWOStartEndtime.get(wo)).get(0)),'GMT',timeZone)),null,String.valueOfGmt(dcUtils.doTZConversion(((mapWOStartEndtime.get(wo)).get(2)),'GMT',timeZone)),null,String.valueOf(mapGroupIdRecord.get(mapWOIdRecord.get(wo).SVMXC__Dependency_Group__c).Name));
                    lstWOtimings.add(tempWODetails);
                }
            }
        }

        response.woDetails.addAll(lstWOtimings);
        response.eventDetails.addAll(lstEventErrorMsgs);
        lstWOtimings.clear();
        lstEventErrorMsgs.clear();
        System.debug('response:'+ response);
        return response;
    }
    /**
    @ Webservice Name : DCON_WO_Get_Dependency_Details_WS
    @ Description     : Method used to fetch dependency details for work order id's sent in the request
    @ Input Parameter : Workorder_dependency_request req
                        listWOIds - list of WO id's
    @ Output Parameter: List<Dependency_Details>
                        list of wrapper containing dependency details.     
                        
    */
    WebService static List<Dependency_Details> DCON_WO_Get_Dependency_Details_WS(Workorder_Dependency_Request req) {
        Set<String> setReqWOIds = new Set<String>();
        setReqWOIds.addAll(req.listWOIds);
        List<Dependency_Details> listDependencyDetails = new List<Dependency_Details>();
        Set<String> setWOIds = new Set<String>();
        setWOIds.addAll(setReqWOIds);

        List<SVMXC__Service_Order_Dependency__c> listDependency = new list<SVMXC__Service_Order_Dependency__c>([SELECT Id,                                                            
                                                                SVMXC__Dependency_Group__r.name,                                                             
                                                                SVMXC__Maximum_Time_Deviation__c,
                                                                SVMXC__Maximum_Time_Deviation_Units__c,
                                                                SVMXC__Minimum_Time_Deviation__c,
                                                                SVMXC__Minimum_Time_Deviation_Units__c,
                                                                SVMXC__Primary_Work_Order__c,
                                                                SVMXC__Resource_Dependency__c,
                                                                SVMXC__Secondary_Work_Order__c,
                                                                SVMXC__Time_Dependency__c 
                                                                FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Primary_Work_Order__c IN :setReqWOIds OR SVMXC__Secondary_Work_Order__c IN :setReqWOIds]);
        for(SVMXC__Service_Order_Dependency__c dependency : listDependency) {
            setWOIds.add(dependency.SVMXC__Primary_Work_Order__c);
            setWOIds.add(dependency.SVMXC__Secondary_Work_Order__c);
        }

        Map<Id,SVMXC__Service_Order__c> mapWo = new Map<Id,SVMXC__Service_Order__c>([Select id,SVMXC__Group_Member__c,SVMXC__Group_Member__r.name, 
                                                                                                    SVMXC__Scheduled_Date_Time__c
                                                                                                    FROM SVMXC__Service_Order__c WHERE id IN :setWOIds]);
        
        List<event> lstSFEvent = new List<event>([Select id, StartDateTime,SVMXC__Service_Duration__c, SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, WhatId,
                                                            SVMXC__Break_Time_Total__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c 
                                                            FROM event WHERE WhatId IN : setWOIds]);
        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>([Select id,SVMXC__StartDateTime__c, SVMXC__Service_Duration__c, SVMXC__Driving_Time__c,SVMXC__Service_Order__c,
                                                                                                SVMXC__Driving_Time_Home__c, SVMXC__Break_Time_Total__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c
                                                                                                FROM SVMXC__SVMX_Event__c WHERE SVMXC__Service_Order__c IN : setWOIds]);
        Map<String,event> mapWOEvents = new Map<String,Event>();
        Map<String,SVMXC__SVMX_Event__c> mapWOSvmxEvents = new Map<String,SVMXC__SVMX_Event__c>();
        for(event sfevent: lstSFEvent) {
            if(mapWo.containsKey(sfevent.Whatid) && mapWo.get(sfevent.Whatid).SVMXC__Scheduled_Date_Time__c != null) {
                if(sfevent.StartDateTime == mapWo.get(sfevent.Whatid).SVMXC__Scheduled_Date_Time__c) {
                    mapWOEvents.put(sfevent.whatId,sfevent);
                }
            }
        }
        for(SVMXC__SVMX_Event__c svmxevent : lstSVMXEvent) {
            if(mapWo.containsKey(svmxevent.SVMXC__Service_Order__c) && mapWo.get(svmxevent.SVMXC__Service_Order__c).SVMXC__Scheduled_Date_Time__c != null) {
                if(svmxevent.SVMXC__StartDateTime__c == mapWo.get(svmxevent.SVMXC__Service_Order__c).SVMXC__Scheduled_Date_Time__c) {
                    mapWOSvmxEvents.put(svmxevent.SVMXC__Service_Order__c,svmxevent);
                }
            }
        }
        for(SVMXC__Service_Order_Dependency__c dependency : [SELECT Id,                                                            
                                                                SVMXC__Dependency_Group__c,
                                                                SVMXC__Dependency_Group__r.Name,                                                             
                                                                SVMXC__Maximum_Time_Deviation__c,
                                                                SVMXC__Maximum_Time_Deviation_Units__c,
                                                                SVMXC__Minimum_Time_Deviation__c,
                                                                SVMXC__Minimum_Time_Deviation_Units__c,
                                                                SVMXC__Primary_Work_Order__c,
                                                                SVMXC__Primary_Work_Order__r.SVMXC__Group_Member__c,
                                                                SVMXC__Primary_Work_Order__r.Name,
                                                                SVMXC__Resource_Dependency__c,
                                                                SVMXC__Secondary_Work_Order__c,
                                                                SVMXC__Secondary_Work_Order__r.name,
                                                                SVMXC__Time_Dependency__c 
                                                                FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Primary_Work_Order__c IN :setReqWOIds OR SVMXC__Secondary_Work_Order__c IN :setReqWOIds]) {

            if(setReqWOIds.contains(dependency.SVMXC__Primary_Work_Order__c)) {
                Dependency_Details dependencyDetails = new Dependency_Details();
                dependencyDetails.woId = dependency.SVMXC__Primary_Work_Order__c;
                dependencyDetails.isPrimaryWorkOrder = true;
                dependencyDetails.dependencyGroup = dependency.SVMXC__Dependency_Group__c;
                dependencyDetails.maximumDeviation = String.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
                dependencyDetails.maximumDeviationUnits = dependency.SVMXC__Maximum_Time_Deviation_Units__c;
                dependencyDetails.minimumDeviation = String.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
                dependencyDetails.minimumDeviationUnits = dependency.SVMXC__Minimum_Time_Deviation_Units__c;
                dependencyDetails.primaryWorkOrder = dependency.SVMXC__Primary_Work_Order__c;
                dependencyDetails.secondaryWorkOrder = dependency.SVMXC__Secondary_Work_Order__c;
                dependencyDetails.primaryWorkOrderName = dependency.SVMXC__Primary_Work_Order__r.Name;
                dependencyDetails.secondaryWorkOrderName = dependency.SVMXC__Secondary_Work_Order__r.Name;
                dependencyDetails.resourceDependency = dependency.SVMXC__Resource_Dependency__c;
                dependencyDetails.timeDependency = dependency.SVMXC__Time_Dependency__c;
                dependencyDetails.technicianId = null;
                listDependencyDetails.add(dependencyDetails);
            }
            if(setReqWOIds.contains(dependency.SVMXC__Secondary_Work_Order__c)) {
                Dependency_Details dependencyDetails = new Dependency_Details();
                dependencyDetails.woId = dependency.SVMXC__Secondary_Work_Order__c;
                dependencyDetails.isPrimaryWorkOrder = false;
                dependencyDetails.dependencyGroup = dependency.SVMXC__Dependency_Group__c;
                dependencyDetails.maximumDeviation = String.valueOf(dependency.SVMXC__Maximum_Time_Deviation__c);
                dependencyDetails.maximumDeviationUnits = dependency.SVMXC__Maximum_Time_Deviation_Units__c;
                dependencyDetails.minimumDeviation = String.valueOf(dependency.SVMXC__Minimum_Time_Deviation__c);
                dependencyDetails.minimumDeviationUnits = dependency.SVMXC__Minimum_Time_Deviation_Units__c;
                dependencyDetails.primaryWorkOrder = dependency.SVMXC__Primary_Work_Order__c;
                dependencyDetails.secondaryWorkOrder = dependency.SVMXC__Secondary_Work_Order__c;
                dependencyDetails.primaryWorkOrderName = dependency.SVMXC__Primary_Work_Order__r.Name;
                dependencyDetails.secondaryWorkOrderName = dependency.SVMXC__Secondary_Work_Order__r.Name;
                dependencyDetails.resourceDependency = dependency.SVMXC__Resource_Dependency__c;
                dependencyDetails.timeDependency = dependency.SVMXC__Time_Dependency__c;
                if(mapWo.get(dependency.SVMXC__Primary_Work_Order__c) != null) {
                    dependencyDetails.technicianId = mapWo.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__c;
                    dependencyDetails.technicianName = mapWo.get(dependency.SVMXC__Primary_Work_Order__c).SVMXC__Group_Member__r.name;
                }
                dependencyDetails.primaryWOName = dependency.SVMXC__Primary_Work_Order__r.Name;
                dependencyDetails.dependencyGroupName = dependency.SVMXC__Dependency_Group__r.Name;
                List<event> sfEvents = new List<event>();
                List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
                if(mapWo.containsKey(dependency.SVMXC__Primary_Work_Order__c)) {
                    if(mapWOEvents.get(dependency.SVMXC__Primary_Work_Order__c) != null) {
                        sfEvents.add(mapWOEvents.get(dependency.SVMXC__Primary_Work_Order__c));
                    }
                    if(mapWOSvmxEvents.get(dependency.SVMXC__Primary_Work_Order__c) != null) {
                        svmxEvents.add(mapWOSvmxEvents.get(dependency.SVMXC__Primary_Work_Order__c));
                    }
                }
                
                if (sfEvents.size() == 0 && svmxEvents.size() == 0) {
                    listDependencyDetails.add(dependencyDetails);
                    continue;
                }
                if(svmxEvents.size() == 0 || (sfEvents.size() != 0 && svmxEvents.size() != 0 && sfEvents[0].StartDateTime > svmxEvents[0].SVMXC__StartDateTime__c)) {
                    if(sfEvents.size() != 0) {
                        dependencyDetails.scheduledStartTime = String.valueOfGMT(dcUtils.doTZConversion(sfEvents[0].StartDateTime,'GMT',req.timezone));
                        dependencyDetails.serviceDuration = String.valueOf(sfEvents[0].SVMXC__Service_Duration__c);
                        dependencyDetails.breakTime = String.valueOf(sfEvents[0].SVMXC__Break_Time_Total__c);
                        dependencyDetails.driveTimeBefore = String.valueOf(sfEvents[0].SVMXC__Driving_Time__c);
                        dependencyDetails.driveTimeAfter = String.valueOf(sfEvents[0].SVMXC__Driving_Time_Home__c);
                        dependencyDetails.overHeadTimeBefore = String.valueOf(sfEvents[0].SVMXC__Overhead_Time_Before__c);
                        dependencyDetails.overHeadTimeAfter = String.valueOf(sfEvents[0].SVMXC__Overhead_Time_After__c);
                    }
                }

                if(sfEvents.size() == 0 || (sfEvents.size() != 0 && svmxEvents.size() != 0 && sfEvents[0].StartDateTime < svmxEvents[0].SVMXC__StartDateTime__c)) {
                    if(svmxEvents.size() != 0) {
                        dependencyDetails.scheduledStartTime = String.valueOfGMT(dcUtils.doTZConversion(svmxEvents[0].SVMXC__StartDateTime__c,'GMT',req.timezone));
                        dependencyDetails.serviceDuration = String.valueOf(svmxEvents[0].SVMXC__Service_Duration__c);
                        dependencyDetails.breakTime = String.valueOf(svmxEvents[0].SVMXC__Break_Time_Total__c);
                        dependencyDetails.driveTimeBefore = String.valueOf(svmxEvents[0].SVMXC__Driving_Time__c);
                        dependencyDetails.driveTimeAfter = String.valueOf(svmxEvents[0].SVMXC__Driving_Time_Home__c);
                        dependencyDetails.overHeadTimeBefore = String.valueOf(svmxEvents[0].SVMXC__Overhead_Time_Before__c);
                        dependencyDetails.overHeadTimeAfter = String.valueOf(svmxEvents[0].SVMXC__Overhead_Time_After__c);
                    }
                }


                
                listDependencyDetails.add(dependencyDetails);
            }

        }

        //Workorder_Dependency_Response response = new Workorder_Dependency_Response();
        //response.listDependencyDetails = listDependencyDetails;
        return listDependencyDetails;
    }

}