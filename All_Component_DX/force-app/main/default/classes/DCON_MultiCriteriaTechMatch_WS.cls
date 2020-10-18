global class DCON_MultiCriteriaTechMatch_WS
{ 
    public DCON_MultiCriteriaTechMatch_WS()
    {}
    
    //QTL computation related functions - to reuse some of them
    public static SMAX_OptiMax_EngineUtils clsOMAXEngineUtils = new SMAX_OptiMax_EngineUtils();
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    public class SVMXException extends Exception {}
    
    // Class to capture Stack rank 
    global class stackRank
    {
        public Id tech;
        public String tName;
        public Boolean valid;
        public Integer prefTech;
        public Integer prod;
        public Integer eligible;
        public Integer skillR;
        public Double skillO;
        public Integer stackRank;
    }

    //Skill details
    global class skill
    {
        WebService string skillId;
        WebService String skillName;
        WebService Boolean isSkillMandatory;
        WebService Integer skillLevel;
        
        global skill(){}
        global skill(string skillId, String skillName, Boolean isSkillMandatory, Integer skillLevel){
            this.skillId = skillId;
            this.skillName = skillName;
            this.isSkillMandatory = isSkillMandatory;
            this.skillLevel = skillLevel;
        }
    }

    //DNS-926/966: MPX technicians details - added new global class to handle list of technicians
    global class MPXTechnicians
    {
        WebService String techID;
        WebService String techPreferenceType;
        WebService string strDeleted; //indicate if a technican record is 'deleted' (empty if not deleted)
        
        global MPXTechnicians(){}
        global MPXTechnicians(String techID, String techPreferenceType, String strDeleted){
            this.techID = techID;
            this.techPreferenceType = techPreferenceType;
        this.strDeleted = strDeleted;
        }
    }
    
    //Eligibility details
    global class Eligibility
    {
        WebService string techField;
        WebService string operator;
        WebService string WOfield;
        WebService string value;
        //WebService string AdvExp;
        
        
        public Eligibility(){}
        public Eligibility(string techField, String operator,string WOfield,string value)//,string AdvExp)
        {
            this.techField = techField;
            this.operator = operator;
            this.WOfield = WOfield;         
            this.value = value;         
           // this.AdvExp = AdvExp;         
        }
    }
    
    //Technician Address details
    global class techAddress
    {
        public Id technicianId;
        public String address;
        public Double latitude;
        public Double longitude;
        
        public techAddress(){}
        
        public techAddress(Id technicianId, String address, Decimal latitude, Decimal longitude){
            this.technicianId = technicianId;
            this.address = address;
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }
    //MCTM details Containing details like Preferred tech, Product Expertise, Skill Matching Rule, Eligibility rules and can be scaled in future as per the need
    // This is being communicated to client in return of getMCTMDetails(..)
    global class MCTMDetails
    {
        
        webservice string productExpertise{get;set;}
        WebService list<Eligibility> lstEligibility = new list<Eligibility>();  
        WebService list<skill> lstskill = new list<skill>();
        webservice list<SVMXMap> lstCandidatePrefTechId = new list<SVMXMap>();
        webservice list<String> lstEventHover = new list<String>();
        
        global MCTMDetails(string productExpertise,list<Eligibility> lstEligibility,list<skill>lstskill, list<SVMXMap> lstCandidatePrefTechId)
        {
            
            this.productExpertise = productExpertise;
            this.lstEligibility = lstEligibility;
            this.lstskill = lstskill;
            this.lstCandidatePrefTechId = lstCandidatePrefTechId;
           
            
        }
        global MCTMDetails(string productExpertise,list<Eligibility> lstEligibility,list<skill>lstskill, list<SVMXMap> lstCandidatePrefTechId, list<String> lstEventHover)
        {
            
            this.productExpertise = productExpertise;
            this.lstEligibility = lstEligibility;
            this.lstskill = lstskill;
            this.lstCandidatePrefTechId = lstCandidatePrefTechId;
            this.lstEventHover = lstEventHover;
            
        }
        global MCTMDetails(){}
        
        
    }
    
    //Wrapper class containing details like WO Id, List of tech for Which QTL has Preferred tech, Product Expertise, Skill Matching Rule, Eligibility rules , to be passed in by the client - currently 1 WO can be passed in/per request
    global class MCTM_Request 
    {
        webservice string WOid{get;set;}
        webservice list<string>lstTech = new list<string>();        
        webservice string preferredTechId{get;set;}
        webservice list<MPXTechnicians> lstMPXTechnicans = new list<MPXTechnicians>();
        webservice string productExpertise{get;set;}
        webservice list<skill> lstSkill = new list<skill>();
        webservice list<Eligibility> lstEligibility = new list<Eligibility>();        
        webservice boolean isPreferredTechEnabled{get;set;}
        webservice boolean isproductExpertiseEnabled{get;set;}
        webservice boolean isSkillsEnabled{get;set;}
        webservice boolean isEligibilityEnabled{get;set;}
        
        //@deprecated - commented since it is not working as expected
        //This method is deprecated as it was not supporting list of technicians, use new constructor as below 
        global MCTM_Request(string WOid, string preferredTech, string productExpertise, list<string>lstTech,list<skill>lstSkill, list<Eligibility>lstEligibility)
        {
            this.WOid = WOid;
            this.preferredTechId = preferredTechId;
            this.productExpertise = productExpertise;
            this.lstTech = lstTech;
            this.lstSkill = lstSkill;
            this.lstEligibility = lstEligibility;
            
        }
        
        //DNS-926/966: Introduced new constructor which takes list of technicans
        global MCTM_Request(string WOid, 
                            list<MPXTechnicians> lstMPXTechnicans, 
                            string productExpertise, 
                            list<string> lstTech,
                            list<skill> lstSkill, 
                            list<Eligibility>lstEligibility) 
        {
            this.WOid = WOid;
            this.lstMPXTechnicans = lstMPXTechnicans; 
            this.productExpertise = productExpertise;
            this.lstTech = lstTech;
            this.lstSkill = lstSkill;
            this.lstEligibility = lstEligibility;
            
        }
        global MCTM_Request()
        {
            
        }
        global List<String> getlstTech(){return lstTech;}
        global void setlstTech(List<String> s ){lstTech = s;}
        global list<Eligibility> getlstEligibility(){return lstEligibility;}
        global void setlstEligibility(list<Eligibility> s ){lstEligibility = s;}
    }
    //Wrapper class containing Qualified Technician List(QTL), to be returned to the client

    global class MCTM_Response 
    {
        
        webservice  List<SVMXMap> valueMap{get;set;}
        
        global MCTM_Response(List<SVMXMap> valueMap )
        {
         this.valueMap = valueMap;
        }
        
        
        global MCTM_Response()
        {
        }
                 
    }
    // Wrapper class having Key ,value
    
    global class SVMXMap
    {
        webservice String key{get;set;} // being used for lstCandidatePrefTechId
        webservice String value{get;set;} // being used for lstCandidatePrefTechId
        webservice list<String> values {get;set;}
        webservice List<SVMXMap> valueMap{get;set;} // being used for QTL
        webservice list<skill> lstSkill{get;set;} // being used for QTL
        webservice List<sObject> data{get;set;}
        webservice sObject record{get;set;} // being used for QTL
        
        global SVMXMap()
        {
            values = new list<String>();
            valueMap = new list<SVMXMap>();
            lstSkill = new list<skill>();
        }
        global SVMXMap(String key, String value)
        {
            this.key = key;
            this.value = value;
            values = new list<String>();
            valueMap = new list<SVMXMap>();
        }
        global SVMXMap(String key, String value, List<String> values)
        {
            this.key = key;
            this.value = value;
            this.values = new List<String>();
            this.values = values;
            valueMap = new list<SVMXMap>();
        }
    }
    
    global class SVMXMapofIdandSkill {
        webservice Id key{get;set;}
        webservice skill skillValue{get;set;}
        webservice String value{get;set;}
        webservice list<skill> lstSkill{get;set;}
        
        global SVMXMapofIdandSkill() {
            lstSkill = new list<skill>();
        }
        
        global SVMXMapofIdandSkill(Id key, skill skillValue) {
            this.key = key;
            this.skillValue = skillValue;
        }
        
        global SVMXMapofIdandSkill(Id key, String value) {
            this.key = key;
            this.value = value;
        }
        
        global SVMXMapofIdandSkill(Id key, List<skill> lstSkill) {
            this.key = key;
            lstSkill = new List<skill>();
        }
    }
    
    global class Skill_Request 
    {
        webservice list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        webservice list<Id> lstTech = new list<Id>();
        webservice list<skill> lstSkills = new list<skill>();
        global List<SVMXC__Service_Order__c> getlstWorkOrder(){return lstWorkOrder;}
        global void setlstWorkOrder(List<SVMXC__Service_Order__c> s ){lstWorkOrder = s;}
        global List<Id> getlstTech(){return lstTech;}
        global void setlstTech(List<Id> s ){lstTech = s;}
        global List<skill> getlstSkills(){return lstSkills;}
        global void setlstSkills(List<skill> s ){lstSkills = s;}        
    }
    
    public static COMM_SVMXC_Utils4 clsUtils4 = new COMM_SVMXC_Utils4();
    public static COMM_Utils utils = new COMM_Utils();
    public static String MSG_QTLCOMPUTED = 'Qualified Technician List Computed';
    public static String MSG_QTLCOMPUTED_NOTECH_ALLOW = 'No Qualified Technicians (Allow)';
    public static String MSG_QTLCOMPUTED_NOTECH_DISALLOW = 'No Qualified Technicians (Disallow)';
    public static String MSG_QTLCOMPUTED_NOTECH_WARN = 'No Qualified Technicians (Warn)';
    public static String strEligibilityMatchSays = 'ALLOW';
    public static String strSkillMatchSays = 'ALLOW';
    public static String strExistingSkillSet = '';
    public static String strExistingQTL = '';
    public static Integer defaultPreferredTechnicianScore = 10;
    public static Integer defaultProductSpecializationScore = 10;
    public static Integer defaultEligibilityScore = 10;
    public static Integer defaultSkillScore = 10;
    public static Integer optionalSkillCount = 0;
    public static Integer ReqSkillCount = 0;
    public static Integer ReqSkillCnt = 0; // Since ReqSkillCount is feeding only at certain conditions declaring new variable for count of required skills
    public static boolean isWOToBeupdated = false;
    public static set<Id> setNonQualifiedWorkOrdersAllow = new set<Id>();
    public static set<Id> setNonQualifiedWorkOrdersDisallow = new set<Id>();
    public static map<Id, list<skill>> mapWorkOrderMatchedSkills = new map<Id, list<skill>>();
    public static map<Id, Integer> mapWorkOrderRequiredSkillCount = new map<Id, Integer>();
    public static map<Id, Integer> mapWorkOrderOptionalSkillCount = new map<Id, Integer>();
    public static map<Id, set<Id>> mapMandatoryMatchedSkills = new map<Id, set<Id>>();
    
    //CRUD 
    public static String[] types = new String[]{'SVMXC__Service_Order__c','SVMXC__Work_Order_Resource__c'};   
    public static map<string, string> mapobjectApiLabel = new map<string, string>();

    //Method returns Qualified Technician List in Json format.It also return Skill set in Json format
    
    WebService static MCTM_Response getQualifiedTechList(MCTM_Request Req)
    {
           
        MCTM_Response response = new MCTM_Response();       
        list<Id> lstWorkorderIds = new list<Id>();
        list<SVMXMap> lstWorkOrderWrapper = new list<SVMXMap>();
        
        //CRUD
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results)
            {
                mapobjectApiLabel.put(res.getName(),res.getLabel());        
            }
            
        //QTL
        try
        {
            system.debug(logginglevel.warn,'Req:  '+ Req);
            //Throw error if Required WO id and list of tech is not available for QTL computation
            if(Req == null && Req.WOid == null || Req.WOid =='' || Req.lstTech == null || Req.lstTech.size() == 0)
            {
                throw new SVMXException(system.label.DCON001_TAG380);
            }
            lstWorkorderIds.add(Req.WOid); 
            populateWeightageToCompute();    
            map<Id, SVMXC__Service_Order__c> mapQTLWorkOrders = buildQualifiedTechnicians(lstWorkorderIds,Req.lstTech,Req.lstSkill,Req.lstEligibility,Req.lstMPXTechnicans,Req.productExpertise,Req.isPreferredTechEnabled,Req.isproductExpertiseEnabled,Req.isSkillsEnabled, Req.isEligibilityEnabled);
            for(SVMXC__Service_Order__c objWO: mapQTLWorkOrders.values())
            {
                if(objWO.SVMXC__Qualified_Technicians__c != null || objWO.SVMXC__Skill_Set__c != null)
                {
                    SVMXMap wrpWorkOrder = new SVMXMap(objWO.Id, null);
                    wrpWorkOrder.record = new SVMXC__Service_Order__c(SVMXC__Qualified_Technicians__c = objWO.SVMXC__Qualified_Technicians__c, SVMXC__Skill_Set__c = objWO.SVMXC__Skill_Set__c);
                    lstWorkOrderWrapper.add(wrpWorkOrder);
                }
                system.debug(LoggingLevel.WARN, 'strExistingQTL: '+strExistingQTL);
                system.debug(LoggingLevel.WARN, 'strExistingSkillSet: '+strExistingSkillSet);
                system.debug(LoggingLevel.WARN, 'objWO.SVMXC__Skill_Set__c: '+objWO.SVMXC__Skill_Set__c);
                system.debug(LoggingLevel.WARN, 'objWO.SVMXC__Qualified_Technicians__c: '+objWO.SVMXC__Qualified_Technicians__c);
                if(((objWO.SVMXC__Qualified_Technicians__c == '' ||objWO.SVMXC__Qualified_Technicians__c == null)  && (strExistingQTL != ''&& strExistingQTL != null)) ||(((objWO.SVMXC__Skill_Set__c == '' || objWO.SVMXC__Skill_Set__c == null)&& (strExistingSkillSet!= '' && strExistingSkillSet!= null))))                         
                    isWOToBeupdated = true;
                                    
                else if((objWO.SVMXC__Qualified_Technicians__c != strExistingQTL) || (objWO.SVMXC__Skill_Set__c != strExistingSkillSet))
                    isWOToBeupdated = true;
            }
        
            list<SVMXC__Service_Order__c> lstWOtoUpdated = new list<SVMXC__Service_Order__c>();
                lstWOtoUpdated.addAll(mapQTLWorkOrders.values());
                System.Debug(logginglevel.warn,'mapQTLWorkOrders.values() : '+mapQTLWorkOrders.values());
                System.Debug(logginglevel.warn,'isWOToBeupdated : '+isWOToBeupdated);
            if(mapQTLWorkOrders.values() != null && mapQTLWorkOrders.values().size()>0 && isWOToBeupdated)
            {
                //CRUD
                if (!securityUtils.verifyFieldAccess(mapQTLWorkOrders.values(), COMM_SecurityUtils.Access.Updateable, true))
                    {

                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Service_Order__c'));
                    }
                    else
                    {
                        update mapQTLWorkOrders.values();   
                    }
            }
                
            response.valueMap = lstWorkOrderWrapper;
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
        
    //Method to compute Qualified Technician List
    public static map<Id, SVMXC__Service_Order__c> buildQualifiedTechnicians(list<Id> lstWorkOrderIds,list<string>lstTechId,list<skill> lstSkills,list<Eligibility>lstEligibility,List<MPXTechnicians> lstMPXTechnicans,string productExpertise,boolean isPreferredTechEnabled,boolean isproductExpertiseEnabled,boolean isSkillsEnabled, boolean isEligibilityEnabled)
    {
        //Batching of technician happening for QTL calculation, Dividing the technicians under technician constraints tab(ATS) according to batching technician list to perform MCTM calculation correctly 
        List<MPXTechnicians> lstMPXTechnicans1 = new List<MPXTechnicians>(); 
        List<MPXTechnicians> lstMPXTechnicans2 = new List<MPXTechnicians>();  
        List<MPXTechnicians> lstbatchMandatorytechs = new List<MPXTechnicians>();
        Set<String> templstTechId = new Set<String>();
        if(lstTechId != null && lstTechId.size()>0)   
            {
                templstTechId.addAll(lstTechId);    
            }
        System.debug('lstMPXTechnicans:' +lstMPXTechnicans);    
        if(lstMPXTechnicans != null && lstMPXTechnicans.size()>0)   
            {
                System.debug('lstMPXTechnicans:' +lstMPXTechnicans);
                for(MPXTechnicians objMPXs: lstMPXTechnicans)
                {
                    if(!objMPXs.strDeleted.trim().equals('Deleted')) 
                    {
                        if(objMPXs.techPreferenceType.trim().equals('Mandatory'))
                        {
                            lstbatchMandatorytechs.add(objMPXs);
                        }   
                    }       
                } 
                if(lstbatchMandatorytechs != null && lstbatchMandatorytechs.size()>0)   
                    {
                        for(MPXTechnicians batchMPX1: lstbatchMandatorytechs)
                            {
                                If(templstTechId.contains(batchMPX1.techID.trim()))  
                                lstMPXTechnicans1.add(batchMPX1);
                            }
                    }   
                else
                    {
                        for(MPXTechnicians batchMPX: lstMPXTechnicans)
                            {
                                //If(templstTechId.contains(batchMPX.techID.trim()))  
                                lstMPXTechnicans1.add(batchMPX);
                            }
                    }       
                System.debug('lstMPXTechnicans1:' +lstMPXTechnicans1);
            }
        if(lstMPXTechnicans != null && lstMPXTechnicans.size()>0)
            {   
                for(MPXTechnicians batchMPX: lstMPXTechnicans)
                    {
                        If(templstTechId.contains(batchMPX.techID.trim()))  
                            lstMPXTechnicans2.add(batchMPX);
                    }
            }   
            System.debug('lstMPXTechnicans2:' +lstMPXTechnicans2);
        templstTechId.clear();  
        DCON_Utils dcUtils = new DCON_Utils();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //SMAX_OptiMax_EngineUtils clsOMAXEngineUtils = new SMAX_OptiMax_EngineUtils();
        list<String> lstTechniciansFields = new list<String>();
        map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
        //map<Id, Id> mapPreferredTechnicians = new map<Id, Id>();
        //DNS-926/966
        map<Id, Set<Id>> mapPreferredTechnicians = new map<Id, Set<Id>>(); 
        map<Id, set<Id>> mapProductSpecialist = new map<Id, set<Id>>();
        map<Id, map<Id, list<skill>>> mapTechnicianSkill = new map<Id, map<Id, list<skill>>>();
        map<Id, list<stackRank>> mapWorkOrderStackRank = new map<Id, list<stackRank>>();
        map<Id, SVMXC__Service_Order__c> mapServiceOrder = new map<Id, SVMXC__Service_Order__c>();

        // Do we Need This ?
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX003_SET045');
        lstSettings.add('OMAX003_SET046');
        lstSettings.add('OMAX003_SET048');
        map<String, String> mapSettingValues = commSettings.SVMX_getGlobalSettingList(lstSettings);
        try
        {
           
            if(mapSettingValues.containsKey('OMAX003_SET045'))
                strSkillMatchSays = mapSettingValues.get('OMAX003_SET045').toUpperCase();
            if(mapSettingValues.containsKey('OMAX003_SET046'))
                strEligibilityMatchSays = mapSettingValues.get('OMAX003_SET046').toUpperCase();

            lstTechniciansFields = getFieldDefinition(Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap());
        
            list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
            String querySelect;
            String WhereClause = null;
            //system.debug(logginglevel.warn, 'Requested Work Order Info: ' + lstWorkOrderIds + ':' + lstWorkOrders);
            system.debug(logginglevel.warn, 'Requested lstTechId: ' + lstTechId);
            if(lstWorkOrderIds != null || lstWorkOrderIds.size() > 0)
            {
                lstWorkOrder = getWO(lstWorkOrderIds);
            }
            strExistingSkillSet = lstWorkOrder.get(0).SVMXC__Skill_Set__c;
            strExistingQTL = lstWorkOrder.get(0).SVMXC__Qualified_Technicians__c;
           //Convert the list of strings to coma seperated string
           
           //DNS-926/966          
            Set<String> lstMandatoryTechId= new Set<String>();
            Set<String> lstPreferredTechnicans = new Set<String>(); 
            Set<String> lstProhibitedTechId = new Set<String>();   
                    
            //Display only matching mandatory technicians when we have mandatory technicans in ATS technician constraint tab ..OR..
            //Display all technicians who are matching the rules when we have preferred technicians ..OR..
            //Display all technicians who are matching the rules except the prohibited technicans when we have prohibited technicians
            if(lstMPXTechnicans1 != null && lstMPXTechnicans1.size()>0)   
            {
                //Add Mandatory technicians into lstMandatoryTechId list & 
                //Prohibited technicians into lstProhibitedTechId list
                for(MPXTechnicians objMPXs: lstMPXTechnicans1)
                {
                    if(!objMPXs.strDeleted.trim().equals('Deleted')) 
                    {
                        if(objMPXs.techPreferenceType.trim().equals('Mandatory'))
                        {
                            lstMandatoryTechId.add(objMPXs.techID);
                        }   
                        else If(objMPXs.techPreferenceType.trim().equals('Prohibited'))
                        {
                            lstProhibitedTechId.add(objMPXs.techID);    
                        }
                    }       
                }       
                //Creating lstPreferredTechnicans with lstTechId includes preferred technician and excludes mandatory and prohibited technicians   
                for(Integer i = 0; i < lstTechId.size(); i++)
                {
                            
                    If(lstMandatoryTechId.contains(lstTechId.get(i)) || lstProhibitedTechId.contains(lstTechId.get(i))) 
                    {
                        continue; 
                    }
                    else
                    {
                    lstPreferredTechnicans.add(lstTechId.get(i));     
                    } 
                }
                        
            }
                
            if(lstMandatoryTechId!= null && lstMandatoryTechId.size()>0)
            {
                WhereClause = 'Id IN :lstMandatoryTechId';
            }
            else if(lstPreferredTechnicans != null && lstPreferredTechnicans.size()>0)
            {
                WhereClause = 'Id IN :lstPreferredTechnicans';
            }
            else if(lstMPXTechnicans == null || lstMPXTechnicans.size() == 0)
            {
                WhereClause = 'Id IN :lstTechId';    // Incase technician constraints tab is disabled in ATS.
            }
             
            System.debug(logginglevel.warn,'lstMandatoryTechId:' + lstMandatoryTechId);
            System.debug(logginglevel.warn,'lstPreferredTechnicans:' + lstPreferredTechnicans);
            System.debug(logginglevel.warn,'lstProhibitedTechId:' + lstProhibitedTechId);
            
            //DNS-926/966       
            // updates workorder resource record if preference type of technician is changed in technician constraints tab
            // deletes workorder resource record if technician is deleted in technician constraints tab
            List<SVMXC__Work_Order_Resource__c> lstUpdateWOResource = new List<SVMXC__Work_Order_Resource__c>();
            List<SVMXC__Work_Order_Resource__c> lstDeleteWOResource = new List<SVMXC__Work_Order_Resource__c>();
            List<SVMXC__Work_Order_Resource__c> lstInsertWOResource = new List<SVMXC__Work_Order_Resource__c>();
                
            if(lstMPXTechnicans2 != null && lstMPXTechnicans2.size()>0)
            {
                List<SVMXC__Work_Order_Resource__c> lstWOResources = DataBase.Query('Select Id,SVMXC__Group_Member__c,SVMXC__Preference_Type__c,SVMXC__Work_Order__c from SVMXC__Work_Order_Resource__c where SVMXC__Work_Order__c IN :lstWorkOrder');
            
                for(MPXTechnicians objlstMPXs: lstMPXTechnicans2)
                {
                    for(SVMXC__Work_Order_Resource__c objWOResource: lstWOResources)
                    {
                        if(objlstMPXs.techID.trim().equals(String.valueOf(objWOResource.SVMXC__Group_Member__c)) 
                            && objlstMPXs.strDeleted.trim().equals('Deleted'))
                        {
                            lstDeleteWOResource.add(objWOResource);
                        }   
                                            
                        else If(objlstMPXs.techID.trim().equals(String.valueOf(objWOResource.SVMXC__Group_Member__c)) 
                            && !(objlstMPXs.techPreferenceType.trim().equals(objWOResource.SVMXC__Preference_Type__c)) 
                            && !objlstMPXs.strDeleted.trim().equals('Deleted'))
                        {
                            objWOResource.SVMXC__Preference_Type__c = objlstMPXs.techPreferenceType;
                            lstUpdateWOResource.add(objWOResource);                                 
                        }                   
                    } 
                    //user story spr 16
                    If(objlstMPXs.strDeleted.trim().equals('Inserted')) 
                    {
                        SVMXC__Work_Order_Resource__c objWOResource1 = new SVMXC__Work_Order_Resource__c();
                        objWOResource1.SVMXC__Work_Order__c =  lstWorkOrder.get(0).Id;
                        objWOResource1.SVMXC__Group_Member__c = Id.valueOf(objlstMPXs.techID.trim());
                        objWOResource1.SVMXC__Preference_Type__c = objlstMPXs.techPreferenceType;
                        lstInsertWOResource.add(objWOResource1);    
                    }
                }
                System.debug(logginglevel.warn,'updating work order resource:' + lstUpdateWOResource);
                System.debug(logginglevel.warn,'updating work order resource:' + lstDeleteWOResource);
                
                //CRUD checking
                if(lstUpdateWOResource != null && lstUpdateWOResource.size() > 0)
                {
                    if (!securityUtils.verifyFieldAccess(lstUpdateWOResource, COMM_SecurityUtils.Access.Updateable))
                    {

                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Work_Order_Resource__c') );
                    }
                    else
                    {
                        update lstUpdateWOResource; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                }   
                if(lstDeleteWOResource != null && lstDeleteWOResource.size() > 0)
                {
                    
                    if (!securityUtils.isDeletableObject('SVMXC__Work_Order_Resource__c'))
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Work_Order_Resource__c') );
                    }
                    else
                    {
                        delete lstDeleteWOResource; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                } 
                //user story spr 16 
                if(lstInsertWOResource != null && lstInsertWOResource.size() > 0)
                {
                    if (!securityUtils.verifyFieldAccess(lstUpdateWOResource, COMM_SecurityUtils.Access.Createable))
                    {

                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Work_Order_Resource__c') );
                    }
                    else
                    {
                    insert lstInsertWOResource; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                }   
                
            }
        if(!String.isBlank(WhereClause))    
        {    
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechniciansFields); 
            //WhereClause = 'Id IN :lstTechId'; commented as we are constructing WhereClause above
            list<SVMXC__Service_Group_Members__c> lstTechnicians = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Active__c = true and '+string.escapeSingleQuotes(WhereClause));
            system.debug(logginglevel.warn, 'Requested lstTechnicians: ' + lstTechnicians);
            
            set<Id> setTechnicianIds = new set<Id>();
            map<Id, String> mapTechNames = new map<Id, String>(); 
            for(SVMXC__Service_Group_Members__c objTechnicians: lstTechnicians)
            {
                setTechnicianIds.add(objTechnicians.Id);
                mapTechNames.put(objTechnicians.Id, objTechnicians.Name);
            }
            
            system.debug(logginglevel.warn, 'Requested setTechnicianIds: ' + setTechnicianIds);
            system.debug(logginglevel.warn, 'Requested mapTechNames: ' + mapTechNames);
            // Find Technician Eligibility score
            if(isEligibilityEnabled){
                if(lstEligibility != null && lstEligibility.size()>0)
                    mapMatchedEligibilityScore = findEligibileTechnicians(lstWorkOrder, lstTechnicians,lstEligibility);
            }
         
            // Checking whether preferred Tech Id is changed.if so WO has to be updated
            /* DNS-926/966
            if(preferredTechId != null && preferredTechId != '') 
            {
                if( lstWorkOrder.get(0).SVMXC__Preferred_Technician__c != null  && (!(String.valueOf(lstWorkOrder.get(0).SVMXC__Preferred_Technician__c).substring(0,15).equals(preferredTechId.substring(0,15)))))
                {       
                    isWOToBeupdated = true;
                    
                }
                lstWorkOrder.get(0).SVMXC__Preferred_Technician__c = preferredTechId;
            }
            */
            
                  
            
            if(isPreferredTechEnabled){
            // Find Preferred Technician score
                //mapPreferredTechnicians = clsOMAXEngineUtils.buildPreferredTechnicianScore(lstWorkOrder, setTechnicianIds);
                //DNS-926/966   
                if(lstMPXTechnicans1 != null && lstMPXTechnicans1.size()>0) 
                {
                mapPreferredTechnicians = buildPreferredTechnicianScore(lstWorkOrder, setTechnicianIds, lstMPXTechnicans1);
                }
            }
            // Find Product Specialization score
            
            if(isproductExpertiseEnabled){
                mapProductSpecialist = clsOMAXEngineUtils.buildProductSpecialScore(lstWorkOrder, setTechnicianIds);
            }
            // Find Technicians Skill score
            if(isSkillsEnabled){
                if(lstSkills != null && lstSkills.size() > 0)
                    mapTechnicianSkill = buildSkillScore(lstWorkOrder, setTechnicianIds,lstSkills);
            }
        
            // Build Work Order Qualified Technician List from above scores
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                mapServiceOrder.put(objWorkOrder.Id, objWorkOrder);
                Integer intOptionalSkillCount = 0;
                if(mapWorkOrderOptionalSkillCount.containsKey(objWorkOrder.Id) && mapWorkOrderOptionalSkillCount.get(objWorkOrder.Id) != null)
                    intOptionalSkillCount = mapWorkOrderOptionalSkillCount.get(objWorkOrder.Id);
                if(mapMatchedEligibilityScore.containsKey(objWorkOrder.Id) || mapPreferredTechnicians.containsKey(objWorkOrder.Id) || mapProductSpecialist.containsKey(objWorkOrder.Id) || mapTechnicianSkill.containsKey(objWorkOrder.Id))
                {
                    set<Id> setEligibleTechnicians = new set<Id>();
                    set<Id> setProductSpecialist = new set<Id>();
                    map<Id, list<skill>> mapTechSkills = new map<Id, list<skill>>();
                    set<Id> setMatchedRequiredTechs = new set<Id>();
                    //id idPreferredTechnician;
                    Set<Id> idPreferredTechnician = new Set<Id>();
                    if(mapMatchedEligibilityScore.containsKey(objWorkOrder.Id))
                        setEligibleTechnicians = mapMatchedEligibilityScore.get(objWorkOrder.Id);
                    if(mapPreferredTechnicians.containsKey(objWorkOrder.Id))
                        idPreferredTechnician = mapPreferredTechnicians.get(objWorkOrder.Id);
                    if(mapProductSpecialist.containsKey(objWorkOrder.Id))
                        setProductSpecialist = mapProductSpecialist.get(objWorkOrder.Id);
                    if(mapTechnicianSkill.containsKey(objWorkOrder.Id))
                        mapTechSkills = mapTechnicianSkill.get(objWorkOrder.Id);
                    if(mapMandatoryMatchedSkills.containsKey(objWorkOrder.Id))
                        setMatchedRequiredTechs = mapMandatoryMatchedSkills.get(objWorkOrder.Id);
                    system.debug(logginglevel.warn, 'setMatchedRequiredTechs: ' + setMatchedRequiredTechs);
                    system.debug(logginglevel.warn, 'setEligibleTechnicians: ' + setEligibleTechnicians);
                    system.debug(logginglevel.warn, 'idPreferredTechnician: ' + idPreferredTechnician);
                    system.debug(logginglevel.warn, 'setProductSpecialist: ' + setProductSpecialist);
                    list<stackRank> lstTechnicianStackRanks = new list<stackRank>(); 
                    for(Id techId: setTechnicianIds)
                    {
                        stackRank clsStackRank = new stackRank();
                        clsStackRank.tech = techId;
                        clsStackRank.tName = mapTechNames.get(techId);
                        if(setEligibleTechnicians != null && setEligibleTechnicians.contains(techId))
                            clsStackRank.eligible = 1;
                        if(setProductSpecialist != null && setProductSpecialist.contains(techId))
                            clsStackRank.prod = 1;
                        //if(idPreferredTechnician != null && idPreferredTechnician == techId)
                        if(idPreferredTechnician != null && idPreferredTechnician.contains(techId)) 
                            clsStackRank.prefTech = 1;
                        System.debug(logginglevel.warn,'prefer technician score:' + clsStackRank.prefTech);
                        if(mapTechSkills != null && mapTechSkills.containsKey(techId))
                        {
                            integer intOptionalSkillScore = 0;
                            if(setMatchedRequiredTechs != null && setMatchedRequiredTechs.contains(techId))
                                clsStackRank.skillR = defaultSkillScore; // if has all required skill provide the the Score (from settings)
                            ReqSkillCount = countOfRequiredSkills(lstSkills);
                            if(ReqSkillCount == 0 || ReqSkillCount >0 && setMatchedRequiredTechs != null && setMatchedRequiredTechs.contains(techId))
                            {
                                for(skill objSkill: mapTechSkills.get(techId))
                                {
                                    if(!objSkill.isSkillMandatory) // collect no. of optionals skill the current Tech has
                                        intOptionalSkillScore++;
                                }
                                if(intOptionalSkillCount > 0)
                                {
                                    clsStackRank.skillO = ((decimal)(intOptionalSkillScore * defaultSkillScore)).divide(intOptionalSkillCount, 2);
                                }
                                else
                                    clsStackRank.skillO = 0;
                            }
                        }
                        lstTechnicianStackRanks.add(clsStackRank);
                    }
                    mapWorkOrderStackRank.put(objWorkOrder.Id, lstTechnicianStackRanks);
                }
                else
                {
                    mapWorkOrderStackRank.put(objWorkOrder.Id, new list<stackRank>());
                }
            }
            
            if(lstSkills != null && lstSkills.size() > 0)
            {
                ReqSkillCnt = countOfRequiredSkills(lstSkills);
            }
            mapWorkOrderStackRank = scoreProcessor(mapWorkOrderStackRank,isPreferredTechEnabled,isproductExpertiseEnabled,isSkillsEnabled, isEligibilityEnabled, lstMPXTechnicans1);
            
            //Update the Work Order with the Qualified Technician and Skill information
            for(Id workOrderId: mapWorkOrderStackRank.keySet())
            {
                if(mapWorkOrderStackRank != null && mapWorkOrderStackRank.containsKey(workOrderId) && mapWorkOrderStackRank.get(workOrderId) != null)   
                    mapServiceOrder.get(workOrderId).SVMXC__Qualified_Technicians__c = JSON.serialize(mapWorkOrderStackRank.get(workOrderId));
                else if(mapWorkOrderStackRank == null ||(mapWorkOrderStackRank != null && mapWorkOrderStackRank.size() == 0))
                    mapServiceOrder.get(workOrderId).SVMXC__Qualified_Technicians__c = '';
                if(setNonQualifiedWorkOrdersAllow.contains(workOrderId))
                    mapServiceOrder.get(workOrderId).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED_NOTECH_ALLOW;
                else if(setNonQualifiedWorkOrdersDisallow.contains(workOrderId))
                    mapServiceOrder.get(workOrderId).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED_NOTECH_DISALLOW;
                else
                    mapServiceOrder.get(workOrderId).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED;
                if(mapWorkOrderMatchedSkills != null && mapWorkOrderMatchedSkills.containsKey(workOrderId) && mapWorkOrderMatchedSkills.get(workOrderId) != null)
                    mapServiceOrder.get(workOrderId).SVMXC__Skill_Set__c = JSON.serialize(mapWorkOrderMatchedSkills.get(workOrderId));
                    //update mapServiceOrder.get(workOrderId);
                else if(mapWorkOrderMatchedSkills == null ||(mapWorkOrderMatchedSkills != null && mapWorkOrderMatchedSkills.size()==0))
                    mapServiceOrder.get(workOrderId).SVMXC__Skill_Set__c = '';    
                    
                    
            }
        }   
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }       
        return mapServiceOrder;
    }

    // Get all field in the given field definition
    public static list<String> getFieldDefinition(map<String, SObjectField> objectFieldDefinition)
    {
        list<String> objectFields = new list<String>();
        try
        {
            for(Schema.SObjectField fieldMap: objectFieldDefinition.values())
            {
                // Describe the field to get all properties
                list<SelectOption> lstWofl = new list<SelectOption>();
                Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                //CRUD
                //Accessing only updateable fields, isAccessible will retrieve readonly fields also which will create security exception when we are updating readonly fields 
                if(fieldDescribe.isAccessible())
                //if(fieldDescribe.isUpdateable())    
                    objectFields.add(fieldDescribe.getName());
            }
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return objectFields;
    }

    //Computation of Stack rank
    public static map<Id, list<stackRank>> scoreProcessor(map<Id, list<stackRank>> mapWorkOrderStackRank,boolean isPreferredTechEnabled,boolean isproductExpertiseEnabled,boolean isSkillsEnabled, boolean isEligibilityEnabled, list<MPXTechnicians> lstMPXTechnicans1)
    {
        try
            {
            // Max score based on weightage
            
            Integer maxScore = getMaxWeightagesForCriteriaSelected(isPreferredTechEnabled,isproductExpertiseEnabled,isSkillsEnabled, isEligibilityEnabled);
            System.debug('isPreferredTechEnabled: '+isPreferredTechEnabled+'  isproductExpertiseEnabled '+isproductExpertiseEnabled+'  isSkillsEnabled: '+isSkillsEnabled+'  isEligibilityEnabled '+isEligibilityEnabled);
            System.debug('maxScore: '+maxScore);
            if(maxScore == 0 ) return mapWorkOrderStackRank;
            for(Id workOrderId: mapWorkOrderStackRank.keySet())
            {
                list<stackRank> lstStackRank = mapWorkOrderStackRank.get(workOrderId);
                list<stackRank> lstProcessedStackRank = new list<stackRank>();
                Integer intEligibilityMatchedTechnicianCount = 0;
                Integer intSkillMatchedTechnicianCount = 0;
                for(stackRank objStackRank: lstStackRank)
                {
                    system.debug(logginglevel.WARN,'objStackRank: ' + objStackRank);
                    //If the technician is not having any QTL values, skip this technician
                    if((objStackRank.eligible == null || objStackRank.eligible == 0 ) && (objStackRank.prefTech == null || objStackRank.prefTech == 0 ) && (objStackRank.prod == null || objStackRank.prod == 0 ) && (objStackRank.skillO == null || objStackRank.skillO == 0 ) && (objStackRank.skillR == null || objStackRank.skillR == 0))
                        continue;
                    objStackRank.valid = true;
                    // If Expertise match is not available and configuration says DISALLOW
                    if((defaultEligibilityScore > 0 && strEligibilityMatchSays == 'DISALLOW' && (objStackRank.eligible == null || objStackRank.eligible == 0)))
                    {
                        objStackRank.valid = false;
                    }
                    else
                        intEligibilityMatchedTechnicianCount++;
                    // If Skill match is not available and configuration says DISALLOW
                    if((defaultSkillScore > 0 && strSkillMatchSays == 'DISALLOW' && (objStackRank.skillR == null || objStackRank.skillR == 0)))
                    {
                        objStackRank.valid = false;
                    }
                    else
                        intSkillMatchedTechnicianCount++;
                        
                    // Update corresponding scores based on default property
                    if(objStackRank.eligible == null || defaultEligibilityScore == 0)
                        objStackRank.eligible = 0;
                    else if(objStackRank.eligible == 1)
                        objStackRank.eligible = defaultEligibilityScore;
                        
                    if(defaultSkillScore == 0)
                    {
                        objStackRank.skillR = 0;
                        objStackRank.skillO = 0;
                    }
                    if(objStackRank.prod == null || defaultProductSpecializationScore == 0)
                        objStackRank.prod = 0;
                    else if(objStackRank.prod == 1)
                        objStackRank.prod = defaultProductSpecializationScore;
                    if(objStackRank.prefTech == null || defaultPreferredTechnicianScore == 0)
                        objStackRank.prefTech = 0;
                    else if(objStackRank.prefTech == 1)
                        objStackRank.prefTech = defaultPreferredTechnicianScore;
                        
                    if(objStackRank.skillO == null)
                        objStackRank.skillO = 0;
                    if(objStackRank.skillR == null)
                        objStackRank.skillR = 0;
                    //Populate Stack Rank

                    double totalScore ;
                    double dblStackRnk ;
                    
                    if(optionalSkillCount >0)
                    totalScore= objStackRank.prefTech + objStackRank.prod + objStackRank.skillO + objStackRank.skillR + objStackRank.eligible;
                    else
                    totalScore = objStackRank.prefTech + objStackRank.prod + objStackRank.skillR + objStackRank.eligible;
                                    
                    dblStackRnk = ((decimal)(totalScore * 10)).divide(maxScore, 2);
                    objStackRank.stackRank = integer.valueOf(dblStackRnk.round());
                    
                      //DNS-926/966
                    //When Skill tab is enabled and we have 'Mandatory' type technician at 'Technician Constraint' tab and not satisfying the 'Required Skills' so it is not satisfying hard constraints functionality so we are overriding stackrank score with ZERO in below code.  
                    System.debug(logginglevel.warn,'ReqSkillCnt: '+ReqSkillCnt);
                    /*
                    if(isSkillsEnabled && ReqSkillCnt> 0 && (objStackRank.skillR == null || objStackRank.skillR == 0) && lstMPXTechnicans1 != null && lstMPXTechnicans1.size()>0)
                    {
                        for(MPXTechnicians objlstMPXs: lstMPXTechnicans1) 
                        {
                            if(objlstMPXs.techID.trim().equals(String.valueOf(objStackRank.tech)) 
                            && objlstMPXs.techPreferenceType.trim().equals('Mandatory') && !objlstMPXs.strDeleted.trim().equals('Deleted'))
                            {
                                objStackRank.stackRank = 0;
                                dblStackRnk = 0;
                            }
                        }
                    
                    }*/
                    //032129 - commented above code, Since Required skills also hard constraint, technician of any type(like mandatory or preferred or prohibited) who is not having required skills are not going to display on gantt since technician score is zero
                    if(isSkillsEnabled && ReqSkillCnt> 0 && (objStackRank.skillR == null || objStackRank.skillR == 0))
                    {
                        objStackRank.stackRank = 0;
                        dblStackRnk = 0;
                    }
                    
                    if(objStackRank.stackRank == 0)
                        continue;
                    lstProcessedStackRank.add(objStackRank);
                    System.debug(logginglevel.warn,'totalScore: '+totalScore);
                    System.debug(logginglevel.warn,'maxScore: '+maxScore);
                    System.debug(logginglevel.warn,'dblStackRnk: '+dblStackRnk);
                }
                mapWorkOrderStackRank.put(workOrderId,lstProcessedStackRank);
                if(intEligibilityMatchedTechnicianCount == 0)
                {
                    if(strEligibilityMatchSays == 'ALLOW')
                    {
                        if(intSkillMatchedTechnicianCount == 0 && strSkillMatchSays == 'DISALLOW')
                            setNonQualifiedWorkOrdersDisallow.add(workOrderId);
                        else
                            setNonQualifiedWorkOrdersAllow.add(workOrderId);
                    }
                    if(strEligibilityMatchSays == 'DISALLOW')
                        setNonQualifiedWorkOrdersDisallow.add(workOrderId);
                }
                else if(intSkillMatchedTechnicianCount == 0)
                {
                    if(strSkillMatchSays == 'ALLOW')
                    {
                        setNonQualifiedWorkOrdersAllow.add(workOrderId);
                    }
                    if(strSkillMatchSays == 'DISALLOW')
                        setNonQualifiedWorkOrdersDisallow.add(workOrderId);
                }
            }
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return mapWorkOrderStackRank;
    }
    //TO Do- Change signature
    /* // external webservice call only to compute skills for the Work Order/s
    WebService static map<Id, map<Id, list<skill>>> computeSkill_WS(list<SVMXC__Service_Order__c> lstWorkOrder, set<Id> setTechnicianIds,list<skill> lstSkills)
    {
        return buildSkillScore(lstWorkOrder,setTechnicianIds,lstSkills);
    }
     *///Method to Compute skill set and Finds technicians eligibility score for each work order and technician
    WebService static list<SVMXMap> buildSkillScore_WS(Skill_Request SkillReq)
    {
        map<Id, map<Id, list<skill>>> mapSkill = new map<Id, map<Id, list<skill>>>(); 
        list<SVMXMap> mapSkillSet = new list<SVMXMap>();
        set<Id> setTechnicianIds = new set<Id> ();
        setTechnicianIds.addAll(SkillReq.lstTech);
        mapSkill = buildSkillScore(SkillReq.lstWorkOrder, setTechnicianIds , SkillReq.lstSkills);
       system.debug(logginglevel.WARN,'mapSkill: ' + mapSkill);
        for(Id WOId :mapSkill.keySet())
        {           
            SVMXMap objSVMXMap = new SVMXMap();
            list<SVMXMap> valMap = new list<SVMXMap>();
            objSVMXMap.key = WOId;
            for(Id SkillId :mapSkill.get(WOId).keySet())
            {           
                SVMXMap objSVMXValMap = new SVMXMap();
                objSVMXValMap.key = SkillId;
                objSVMXValMap.lstskill =mapSkill.get(WOId).get(SkillId);
                valMap.add(objSVMXValMap);
            }
            objSVMXMap.valueMap = valMap;
            mapSkillSet.add(objSVMXMap);
        }
        return mapSkillSet;
    }
    
    //Name is misleading, no calculation happens here
    public static map<Id, map<Id, list<skill>>> buildSkillScore(list<SVMXC__Service_Order__c> lstWorkOrder, set<Id> setTechnicianIds,list<skill> lstSkills)
    {
        map<Id, map<Id, list<skill>>> mapSkillMatch = new map<Id, map<Id, list<skill>>>();
        map<Id, SVMXC__Service_Order__c> mapWorkOrders = new map<Id, SVMXC__Service_Order__c>();        
        set<Id> setRequiredSkills = new set<Id>();
        try
        {
            for(skill objskill:lstSkills)
                setRequiredSkills.add(objskill.skillId); //setRequiredSkill name is confusing - it contains all the optional+required skills
                
            list<SVMXC__Service_Group_Skills__c> lstExpertise = [Select SVMXC__Skill__c, SVMXC__Skill_Level__c, SVMXC__Group_Member__c from SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__c IN :setTechnicianIds and SVMXC__Skill__c IN: setRequiredSkills and SVMXC__Is_Applicable__c = 'TRUE'];
            map<Id, map<Id, Integer>> mapTechnicianSkillScore = new map<Id, map<Id, Integer>>();
            for(SVMXC__Service_Group_Skills__c objExperts: lstExpertise)
            {
                map<Id, Integer> mapSkillScore = new map<Id, Integer>();
                if(!mapTechnicianSkillScore.containsKey(objExperts.SVMXC__Group_Member__c))
                    mapTechnicianSkillScore.put(objExperts.SVMXC__Group_Member__c, null);
                if(mapTechnicianSkillScore.get(objExperts.SVMXC__Group_Member__c) != null)
                    mapSkillScore = mapTechnicianSkillScore.get(objExperts.SVMXC__Group_Member__c);
                if(objExperts.SVMXC__Skill_Level__c == null)
                    objExperts.SVMXC__Skill_Level__c = 0;
                mapSkillScore.put(objExperts.SVMXC__Skill__c, (objExperts.SVMXC__Skill_Level__c).intValue());
                mapTechnicianSkillScore.put(objExperts.SVMXC__Group_Member__c, mapSkillScore);
            }
            
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                map<Id, list<skill>> mapTechnicianMatchedSkillScores = new map<Id, list<skill>>();
                Integer expectedOptionalSkillCount = 0;                
                    mapWorkOrderMatchedSkills.put(objWorkOrder.Id, lstSkills);
                    set<Id> setMatchedTechnicianIds = new set<Id>();
                    for(Id idTechnician: setTechnicianIds)
                    {
                        if(!mapTechnicianSkillScore.containsKey(idTechnician))
                            continue;
                        Boolean isOneMandatorySkillMatched = false;
                        Boolean isAllMandatorySkillsMatched = true;
                        map<Id, Integer> mapTechniciansSkills = new map<Id, Integer>();
                        list<skill> lstMatchedTechnicianRequiredSkills = new list<skill>();
                        list<skill> lstMatchedTechnicianOptionalSkills = new list<skill>();
                        //Get technicians skills
                        mapTechniciansSkills = mapTechnicianSkillScore.get(idTechnician);
                        if(mapTechniciansSkills == null || lstSkills == null)
                            continue;
                        for(skill objSkill: lstSkills)
                        {
                            system.debug(logginglevel.warn, 'TEST LOG: objSkill: ' + objSkill);
                            //If any of mandatory skill is not available
                            if((!isAllMandatorySkillsMatched && objSkill.isSkillMandatory) || (objSkill.isSkillMandatory && !mapTechniciansSkills.containsKey(objSkill.skillId)))
                            {
                                isAllMandatorySkillsMatched = false;
                                continue;
                            }
                            if(mapTechniciansSkills.containsKey(objSkill.skillId))
                            {
                                system.debug(logginglevel.warn, 'TEST LOG: mapTechniciansSkills: ' + objSkill.skillLevel + '<:' + mapTechniciansSkills.get(objSkill.skillId));
                                if(objSkill.isSkillMandatory && (objSkill.skillLevel <= mapTechniciansSkills.get(objSkill.skillId)))
                                // The skill level is getting matched only if Tech's skill level is in higher side? 
                                {
                                    lstMatchedTechnicianRequiredSkills.add(new skill(objSkill.skillId, objSkill.skillName, objSkill.isSkillMandatory, mapTechniciansSkills.get(objSkill.skillId)));
                                    isOneMandatorySkillMatched = true;//atleastOneMatched -  Interesting to see how it will be used: PavitrA
                                }
                                else if(!objSkill.isSkillMandatory)
                                    lstMatchedTechnicianOptionalSkills.add(new skill(objSkill.skillId, objSkill.skillName, objSkill.isSkillMandatory, mapTechniciansSkills.get(objSkill.skillId)));
                                else
                                {
                                    isAllMandatorySkillsMatched = false;
                                    continue;
                                }
                            }
                        }
                        if(isAllMandatorySkillsMatched && isOneMandatorySkillMatched)
                            setMatchedTechnicianIds.add(idTechnician);
                        lstMatchedTechnicianOptionalSkills.addAll(lstMatchedTechnicianRequiredSkills);
                        mapTechnicianMatchedSkillScores.put(idTechnician, lstMatchedTechnicianOptionalSkills);
                    }
                    
                    mapMandatoryMatchedSkills.put(objWorkOrder.Id, setMatchedTechnicianIds);
                    mapSkillMatch.put(objWorkOrder.Id, mapTechnicianMatchedSkillScores);
                
                if(lstSkills != null)
                for(skill objSkill: lstSkills)
                {
                    if(!objSkill.isSkillMandatory)
                    {
                        expectedOptionalSkillCount++;
                        optionalSkillCount ++;
                    }
                }
                mapWorkOrderOptionalSkillCount.put(objWorkOrder.Id, expectedOptionalSkillCount);
            }
            system.debug(logginglevel.WARN,'mapWorkOrderOptionalSkillCount: ' + mapWorkOrderOptionalSkillCount);
            system.debug(logginglevel.WARN,'mapWorkOrderMatchedSkills: ' + mapWorkOrderMatchedSkills);
            system.debug(logginglevel.WARN,'mapSkillMatch: ' + mapSkillMatch);
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return mapSkillMatch; // its map of map < WOID, <TechID, <listSkillDetails>>>
    }
    //Finds technicians eligibility score for each work order and technician
    public static map<Id, set<Id>> findEligibileTechnicians(list<SVMXC__Service_Order__c> lstWorkOrder, list<SVMXC__Service_Group_Members__c> lstTechnicians,list<Eligibility>lstEligibility)
    {
        map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEligibilityMatchExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        // Get the list of all valid Expertise Match rules
        map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
       
        try
        {
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                set<Id> mapTechnicianScore = new set<Id>();
                
                for(SVMXC__Service_Group_Members__c objTechnicians: lstTechnicians)
                {
                    //Method returns true if the tech matches Eligibility criteria
                    Boolean isTechnicianMatched = matchTechnicianEligibility(objTechnicians, objWorkOrder, lstEligibility, '');
                    if(isTechnicianMatched)
                    {
                        mapTechnicianScore.add(objTechnicians.Id);
                    }
                }
                if(mapTechnicianScore.size() > 0)
                    mapMatchedEligibilityScore.put(objWorkOrder.Id, mapTechnicianScore);
            }
            system.debug(logginglevel.warn, 'mapMatchedEligibilityScore ' + mapMatchedEligibilityScore);
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return mapMatchedEligibilityScore;
    }


    // Apply technician expression and find whether the technician is elligible to work on the work order
    public static boolean matchTechnicianEligibility(SVMXC__Service_Group_Members__c objTechnician, SVMXC__Service_Order__c objWorkOrder, list<Eligibility>lstEligibility, String strAdvanceExpression)
    {
        boolean response = false;
        list<SVMXC__ServiceMax_Config_Data__c> eligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
        try
        {
            eligibilities = getEligibilityExp(lstEligibility, objWorkOrder);
            //Utility returns true if the tech matches Eligibility criteria
            response = clsUtils4.SVMX_ExpressionParsing(objTechnician, eligibilities, strAdvanceExpression);
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        if(response == null) response = false;
        return response;
    }
    //Method to build Eligibiity Expression by using list of Eligibility wrapper
    public static list<SVMXC__ServiceMax_Config_Data__c> getEligibilityExp(list<Eligibility>lstEligibility,SVMXC__Service_Order__c objWorkOrder)
    {
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        // Defect no: 21785
        objfieldMap = SVMXC__Service_Group_Members__c.SObjectType.getDescribe().fields.getMap(); 
        //objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap(); 
        list<SVMXC__ServiceMax_Config_Data__c> lstEligibilityCriteria= new list<SVMXC__ServiceMax_Config_Data__c>();
        integer intSeq =1;
        try
        {
            //Building Config data using Eligibility wrapper
            for(Eligibility exp: lstEligibility)
            {
                SVMXC__ServiceMax_Config_Data__c expression = new SVMXC__ServiceMax_Config_Data__c();
                if(exp.operator != null)
                    expression.SVMXC__Field_Name__c = exp.techField;
                if(exp.operator != null)
                    expression.SVMXC__Operator__c = exp.operator;
                if(exp.value != null)
                    expression.SVMXC__Display_Value__c = exp.value;
                if(exp.WOfield != null)
                    expression.SVMXC__Target_Field_Name__c = exp.WOfield;
                expression.SVMXC__Sequence__c = intSeq++;
                for (String fieldKey : objfieldMap.keySet()) 
                {
                    Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                    if(f.getName() == expression.SVMXC__Field_Name__c)
                    {
                        expression.SVMXC__Display_Type__c = f.getType().name();
                    }
                }
                if(expression.SVMXC__Operator__c != null)
                {
                    expression.SVMXC__Operand__c = expression.SVMXC__Display_Value__c;
                    if(expression.SVMXC__Target_Field_Name__c != null && objWorkOrder.get(expression.SVMXC__Target_Field_Name__c) != null)
                    {
                        expression.SVMXC__Operand__c = String.valueOf(objWorkOrder.get(expression.SVMXC__Target_Field_Name__c));
                        
                    }
                }
                //Defect No. 028999
                if(expression.SVMXC__Display_Type__c.equalsIgnoreCase('double'))
                    if(expression.SVMXC__Operand__c == null)
                        expression.SVMXC__Operand__c = String.valueOf(0);
                lstEligibilityCriteria.add(expression);     
            }
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }       
        return lstEligibilityCriteria;
    }
    //Get Product Expertise, Tech Eligibility Rules for a WO
    WebService static MCTMDetails getMCTMDetails(list<string> lstWorkorderIds)
    {
        MCTMDetails objMCTMDetails = new MCTMDetails();
        list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        //list<Id> lstWorkorderIds = new list<Id>();
        try
        {
            
            System.debug(logginglevel.warn,'lstWorkorderIds '+lstWorkorderIds);
            if(lstWorkorderIds != null || lstWorkorderIds.size() > 0)
            {
                lstWorkOrder = getWO(lstWorkOrderIds);
            }       
            System.debug(logginglevel.warn,'lstWorkOrder '+lstWorkOrder);
            
            objMCTMDetails.productExpertise = lstWorkOrder.get(0).SVMXC__Product__c;
            objMCTMDetails.lstskill.addAll(getSkillsetFromWO(lstWorkOrder));
            objMCTMDetails.lstEligibility.addAll(getMatchingTechnicianEligibilityRulesforWO(lstWorkOrder));
            objMCTMDetails.lstCandidatePrefTechId.addAll(getAllCandidateTechDetails(lstWorkOrder));
            list<String> lstEvntHov = new list<String>();
            lstEvntHov = DCON_Work_Order_WS.DCON_Retrieve_Work_Order_EventHover(lstWorkOrderIds.get(0));
            if(lstEvntHov.size()>0)
                objMCTMDetails.lstEventHover.addAll(lstEvntHov);
            System.debug(logginglevel.warn,'objMCTMDetails '+objMCTMDetails);
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return objMCTMDetails;
    
    }
    
    //Get List of Tech Eligibility Rules for a WO
    public static list<Eligibility> getMatchingTechnicianEligibilityRulesforWO(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        list<Eligibility> lstEligibility = new list<Eligibility>();
        map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEligibilityMatchExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        // Get the list of all valid Expertise Match rules
        map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        try
        {
            mapOMaxEligibilityRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Tech Eligibility' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
            
            //get the corresponding Config data (entry criteria) of the process_object list: mapOMaxEligibilityRules
            mapOMaxEligibilityRulesExpression = clsOMAXEngineUtils.getWorkOrderExpression(mapOMaxEligibilityRules,  'Tech_Eligibility');
            system.debug(logginglevel.WARN, 'Technician Eligibility Match: Rule -> Expression ' + mapOMaxEligibilityRules + mapWorkOrderRule.size());
            
            
            mapWorkOrderRule = clsOMAXEngineUtils.parseWorkOrderExpressions(lstWorkOrder, mapOMaxEligibilityRules, mapOMaxEligibilityRulesExpression);
            system.debug(logginglevel.WARN, 'Technician Eligibility Match: Work Order -> Rules: ' + mapWorkOrderRule);
            
            list<SVMXC__ServiceMax_Config_Data__c> eligibilities = [Select Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Tech_Match' and SVMXC__Expression_Rule__c IN :mapWorkOrderRule.values() order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Config_Data__c confData: eligibilities)
            {
                list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
                if(!mapEligibilityMatchExpressions.containsKey(confData.SVMXC__Expression_Rule__c))
                    mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, null);
                if(mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c) != null)
                    lstEligibilities = mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c);
                lstEligibilities.add(confData);
                mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, lstEligibilities);
            }
            
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                set<Id> mapTechnicianScore = new set<Id>();
                list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
                //Getting eligibility for this work order
                if(mapEligibilityMatchExpressions.containsKey(mapWorkOrderRule.get(objWorkOrder.Id)))
                    lstEligibilities = mapEligibilityMatchExpressions.get(mapWorkOrderRule.get(objWorkOrder.Id));
                else//Go to next work order, there is no expression to match for tech eligibility
                    continue;
                
                for(SVMXC__ServiceMax_Config_Data__c confElig:lstEligibilities)
                {
                    Eligibility objElig = new Eligibility();
                    objElig.techField = confElig.SVMXC__Field_Name__c;
                    objElig.operator = confElig.SVMXC__Operator__c;
                    objElig.WOfield = confElig.SVMXC__Target_Field_Name__c;
                    objElig.value = confElig.SVMXC__Display_Value__c;
                    lstEligibility.add(objElig);
                }
            }
            
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return lstEligibility;
    }
    //Get All ative Skills 
    WebService static list<skill> getSkillDetails()
    {
    
        List<SVMXC__Skill__c > lstSkillobj = new List<SVMXC__Skill__c >();
        lstSkillobj = [SELECT Id,Name FROM SVMXC__Skill__c where name != null and SVMXC__Active__c = true];
        list<skill> lstSkilldetails = new list<skill> ();
        try
        {
            for(SVMXC__Skill__c obj :lstSkillobj)
            {
                skill objskill = new skill();
                objskill.skillId = obj.id;
                objskill.skillName = obj.Name;
                lstSkilldetails.add(objskill);
            }
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return lstSkilldetails;
    }
    //Retrieve WO record for the given WO Id
    public static list<SVMXC__Service_Order__c> getWO(list<Id> lstWorkOrderIds)
    {
        list<String> lstWorkOrderFields = new list<String>();
        list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        try
        {
            if(lstWorkOrderIds != null && lstWorkOrderIds.size() > 0)
            {
                lstWorkOrderFields = getFieldDefinition(Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());
                // Get all Work Orders that needs to be preprocessed
                string querySelect = utils.SVMX_getFieldNamesFromList(lstWorkOrderFields); //Convert the list of strings to coma seperated string
                querySelect = querySelect+',SVMXC__Company__r.SVMXC__Preferred_Technician__c' + ',SVMXC__Component__r.SVMXC__Preferred_Technician__c';
                string WhereClause = 'Id IN :lstWorkOrderIds';
                lstWorkOrder = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Order__c WHERE '+string.escapeSingleQuotes(WhereClause));
            }
            
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return lstWorkOrder;
    }
    /*
    public static list<SVMXMap> getAllCandidateTechDetails(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        list<SVMXMap> ObjNameTechId = new list<SVMXMap>();
        try
        {
            if(lstWorkOrder != null && lstWorkOrder.size() >0 && (lstWorkOrder.get(0).SVMXC__Company__c != null || lstWorkOrder.get(0).SVMXC__Component__c != null || lstWorkOrder.get(0).SVMXC__Preferred_Technician__c != null))
            {
                // sObject types to describe                    
                String[] types = new String[]{'Account','SVMXC__Installed_Product__c','SVMXC__Service_Order__c'};
                map<string, string> mapobjectApiLabel = new map<string, string>();
                // Make the describe call
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
                // For each returned result, get some info
                for(Schema.DescribeSobjectResult res : results)
                {
                    mapobjectApiLabel.put(res.getName(),res.getLabel());        
                }
                
                SVMXMap objSVMXMap1 = new SVMXMap();
                SVMXMap objSVMXMap2 = new SVMXMap();
                SVMXMap objSVMXMap3 = new SVMXMap();
                objSVMXMap1.key = mapobjectApiLabel.get('SVMXC__Service_Order__c');
                objSVMXMap1.value = lstWorkOrder.get(0).SVMXC__Preferred_Technician__c;
                objSVMXMap2.key = mapobjectApiLabel.get('Account');
                objSVMXMap2.value = lstWorkOrder.get(0).SVMXC__Company__r.SVMXC__Preferred_Technician__c;
                objSVMXMap3.key = mapobjectApiLabel.get('SVMXC__Installed_Product__c');
                objSVMXMap3.value = lstWorkOrder.get(0).SVMXC__Component__r.SVMXC__Preferred_Technician__c;
                ObjNameTechId.add(objSVMXMap1);
                ObjNameTechId.add(objSVMXMap2);
                ObjNameTechId.add(objSVMXMap3);
                
            }
            
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return ObjNameTechId;
    }
    */
    //DNS-926/966
    //All workorder resource for workorder will be send to client to display on technician constraints tab. If preferred technician of workorder is not in workorder resource, that technician will be inserted into workorder resource of workorder. 
    public static list<SVMXMap> getAllCandidateTechDetails(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        list<SVMXMap> ObjNameTechId = new list<SVMXMap>();
        Boolean isWOPrefTechMatchWORes = false;
        try
        {
            if(lstWorkOrder != null && lstWorkOrder.size() >0)
            {
                List<SVMXC__Work_Order_Resource__c> lstWOResources = DataBase.Query('Select Id,SVMXC__Group_Member__c,SVMXC__Preference_Type__c,SVMXC__Work_Order__c from SVMXC__Work_Order_Resource__c where SVMXC__Work_Order__c IN :lstWorkOrder');
                
                for(SVMXC__Work_Order_Resource__c objWOResource: lstWOResources)
                {
                    SVMXMap objSVMXMap1 = new SVMXMap();
                    objSVMXMap1.key = objWOResource.SVMXC__Group_Member__c;
                    objSVMXMap1.value = objWOResource.SVMXC__Preference_Type__c;
                    ObjNameTechId.add(objSVMXMap1); 
                    If(lstWorkOrder.get(0).SVMXC__Preferred_Technician__c != null && String.valueOf(lstWorkOrder.get(0).SVMXC__Preferred_Technician__c).substring(0,15).equals(String.valueOf(objWOResource.SVMXC__Group_Member__c).substring(0,15)))
                    {
                        isWOPrefTechMatchWORes = true; 
                    }
                }
                If(!isWOPrefTechMatchWORes && lstWorkOrder.get(0).SVMXC__Preferred_Technician__c != null)
                {
                    SVMXC__Work_Order_Resource__c insertWORes = new SVMXC__Work_Order_Resource__c();
                    insertWORes.SVMXC__Work_Order__c = lstWorkOrder.get(0).Id;
                    insertWORes.SVMXC__Group_Member__c  = lstWorkOrder.get(0).SVMXC__Preferred_Technician__c;
                    insertWORes.SVMXC__Preference_Type__c = 'Preferred';
                    //CRUD checking
                    If(!securityUtils.verifyFieldAccess(insertWORes, COMM_SecurityUtils.Access.Createable))
                        {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Work_Order_Resource__c') );  
                        }
                        else
                        {
                            insert insertWORes; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                    SVMXMap objSVMXMap1 = new SVMXMap();
                    objSVMXMap1.key = lstWorkOrder.get(0).SVMXC__Preferred_Technician__c;
                    objSVMXMap1.value = 'Preferred';
                    ObjNameTechId.add(objSVMXMap1); 
                    
                }
            }   
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        
        System.debug('Result:' + ObjNameTechId);
        return ObjNameTechId;
    }
    public static void populateWeightageToCompute()
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        try            
        {
            map<string, Map<String, String>> mapSetting = new map<string, Map<String, String>>();
            list<string> lstSetting = new list<string>();
            lstSetting.add('OMAX003');
            mapSetting = commSettings.SVMX_getSettingList(lstSetting);
            map<String, String> svmxSettingList = new Map<String, String>();
            if(mapSetting.containsKey('OMAX003'))
                svmxSettingList = mapSetting.get('OMAX003');
            if(svmxSettingList.containsKey('SET042') && svmxSettingList.get('SET042') != null)      
                defaultEligibilityScore = Integer.valueOf(svmxSettingList.get('SET042'));
                
            if(svmxSettingList.containsKey('SET043') && svmxSettingList.get('SET043') != null)
                defaultProductSpecializationScore = Integer.valueOf(svmxSettingList.get('SET043')); 
                
            if(svmxSettingList.containsKey('SET044') && svmxSettingList.get('SET044') != null)
                defaultPreferredTechnicianScore = Integer.valueOf(svmxSettingList.get('SET044')); 
                
                
            if(svmxSettingList.containsKey('SET047') && svmxSettingList.get('SET047') != null)
                defaultSkillScore = Integer.valueOf(svmxSettingList.get('SET047'));
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }
    
    //Get List of Skill matching rules form a Skill Set of WO
    public static list<skill> getSkillsetFromWO(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        system.debug('list<SVMXC__Service_Order__c> = ' + lstWorkOrder);
        string strSkillSet = '';
        list<skill> wrpSkillValues = new list<skill>();
        try
        {
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                strSkillSet = objWorkOrder.SVMXC__Skill_Set__c;
            }
            
            if(strSkillSet != null && strSkillSet !='') 
            {
                wrpSkillValues = (List<skill>)JSON.deserialize(strSkillSet, List<skill>.class);
            }  
        }           
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return wrpSkillValues;
    }

    // The below block of code is commented for time being as it used to 
    // the get the matching Skill set of WO and passing it to client for display
    /* //Get List of Skill matching rules for a WO
    public static list<skill> getSkillsetFromWO(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        
        string strSkillSet = '';
        list<skill> wrpSkillValues = new list<skill>();
        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
        {
            strSkillSet = objWorkOrder.SVMXC__Skill_Set__c;
        }
        
        if(strSkillSet == null || strSkillSet =='') 
        {
            lstWorkOrder = computeSkillSet(lstWorkOrder); 
            //if(lstWorkOrder.size()>0)
            //update lstWorkOrder;
            strSkillSet = lstWorkOrder.get(0).SVMXC__Skill_Set__c;
        }

        wrpSkillValues = (List<skill>)JSON.deserialize(strSkillSet, List<skill>.class); 
        return wrpSkillValues;
    }
    //Compute Skill Set Using Skill matching rules for a WO
    public static list<SVMXC__Service_Order__c> computeSkillSet(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        map<Id, SVMXC__Service_Order__c> mapWorkOrders = new map<Id, SVMXC__Service_Order__c>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxAllSkillMatchRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxSkillMatchRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Processes__c>> mapOMaxSkillMatchRulesChildrens = new map<Id, list<SVMXC__ServiceMax_Processes__c>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxAllSkillMatchRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxSkillMatchRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
        map<Id, list<skill>> mapRequiredSkills = new map<Id, list<skill>>();
        list<Id> lstAllMatchedRules = new list<Id>();
        map<Id, Id> mapChildRuleToParentRule = new map<Id, Id>();
        list<skill> wrpSkillValues = new list<skill>();
        
        mapOMaxAllSkillMatchRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c, SVMXC__Node_Parent__c, SVMXC__Primary_Consolidation_Rule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Skill Matching' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
        
        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder){
            mapWorkOrders.put(objWorkOrder.Id, objWorkOrder);
        }
        
        for(SVMXC__ServiceMax_Processes__c rule: mapOMaxAllSkillMatchRules.values()){
            if(rule.SVMXC__Node_Parent__c == null)
                mapOMaxSkillMatchRules.put(rule.Id, rule);
            else{
                list<SVMXC__ServiceMax_Processes__c> lstRules = new list<SVMXC__ServiceMax_Processes__c>();
                if(!mapOMaxSkillMatchRulesChildrens.containsKey(rule.SVMXC__Node_Parent__c))
                    mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, null);
                if(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c) != null)
                    lstRules.addAll(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c));
                lstRules.add(rule);
                mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, lstRules);
            }
        }
        
        mapOMaxAllSkillMatchRulesExpression = clsOMAXEngineUtils.getWorkOrderExpression(mapOMaxAllSkillMatchRules,  'Skill_Eligibility');
        for(Id ruleId: mapOMaxSkillMatchRules.keySet()){
            mapOMaxSkillMatchRulesExpression.put(ruleId, mapOMaxAllSkillMatchRulesExpression.get(ruleId));
        }
        
        system.debug(logginglevel.WARN,'lstWorkOrder: ' + lstWorkOrder);
        system.debug(logginglevel.WARN,'mapOMaxSkillMatchRulesExpression: ' + mapOMaxSkillMatchRulesExpression);
        // Get the list of all valid Skill Match rules
        mapWorkOrderRule = clsOMAXEngineUtils.parseWorkOrderExpressions(lstWorkOrder, mapOMaxSkillMatchRules, mapOMaxSkillMatchRulesExpression);
        
        //For each Work Order Matched, get all child Rules and Find the Expression Match
        map<Id, set<Id>> mapMatchedWorkOrderSkills = new map<Id, set<Id>>();
        for(Id workOrderId: mapWorkOrderRule.keySet()){
            set<Id> setMatchedRules = new set<Id>();
            Id parentRule = mapWorkOrderRule.get(workOrderId);
            if(mapOMaxSkillMatchRulesChildrens.containsKey(parentRule) && mapOMaxSkillMatchRulesChildrens.get(parentRule) != null){
                list<SVMXC__ServiceMax_Processes__c> lstChildRules = mapOMaxSkillMatchRulesChildrens.get(parentRule);
                map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxSkillMatchRules2 = new map<Id, SVMXC__ServiceMax_Processes__c>();
                map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxSkillMatchRulesExpression2 = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
                for(SVMXC__ServiceMax_Processes__c childRule: lstChildRules){
                    mapOMaxSkillMatchRules2.put(childRule.Id, childRule);
                    if(mapOMaxAllSkillMatchRulesExpression.containsKey(childRule.Id))
                        mapOMaxSkillMatchRulesExpression2.put(childRule.Id, mapOMaxAllSkillMatchRulesExpression.get(childRule.Id));
                }
                setMatchedRules = clsUtils4.SVMX_GetAllMatchingExpression((SObject)mapWorkOrders.get(workOrderId), mapOMaxSkillMatchRulesExpression2, mapOMaxSkillMatchRules2);
                system.debug(logginglevel.WARN,'Parent Rule: ' + parentRule + 'Chile Rules: ' + mapOMaxSkillMatchRules2.keySet());
                system.debug(logginglevel.WARN,'setMatchedRules: ' + setMatchedRules);
                for(Id matchedRuleId: setMatchedRules)
                {
                    mapChildRuleToParentRule.put(matchedRuleId, parentRule);
                }
                if(setMatchedRules != null)
                {
                    lstAllMatchedRules.addAll(setMatchedRules);
                }
            }
            //Add all matched skill matching rule Id for work order
            setMatchedRules.add(parentRule);
            mapMatchedWorkOrderSkills.put(workOrderId, setMatchedRules);
        }
        lstAllMatchedRules.addAll(mapWorkOrderRule.values());
        
        system.debug(logginglevel.WARN,'lstAllMatchedRules: ' + lstAllMatchedRules);
        list<SVMXC__ServiceMax_Config_Data__c> lstSkillMatches = [Select SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Minimum_Level__c, SVMXC__Required__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Applicable Skills' and SVMXC__Expression_Rule__c IN: lstAllMatchedRules];
        set<Id> setRequiredSkills = new set<Id>();
        
        for(SVMXC__ServiceMax_Config_Data__c skillMatches: lstSkillMatches)
        {
            //list<skill> wrpSkillValues = new list<skill>();
            //skillMatches.SVMXC__Expression_Rule__c = mapChildRuleToParentRule.containsKey(skillMatches.SVMXC__Expression_Rule__c) ? mapChildRuleToParentRule.get(skillMatches.SVMXC__Expression_Rule__c) : skillMatches.SVMXC__Expression_Rule__c;
            if(!mapRequiredSkills.containsKey(skillMatches.SVMXC__Expression_Rule__c))
                mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, null);
            
            if(mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c) != null)
                wrpSkillValues = mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c);
            if(skillMatches.SVMXC__Minimum_Level__c == null)
                skillMatches.SVMXC__Minimum_Level__c = 0;
            wrpSkillValues.add(new skill(skillMatches.SVMXC__Skill__c, skillMatches.SVMXC__Skill__r.Name, skillMatches.SVMXC__Required__c, (skillMatches.SVMXC__Minimum_Level__c).intValue()));
            //setRequiredSkills.add(skillMatches.SVMXC__Skill__c);
           // mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, wrpSkillValues);
            
        }
        lstWorkOrder.get(0).SVMXC__Skill_Set__c = JSON.serialize(wrpSkillValues);
        return lstWorkOrder;
    } */
    //Count of required skills
    public static integer countOfRequiredSkills(list<skill> lstSkills)
    {
        integer countOfReqSkill = 0;
        
        for(skill objskill: lstSkills)
        {
            
            if(objSkill.isSkillMandatory)
                countOfReqSkill++;

        }
        return countOfReqSkill;
    }
   
    public static integer getMaxWeightagesForCriteriaSelected(boolean isPreferredTechEnabled,boolean isproductExpertiseEnabled,boolean isSkillsEnabled, boolean isEligibilityEnabled)
    {
        integer MaxWeigtageForCriteriaSelected = 0;
        integer MaxWeigtageForSkillEnabled = 0;
        if(isPreferredTechEnabled)
        MaxWeigtageForCriteriaSelected = MaxWeigtageForCriteriaSelected +defaultPreferredTechnicianScore; 
        if(isproductExpertiseEnabled)
            MaxWeigtageForCriteriaSelected = MaxWeigtageForCriteriaSelected +defaultProductSpecializationScore;
        /*if(isSkillsEnabled)
        {
            MaxWeigtageForCriteriaSelected = MaxWeigtageForCriteriaSelected +defaultSkillScore;
            if((ReqSkillCount == 0 || ReqSkillCount >0) && optionalSkillCount >0)
            MaxWeigtageForCriteriaSelected = MaxWeigtageForCriteriaSelected +defaultSkillScore; 
        }*/
        //DNS-926/966
        /*  If checkbox is checked in 'Skills' tab at 'Advanced Technician Search(ATS)'
            case:1 If only required skills are there, defaultSkillScore is added only once to MaxWeigtageForCriteriaSelected 
            case:2 If required skills and optional skills are there, defaultSkillScore will be added twice to MaxWeigtageForCriteriaSelected. one for Required skills and another for optional skills
            case:3 If only optional skills are there, defaultSkillScore is added only once to MaxWeigtageForCriteriaSelected
            case:4 If none of skills is there, then defaultSkillScore is added once to MaxWeigtageForCriteriaSelected.
        */  
        if(isSkillsEnabled)
        {
            If(ReqSkillCnt >0)
            {
                MaxWeigtageForSkillEnabled = defaultSkillScore;
            }
            If(ReqSkillCnt >0 && optionalSkillCount >0)
            {
                MaxWeigtageForSkillEnabled = MaxWeigtageForSkillEnabled + defaultSkillScore;
            }
            If(ReqSkillCnt == 0 && optionalSkillCount >0)
            {
                MaxWeigtageForSkillEnabled = defaultSkillScore;
            }
            If(MaxWeigtageForSkillEnabled == 0)
            {
                MaxWeigtageForSkillEnabled = defaultSkillScore;
            }
            MaxWeigtageForCriteriaSelected = MaxWeigtageForCriteriaSelected +MaxWeigtageForSkillEnabled; 
        }
        
        if(isEligibilityEnabled)
            MaxWeigtageForCriteriaSelected = MaxWeigtageForCriteriaSelected +defaultEligibilityScore; 
        return MaxWeigtageForCriteriaSelected;
    }   

    //Get skill list for each work order id
    WebService static List<SVMXMapofIdandSkill> getSkillsForGivenWOIds(List<Id> lstOfWorkOrderId)
    {
        SVMXMapofIdandSkill objmapofIdSkill =  new SVMXMapofIdandSkill();
        List<SVMXMapofIdandSkill> listmapWOidlSkillLst = new List<SVMXMapofIdandSkill>();
        System.debug('lstOfWorkOrderId: '+lstOfWorkOrderId);
        List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
        //lstWorkOrder = getWO(lstOfWorkOrderId);
        if(lstOfWorkOrderId != null && lstOfWorkOrderId.size()>0)
            lstWorkOrder = getLstWO(lstOfWorkOrderId);

        System.debug('lstWorkOrder: '+lstWorkOrder);
        try
        {
            for(SVMXC__Service_Order__c ObjWO: lstWorkOrder)
            {
                List<skill> lstWOSkills = new  List<skill>();
                lstWOSkills = getSkillsetFromWO(lstWorkOrder);
                objmapofIdSkill.key = ObjWO.id;
                objmapofIdSkill.lstSkill = lstWOSkills;
                listmapWOidlSkillLst.add(objmapofIdSkill);
            }
            System.debug('listmapWOidlSkillLst: '+listmapWOidlSkillLst);
            return listmapWOidlSkillLst;
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }


    WebService static List<skill> encodeToSkillObj(String jsonStringOfSkills)
    {
        List<skill> wrpSkillValues = new List<skill>();
        try
        {
            
            if(String.isNotBlank(jsonStringOfSkills))
            {
                wrpSkillValues = (List<skill>)JSON.deserialize(jsonStringOfSkills, List<skill>.class);
                
            }
            return wrpSkillValues;
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }
    
    //This function is to return the appended skill set in JSON format
    Webservice static List<SVMXMapofIdandSkill> decodeSkillObjMapToJSON(List<SVMXMapofIdandSkill> mapWOidJsonStrOfSkill)
    {
        List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
        List<Id> lstOfWorkOrderId = new List<Id>();
        
        List<SVMXMapofIdandSkill> listofMapWOIdJsonStrofSkill = new List<SVMXMapofIdandSkill>();
        
        try
        {
            for(SVMXMapofIdandSkill svmxMap: mapWOidJsonStrOfSkill){
                lstOfWorkOrderId.add(svmxMap.key );
                //lstWorkOrder = getWO(lstOfWorkOrderId);
                if(lstOfWorkOrderId != null && lstOfWorkOrderId.size()>0)
                    lstWorkOrder = getLstWO(lstOfWorkOrderId);

                //extract skill from the workOrder
                List<skill> lstWOSkills = new  List<skill>();
                lstWOSkills = getSkillsetFromWO(lstWorkOrder);
                
                SVMXMapofIdandSkill objSVMXMapofIdandSkill = new SVMXMapofIdandSkill();
                String jsonStringOfSkills = '';
                String jsonInputString = '';
                jsonStringOfSkills = JSON.serialize(lstWOSkills);
                jsonInputString = svmxMap.value;
                jsonStringOfSkills = jsonStringOfSkills+jsonInputString;
                
                objSVMXMapofIdandSkill.key = svmxMap.key;
                objSVMXMapofIdandSkill.value = jsonStringOfSkills;
                listofMapWOIdJsonStrofSkill.add(objSVMXMapofIdandSkill);
            }
            return listofMapWOIdJsonStrofSkill;
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }
    
    // This function returns skill set in JSON format of provided skill objects
    WebService static String decodeSkillListToJSON(List<skill> lstOfSkills)
    {
        try
        {   
            String jsonStringOfSkills = '';
            return jsonStringOfSkills = JSON.serialize(lstOfSkills);
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }

    // Update the WorkOrder with the given skill
    Webservice static void putSkillsForGivenWOIds(List<SVMXMapofIdandSkill> mapWOIdSkill)
    {
        List<SVMXC__Service_Order__c> listOfWorkOrders = new List<SVMXC__Service_Order__c>();
        list<Id> lstWorkorderIds = new list<Id>();  
        SVMXMapofIdandSkill objSvmxMapIdSkill = new SVMXMapofIdandSkill();
        
        try
        {
            // Add the WorkOrderId's to the list
            for(SVMXMapofIdandSkill workOrderId: mapWOIdSkill) {
                lstWorkorderIds.add(workOrderId.key);
            }
            
            //get the WorkOrder list to update
            list<SVMXC__Service_Order__c> theListOfWorkOrder = new list<SVMXC__Service_Order__c>();
             //list<SVMXC__Service_Order__c> theListOfWorkOrder = getWO(lstWorkorderIds);
            if(lstWorkorderIds != null && lstWorkorderIds.size()>0)
            theListOfWorkOrder = getLstWO(lstWorkorderIds);


            Map<Id, SVMXC__Service_Order__c> workOrderMap = new Map<Id, SVMXC__Service_Order__c>();
            
            for(SVMXC__Service_Order__c ObjWO: theListOfWorkOrder){
                workOrderMap.put(ObjWO.Id, ObjWO);
            }
            
            for(SVMXMapofIdandSkill workOrderId: mapWOIdSkill){ 
                String jsonStringOfSkill = JSON.serialize(workOrderId.skillValue);
                System.debug('Json String Of Skill '+jsonStringOfSkill);
                SVMXC__Service_Order__c theWorkOrder = workOrderMap.get(workOrderId.key);
                //Update the skill for WorkOrder
                theWorkOrder.SVMXC__Skill_Set__c = jsonStringOfSkill; 
                listOfWorkOrders.add(theWorkOrder);
            }
        //CRUD checking 
        if(listOfWorkOrders != null && listOfWorkOrders.size() >0)
            {
            if (!securityUtils.verifyFieldAccess(listOfWorkOrders, COMM_SecurityUtils.Access.Updateable, true))
                {

                throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Service_Order__c') );    
                }   
        //update the list of WorkOrders
            else
                {
                    update listOfWorkOrders; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
            }   
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }
    public static list<SVMXC__Service_Order__c>  getLstWO(List<Id> lstWorkOrderIds)
    {
        system.debug('lstWorkOrderIds:'+lstWorkOrderIds);
        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        lstWO = [SELECT Id, SVMXC__Skill_Set__c FROM SVMXC__Service_Order__c WHERE Id IN :lstWorkOrderIds];
        system.debug('lstWO: '+lstWO);
        return lstWO;
    }
    //This function appends skill set to the work order
    Webservice static void appendSkillsForGivenWOIds(List<SVMXMapofIdandSkill> mapWOidJsonStrOfSkill)
    {
        List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
        List<Id> lstOfWorkOrderId = new List<Id>();
                
        map<Id,string> mapWOIdSkill = new map<Id,string>();
        try
        {
            for(SVMXMapofIdandSkill svmxMap: mapWOidJsonStrOfSkill){
                lstOfWorkOrderId.add(svmxMap.key);
                mapWOIdSkill.put(svmxMap.key, svmxMap.value);
            }
            //Retriving WO    
            if(lstOfWorkOrderId != null && lstOfWorkOrderId.size()>0)
                lstWorkOrder = getLstWO(lstOfWorkOrderId);

            //extract skill from the workOrder
            List<skill> lstWOSkills = new  List<skill>();
            for(SVMXC__Service_Order__c objWO:lstWorkOrder)
            {
                list<SVMXC__Service_Order__c> lstWO= new list<SVMXC__Service_Order__c>();
                lstWO.add(objWO);
                lstWOSkills = getSkillsetFromWO(lstWO);
                
                objWO.SVMXC__Skill_Set__c =  JSON.serialize(lstWOSkills)+ mapWOIdSkill.get(objWO.Id); 
                
            }
            //CRUD checking
            if(lstWorkOrder != null && lstWorkOrder.size() > 0)
            {
                
                if (!securityUtils.verifyFieldAccess(lstWorkOrder, COMM_SecurityUtils.Access.Updateable, true))
                    {

                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Service_Order__c')  );   
                    }
                else
                {
                    update lstWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED   
                }
            }    
                    
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
    }
    


    //DNS-926/966   
    public static Map<Id, Set<Id>> buildPreferredTechnicianScore(list<SVMXC__Service_Order__c> lstWorkOrder, 
                                                                set<Id> setTechnicianIds, 
                                                                list<MPXTechnicians> lstMPXTechnicans1)
    {
        Map<Id, Set<Id>> mapWorkOrderPrefferedTechnician = new Map<Id, Set<Id>>();
        Set<Id> temppreftechs = new Set<Id>();
        
        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
        {
            for(MPXTechnicians objlstMPXs: lstMPXTechnicans1) 
            {
                If(setTechnicianIds.contains(objlstMPXs.techID))
                {
                    If(objlstMPXs.techPreferenceType.trim().equals('Preferred') || objlstMPXs.techPreferenceType.trim().equals('Mandatory')) 
                    {
                        If(!objlstMPXs.strDeleted.trim().equals('Deleted')) 
                        {
                            temppreftechs.add(objlstMPXs.techID); 
                        }
                    }
                }   
            }
            mapWorkOrderPrefferedTechnician.put(objWorkOrder.Id, temppreftechs);    
        }
        System.debug(logginglevel.warn,'mapWorkOrderPrefferedTechnician:' + mapWorkOrderPrefferedTechnician);
        return mapWorkOrderPrefferedTechnician;
    }
}