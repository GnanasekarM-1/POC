public with sharing class SMAX_OptiMax_EngineUtils {

public class SVMXException extends Exception{}

private COMM_SVMXC_Utils4 clsUtils4 = new COMM_SVMXC_Utils4();
private COMM_Utils utils = new COMM_Utils();
String MSG_QTLCOMPUTED = 'Qualified Technician List Computed';
String MSG_QTLCOMPUTED_NOTECH_ALLOW = 'No Qualified Technicians (Allow)';
String MSG_QTLCOMPUTED_NOTECH_DISALLOW = 'No Qualified Technicians (Disallow)';
String MSG_QTLCOMPUTED_NOTECH_WARN = 'No Qualified Technicians (Warn)';
String strEligibilityMatchSays = 'ALLOW';
String strSkillMatchSays = 'ALLOW';
Integer defaultPreferredTechnicianScore = 10;
Integer defaultProductSpecializationScore = 10;
Integer defaultEligibilityScore = 10;
Integer defaultSkillScore = 10;
set<Id> setNonQualifiedWorkOrdersAllow = new set<Id>();
set<Id> setNonQualifiedWorkOrdersDisallow = new set<Id>();
map<Id, list<skill>> mapWorkOrderMatchedSkills = new map<Id, list<skill>>();
map<Id, Integer> mapWorkOrderRequiredSkillCount = new map<Id, Integer>();
map<Id, Integer> mapWorkOrderOptionalSkillCount = new map<Id, Integer>();
map<Id, set<Id>> mapMandatoryMatchedSkills = new map<Id, set<Id>>();

public class stachRank{
    public Id tech;
    public String tName;
    public Boolean valid;
    public Integer prefTech;
    public Integer prod;
    public Integer eligible;
    public Integer skillR;
    public Double skillO;
    public Integer stackRank;
    public String prefType;
    public String eligibleRuleName;
}

public class skill{
    Id skillId;
    String skillName;
    Boolean isSkillMandatory;
    Integer skillLevel;
    
    public skill(Id skillId, String skillName, Boolean isSkillMandatory, Integer skillLevel){
        this.skillId = skillId;
        this.skillName = skillName;
        this.isSkillMandatory = isSkillMandatory;
        this.skillLevel = skillLevel;
    }
}

public class techAddress{
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

public void getDispatchProcessProperties(Id dispatchProcessId)
{
    SVMXC__ServiceMax_Processes__c objSVMXProcess;
    try
    {
        objSVMXProcess = [Select SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c from SVMXC__ServiceMax_Processes__c where Id = :dispatchProcessId];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    catch(Exception ex)
    {
        throw new SVMXException('Invalid dispatch process Id found.');
    }
    
    if(objSVMXProcess.SVMXC__Weight_Tech_Eligibility__c != NULL)
        defaultEligibilityScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Tech_Eligibility__c);
    if(objSVMXProcess.SVMXC__Weight_Skill_Match__c != NULL)
        defaultSkillScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Skill_Match__c);
    if(objSVMXProcess.SVMXC__Weight_Product_Specialization__c != NULL)
        defaultProductSpecializationScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Product_Specialization__c);
    if(objSVMXProcess.SVMXC__Weight_Preferred_Technician__c != NULL)
        defaultPreferredTechnicianScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Preferred_Technician__c);
}


public INTF_WebServicesDef.INTF_Response OMAX_BuildQualifiedTechnicians_WS(INTF_WebServicesDef.INTF_Request request)
{
    INTF_WebServicesDef.INTF_Response response = new INTF_WebServicesDef.INTF_Response();
    if(request.stringMap.size() > 0)
    {
        list<Id> lstWorkorderIds = new list<Id>();
        Id territoryId;
        Id dispatchProcessId;
        for(INTF_WebServicesDef.INTF_StringMap strMap: request.stringMap)
        {
            if(strMap.key == 'WORKORDERID')
                lstWorkorderIds.add(strMap.value);
            if(strMap.key == 'DISPATCHPROCESSID')
                dispatchProcessId = strMap.value;
            if(strMap.key == 'TERRITORYID')
                territoryId = strMap.value;
        }
        if(lstWorkorderIds.size() == 0 || territoryId == NULL || dispatchProcessId == NULL)
        {
            throw new SVMXException('Insufficient information to compute qaulified technician list.');
        }
        getDispatchProcessProperties(dispatchProcessId);
        SMAX_OptiMax_EngineUtils clsOMAXEngineUtils = new SMAX_OptiMax_EngineUtils();
        List<INTF_WebServicesDef.SVMXMap> lstWorkOrderWrapper = new List<INTF_WebServicesDef.SVMXMap>();
        map<Id, SVMXC__Service_Order__c> mapQTLWorkOrders = clsOMAXEngineUtils.buildQualifiedTechnicians(lstWorkorderIds, NULL, territoryId);
        for(SVMXC__Service_Order__c objWO: mapQTLWorkOrders.values())
        {
            if(objWO.SVMXC__Qualified_Technicians__c != NULL || objWO.SVMXC__Skill_Set__c != NULL)
            {
                INTF_WebServicesDef.SVMXMap wrpWorkOrder = new INTF_WebServicesDef.SVMXMap(objWO.Id, NULL);
                wrpWorkOrder.record = new SVMXC__Service_Order__c(SVMXC__Qualified_Technicians__c = objWO.SVMXC__Qualified_Technicians__c, SVMXC__Skill_Set__c = objWO.SVMXC__Skill_Set__c);
                lstWorkOrderWrapper.add(wrpWorkOrder);
            }
        }
        response.valueMap = lstWorkOrderWrapper;
    }
    return response;
}

public map<Id, SVMXC__Service_Order__c> buildQualifiedTechnicians(list<Id> lstWorkOrderIds, list<SVMXC__Service_Order__c> lstWorkOrders, Id idTerritory)
{
    DCON_Utils dcUtils = new DCON_Utils();
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    
    list<String> lstWorkOrderFields = new list<String>();
    list<String> lstTechniciansFields = new list<String>();
    map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
    map<Id, Id> mapPreferredTechnicians = new map<Id, Id>();
    map<Id, set<Id>> mapProductSpecialist = new map<Id, set<Id>>();
    map<Id, map<Id, list<skill>>> mapTechnicianSkill = new map<Id, map<Id, list<skill>>>();
    map<Id, list<stachRank>> mapWorkOrderStackRank = new map<Id, list<stachRank>>();
    map<Id, SVMXC__Service_Order__c> mapServiceOrder = new map<Id, SVMXC__Service_Order__c>();

    Integer intLimitCpuTime = Limits.getLimitCpuTime();
    Integer intLimitHeapSize = Limits.getLimitHeapSize();
    
    list<string> lstSettings = new list<string>();
    lstSettings.add('OMAX003_SET045');
    lstSettings.add('OMAX003_SET046');
    lstSettings.add('OMAX003_SET048');
    map<String, String> mapSettingValues = commSettings.SVMX_getGlobalSettingList(lstSettings);
    

    if(mapSettingValues.containsKey('OMAX003_SET045'))
        strSkillMatchSays = mapSettingValues.get('OMAX003_SET045').toUpperCase();
    if(mapSettingValues.containsKey('OMAX003_SET046'))
        strEligibilityMatchSays = mapSettingValues.get('OMAX003_SET046').toUpperCase();

    lstTechniciansFields = getFieldDefinition(Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap());
    
    list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
    String querySelect;
    String WhereClause;
    system.debug(logginglevel.warn, 'Requested Work Order Info: ' + lstWorkOrderIds + ':' + lstWorkOrders);
    if(lstWorkOrders == NULL || lstWorkOrders.size() == 0)
    {
        lstWorkOrderFields = getFieldDefinition(Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap());
        // Get all Work Orders that needs to be preprocessed
        querySelect = utils.SVMX_getFieldNamesFromList(lstWorkOrderFields); //Convert the list of strings to coma seperated string
        WhereClause = 'Id IN :lstWorkOrderIds';
        lstWorkOrder = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Order__c WHERE '+string.escapeSingleQuotes(WhereClause));
    }
    else
        lstWorkOrder = lstWorkOrders;
    querySelect = utils.SVMX_getFieldNamesFromList(lstTechniciansFields); //Convert the list of strings to coma seperated string
    WhereClause = 'SVMXC__Service_Territory__c = :idTerritory';
    list<SVMXC__Service_Group_Members__c> lstTechnicians = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Active__c = true and '+string.escapeSingleQuotes(WhereClause));
    set<Id> setTechnicianIds = new set<Id>();
    map<Id, String> mapTechNames = new map<Id, String>(); 
    for(SVMXC__Service_Group_Members__c objTechnicians: lstTechnicians)
    {
        setTechnicianIds.add(objTechnicians.Id);
        mapTechNames.put(objTechnicians.Id, objTechnicians.Name);
    }
    
    // Find Technician Eligibility score
    mapMatchedEligibilityScore = buildTechnicianEligibilityScore(lstWorkOrder, lstTechnicians);
    
    system.debug(logginglevel.WARN, system.now() + ': Usage Details: After buildTechnicianEligibilityScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            
    // Find Preferred Technician score
    mapPreferredTechnicians = buildPreferredTechnicianScore(lstWorkOrder, setTechnicianIds);
    // Find Product Specialization score
    system.debug(logginglevel.WARN, system.now() + ': Usage Details: After buildPreferredTechnicianScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
    
    mapProductSpecialist = buildProductSpecialScore(lstWorkOrder, setTechnicianIds);
    // Find Technicians Skill score
    system.debug( system.now() + ': Usage Details: After buildProductSpecialScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
    
    mapTechnicianSkill = buildSkillScore(lstWorkOrder, setTechnicianIds);
    system.debug(logginglevel.WARN, system.now() + ': Usage Details: After buildSkillScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
    
    // Build Work Order Qualified Technician List from above scores
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
    {
        mapServiceOrder.put(objWorkOrder.Id, objWorkOrder);
        Integer intOptionalSkillCount = 0;
        if(mapWorkOrderOptionalSkillCount.containsKey(objWorkOrder.Id) && mapWorkOrderOptionalSkillCount.get(objWorkOrder.Id) != NULL)
            intOptionalSkillCount = mapWorkOrderOptionalSkillCount.get(objWorkOrder.Id);
        if(mapMatchedEligibilityScore.containsKey(objWorkOrder.Id) || mapPreferredTechnicians.containsKey(objWorkOrder.Id) || mapProductSpecialist.containsKey(objWorkOrder.Id) || mapTechnicianSkill.containsKey(objWorkOrder.Id))
        {
            set<Id> setEligibleTechnicians = new set<Id>();
            set<Id> setProductSpecialist = new set<Id>();
            map<Id, list<skill>> mapTechSkills = new map<Id, list<skill>>();
            set<Id> setMatchedRequiredTechs = new set<Id>();
            id idPreferredTechnician;
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
            list<stachRank> lstTechnicianStackRanks = new list<stachRank>(); 
            for(Id techId: setTechnicianIds)
            {
                stachRank clsStackRank = new stachRank();
                clsStackRank.tech = techId;
                clsStackRank.tName = mapTechNames.get(techId);
                if(setEligibleTechnicians != NULL && setEligibleTechnicians.contains(techId))
                    clsStackRank.eligible = 1;
                if(setProductSpecialist != NULL && setProductSpecialist.contains(techId))
                    clsStackRank.prod = 1;
                if(idPreferredTechnician != NULL && idPreferredTechnician == techId)
                    clsStackRank.prefTech = 1;
                if(mapTechSkills != NULL && mapTechSkills.containsKey(techId))
                {
                    integer intOptionalSkillScore = 0;
                    if(setMatchedRequiredTechs != NULL && setMatchedRequiredTechs.contains(techId))
                        clsStackRank.skillR = defaultSkillScore;
                    for(skill objSkill: mapTechSkills.get(techId))
                    {
                        if(!objSkill.isSkillMandatory)
                            intOptionalSkillScore++;
                    }
                    if(intOptionalSkillCount > 0)
                    {
                        clsStackRank.skillO = ((decimal)(intOptionalSkillScore * defaultSkillScore)).divide(intOptionalSkillCount, 2);
                    }
                    else
                        clsStackRank.skillO = 0;
                }
                lstTechnicianStackRanks.add(clsStackRank);
            }
            mapWorkOrderStackRank.put(objWorkOrder.Id, lstTechnicianStackRanks);
        }
        else
        {
            mapWorkOrderStackRank.put(objWorkOrder.Id, new list<stachRank>());
        }
    }
    mapWorkOrderStackRank = scoreProcessor(mapWorkOrderStackRank);
    
    //Update the Work Order with the Qualified Technician and Skill information
    for(Id workOrderId: mapWorkOrderStackRank.keySet())
    {
        mapServiceOrder.get(workOrderId).SVMXC__Qualified_Technicians__c = JSON.serialize(mapWorkOrderStackRank.get(workOrderId));
        if(setNonQualifiedWorkOrdersAllow.contains(workOrderId))
            mapServiceOrder.get(workOrderId).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED_NOTECH_ALLOW;
        else if(setNonQualifiedWorkOrdersDisallow.contains(workOrderId))
            mapServiceOrder.get(workOrderId).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED_NOTECH_DISALLOW;
        else
            mapServiceOrder.get(workOrderId).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED;
        if(mapWorkOrderMatchedSkills != NULL && mapWorkOrderMatchedSkills.containsKey(workOrderId) && mapWorkOrderMatchedSkills.get(workOrderId) != NULL)
            mapServiceOrder.get(workOrderId).SVMXC__Skill_Set__c = JSON.serialize(mapWorkOrderMatchedSkills.get(workOrderId));
    }

    return mapServiceOrder;
}

public map<Id, list<stachRank>> scoreProcessor(map<Id, list<stachRank>> mapWorkOrderStackRank)
{
    Integer maxScore = defaultPreferredTechnicianScore + defaultProductSpecializationScore + defaultEligibilityScore + (defaultSkillScore * 2);
    if(maxScore == 0 ) return mapWorkOrderStackRank;
    for(Id workOrderId: mapWorkOrderStackRank.keySet())
    {
        list<stachRank> lstStackRank = mapWorkOrderStackRank.get(workOrderId);
        list<stachRank> lstProcessedStackRank = new list<stachRank>();
        Integer intEligibilityMatchedTechnicianCount = 0;
        Integer intSkillMatchedTechnicianCount = 0;
        for(stachRank objStackRank: lstStackRank)
        {
            system.debug(logginglevel.WARN,'objStackRank: ' + objStackRank);
            //If the technician is not having any QTL values, skip this technician
            if((objStackRank.eligible == NULL || objStackRank.eligible == 0 ) && (objStackRank.prefTech == NULL || objStackRank.prefTech == 0 ) && (objStackRank.prod == NULL || objStackRank.prod == 0 ) && (objStackRank.skillO == NULL || objStackRank.skillO == 0 ) && (objStackRank.skillR == NULL || objStackRank.skillR == 0))
                continue;
            objStackRank.valid = true;
            // If Expertise match is not available and configuration says don't send Work Order to OptiMax
            if((defaultEligibilityScore > 0 && strEligibilityMatchSays == 'DISALLOW' && (objStackRank.eligible == NULL || objStackRank.eligible == 0)))
            {
                objStackRank.valid = false;
            }
            else
                intEligibilityMatchedTechnicianCount++;
            // If Skill match is not available and configuration says don't send Work Order to OptiMax
            if((defaultSkillScore > 0 && strSkillMatchSays == 'DISALLOW' && (objStackRank.skillR == NULL || objStackRank.skillR == 0)))
            {
                objStackRank.valid = false;
            }
            else
                intSkillMatchedTechnicianCount++;
                
            // Update corresponding scores based on default property
            if(objStackRank.eligible == NULL || defaultEligibilityScore == 0)
                objStackRank.eligible = 0;
            else if(objStackRank.eligible == 1)
                objStackRank.eligible = defaultEligibilityScore;
                
            if(defaultSkillScore == 0)
            {
                objStackRank.skillR = 0;
                objStackRank.skillO = 0;
            }
            if(objStackRank.prod == NULL || defaultProductSpecializationScore == 0)
                objStackRank.prod = 0;
            else if(objStackRank.prod == 1)
                objStackRank.prod = defaultProductSpecializationScore;
            if(objStackRank.prefTech == NULL || defaultPreferredTechnicianScore == 0)
                objStackRank.prefTech = 0;
            else if(objStackRank.prefTech == 1)
                objStackRank.prefTech = defaultPreferredTechnicianScore;
                
            if(objStackRank.skillO == NULL)
                objStackRank.skillO = 0;
            if(objStackRank.skillR == NULL)
                objStackRank.skillR = 0;
            //Populate Stack Rank
            double totalScore = objStackRank.prefTech + objStackRank.prod + objStackRank.skillO + objStackRank.skillR + objStackRank.eligible;
            double dblStackRnk = ((decimal)(totalScore * 10)).divide(maxScore, 2);
            objStackRank.stackRank = integer.valueOf(dblStackRnk.round());
            if(objStackRank.stackRank == 0)
                continue;
            lstProcessedStackRank.add(objStackRank);
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
    return mapWorkOrderStackRank;
}

public map<Id, map<Id, list<skill>>> buildSkillScore(list<SVMXC__Service_Order__c> lstWorkOrder, set<Id> setTechnicianIds)
{
    map<Id, map<Id, list<skill>>> mapSkillMatch = new map<Id, map<Id, list<skill>>>();
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
    mapOMaxAllSkillMatchRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c, SVMXC__Node_Parent__c, SVMXC__Primary_Consolidation_Rule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Skill Matching' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
    
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder){
        mapWorkOrders.put(objWorkOrder.Id, objWorkOrder);
    }
    
    for(SVMXC__ServiceMax_Processes__c rule: mapOMaxAllSkillMatchRules.values()){
        if(rule.SVMXC__Node_Parent__c == NULL)
            mapOMaxSkillMatchRules.put(rule.Id, rule);
        else{
            list<SVMXC__ServiceMax_Processes__c> lstRules = new list<SVMXC__ServiceMax_Processes__c>();
            if(!mapOMaxSkillMatchRulesChildrens.containsKey(rule.SVMXC__Node_Parent__c))
                mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, NULL);
            if(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c) != NULL)
                lstRules.addAll(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c));
            lstRules.add(rule);
            mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, lstRules);
        }
    }
    
    mapOMaxAllSkillMatchRulesExpression = getWorkOrderExpression(mapOMaxAllSkillMatchRules,  'Skill_Eligibility');
    for(Id ruleId: mapOMaxSkillMatchRules.keySet()){
        mapOMaxSkillMatchRulesExpression.put(ruleId, mapOMaxAllSkillMatchRulesExpression.get(ruleId));
    }
    
    system.debug(logginglevel.WARN,'lstWorkOrder: ' + lstWorkOrder);
    system.debug(logginglevel.WARN,'mapOMaxSkillMatchRulesExpression: ' + mapOMaxSkillMatchRulesExpression);
    // Get the list of all valid Skill Match rules
    mapWorkOrderRule = parseWorkOrderExpressions(lstWorkOrder, mapOMaxSkillMatchRules, mapOMaxSkillMatchRulesExpression);
    
    //For each Work Order Matched, get all child Rules and Find the Expression Match
    map<Id, set<Id>> mapMatchedWorkOrderSkills = new map<Id, set<Id>>();
    for(Id workOrderId: mapWorkOrderRule.keySet()){
        set<Id> setMatchedRules = new set<Id>();
        Id parentRule = mapWorkOrderRule.get(workOrderId);
        if(mapOMaxSkillMatchRulesChildrens.containsKey(parentRule) && mapOMaxSkillMatchRulesChildrens.get(parentRule) != NULL){
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
            if(setMatchedRules != NULL)
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
    list<SVMXC__ServiceMax_Config_Data__c> lstSkillMatches = [Select SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Minimum_Level__c, SVMXC__Required__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Applicable Skills' and SVMXC__Expression_Rule__c IN: lstAllMatchedRules];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    set<Id> setRequiredSkills = new set<Id>();
    for(SVMXC__ServiceMax_Config_Data__c skillMatches: lstSkillMatches)
    {
        list<skill> wrpSkillValues = new list<skill>();
        //skillMatches.SVMXC__Expression_Rule__c = mapChildRuleToParentRule.containsKey(skillMatches.SVMXC__Expression_Rule__c) ? mapChildRuleToParentRule.get(skillMatches.SVMXC__Expression_Rule__c) : skillMatches.SVMXC__Expression_Rule__c;
        if(!mapRequiredSkills.containsKey(skillMatches.SVMXC__Expression_Rule__c))
            mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, NULL);
        
        if(mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c) != NULL)
            wrpSkillValues = mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c);
        if(skillMatches.SVMXC__Minimum_Level__c == NULL)
            skillMatches.SVMXC__Minimum_Level__c = 0;
        wrpSkillValues.add(new skill(skillMatches.SVMXC__Skill__c, skillMatches.SVMXC__Skill__r.Name, skillMatches.SVMXC__Required__c, (skillMatches.SVMXC__Minimum_Level__c).intValue()));
        setRequiredSkills.add(skillMatches.SVMXC__Skill__c);
        mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, wrpSkillValues);
    }
    
    list<SVMXC__Service_Group_Skills__c> lstExpertise = [Select SVMXC__Skill__c, SVMXC__Skill_Level__c, SVMXC__Group_Member__c from SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__c IN :setTechnicianIds and SVMXC__Skill__c IN: setRequiredSkills and SVMXC__Is_Applicable__c = 'TRUE'];
    map<Id, map<Id, Integer>> mapTechnicianSkillScore = new map<Id, map<Id, Integer>>();
    for(SVMXC__Service_Group_Skills__c objExperts: lstExpertise)
    {
        map<Id, Integer> mapSkillScore = new map<Id, Integer>();
        if(!mapTechnicianSkillScore.containsKey(objExperts.SVMXC__Group_Member__c))
            mapTechnicianSkillScore.put(objExperts.SVMXC__Group_Member__c, NULL);
        if(mapTechnicianSkillScore.get(objExperts.SVMXC__Group_Member__c) != NULL)
            mapSkillScore = mapTechnicianSkillScore.get(objExperts.SVMXC__Group_Member__c);
        if(objExperts.SVMXC__Skill_Level__c == NULL)
            objExperts.SVMXC__Skill_Level__c = 0;
        mapSkillScore.put(objExperts.SVMXC__Skill__c, (objExperts.SVMXC__Skill_Level__c).intValue());
        mapTechnicianSkillScore.put(objExperts.SVMXC__Group_Member__c, mapSkillScore);
    }
    
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
    {
        map<Id, list<skill>> mapTechnicianMatchedSkillScores = new map<Id, list<skill>>();
        Integer expectedOptionalSkillCount = 0;
        //Getting matched skills for work order
        list<skill> lstMatchedWOSkills = new list<skill>();
        if(mapMatchedWorkOrderSkills != NULL && mapMatchedWorkOrderSkills.containsKey(objWorkOrder.Id) && mapMatchedWorkOrderSkills.get(objWorkOrder.Id) != NULL)
        {
            for(Id matchedRule: mapMatchedWorkOrderSkills.get(objWorkOrder.Id))
            {
                list<skill> setMatchedSkills = mapRequiredSkills.get(matchedRule);
                if(setMatchedSkills != NULL)
                    lstMatchedWOSkills.addAll(setMatchedSkills);
            }
        }
        else
            continue;
        
        if(mapWorkOrderRule.containsKey(objWorkOrder.Id) && mapWorkOrderRule.get(objWorkOrder.Id) != NULL && lstMatchedWOSkills.size() > 0)
        {
            lstMatchedWOSkills = makeUniqueSkillList(lstMatchedWOSkills);
            mapWorkOrderMatchedSkills.put(objWorkOrder.Id, lstMatchedWOSkills);
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
                if(mapTechniciansSkills == NULL || lstMatchedWOSkills == NULL)
                    continue;
                for(skill objSkill: lstMatchedWOSkills)
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
                        {
                            lstMatchedTechnicianRequiredSkills.add(new skill(objSkill.skillId, objSkill.skillName, objSkill.isSkillMandatory, mapTechniciansSkills.get(objSkill.skillId)));
                            isOneMandatorySkillMatched = true;
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
        }
        if(lstMatchedWOSkills != NULL)
        for(skill objSkill: lstMatchedWOSkills)
        {
            if(!objSkill.isSkillMandatory)
                expectedOptionalSkillCount++;
        }
        mapWorkOrderOptionalSkillCount.put(objWorkOrder.Id, expectedOptionalSkillCount);
    }
    system.debug(logginglevel.WARN,'mapWorkOrderOptionalSkillCount: ' + mapWorkOrderOptionalSkillCount);
    system.debug(logginglevel.WARN,'mapWorkOrderMatchedSkills: ' + mapWorkOrderMatchedSkills);
    system.debug(logginglevel.WARN,'mapSkillMatch: ' + mapSkillMatch);
    
    return mapSkillMatch;
}

public list<skill> makeUniqueSkillList(list<skill> lstMatchedWOSkills)
{
    list<skill> response = new list<skill>();
    map<Id, Integer> mapMandatoryLevel = new map<Id, Integer>();
    set<Id> setAddedMandatory = new set<Id>();
    set<Id> setAddedOptional = new set<Id>();
    for(skill objSkill: lstMatchedWOSkills)
    {
        if(objSkill.isSkillMandatory)
        {
            if(mapMandatoryLevel.containsKey(objSkill.skillId))
            {
                if(mapMandatoryLevel.get(objSkill.skillId) < objSkill.skillLevel)
                    mapMandatoryLevel.put(objSkill.skillId, objSkill.skillLevel);
            }
            else
                mapMandatoryLevel.put(objSkill.skillId, objSkill.skillLevel);
        }
    }
    for(skill objSkill: lstMatchedWOSkills)
    {
        //Add mandatory
        if(objSkill.isSkillMandatory && !setAddedMandatory.contains(objSkill.skillId) && mapMandatoryLevel.get(objSkill.skillId) == objSkill.skillLevel)
        {
            response.add(objSkill);
            setAddedMandatory.add(objSkill.skillId);
        }
        else
        {
            if((mapMandatoryLevel == NULL || !mapMandatoryLevel.containsKey(objSkill.skillId)) && !setAddedOptional.contains(objSkill.skillId))
            {
                response.add(objSkill);
                setAddedOptional.add(objSkill.skillId);
            }
        }
    }
    return response;
}

public map<Id, set<Id>> buildProductSpecialScore(list<SVMXC__Service_Order__c> lstWorkOrder, set<Id> setTechnicianIds)
{
    map<Id, set<Id>> mapProductSpecializedTechnician = new map<Id, set<Id>>();
    map<Id, String> mapWorkOrderProduct = new map<Id, String>();
    map<Id, Id> mapWorkOrderInstalledProduct = new map<Id, Id>();
    
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
    {
        if(objWorkOrder.SVMXC__Product__c != NULL)
            mapWorkOrderProduct.put(objWorkOrder.Id, objWorkOrder.SVMXC__Product__c);
        if(objWorkOrder.SVMXC__Component__c != NULL)
            mapWorkOrderInstalledProduct.put(objWorkOrder.Id, objWorkOrder.SVMXC__Component__c);
    }
    
    map<Id, SVMXC__Installed_Product__c> mapInstalledProduct = new map<Id, SVMXC__Installed_Product__c>();
    mapInstalledProduct.putAll([Select Id, SVMXC__Product__c from SVMXC__Installed_Product__c where Id IN: mapWorkOrderInstalledProduct.values()]);
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
    {
        // If Work Order is having IB and Product, IB will get preferrence
        if(mapWorkOrderInstalledProduct.containsKey(objWorkOrder.Id))
        {
            mapWorkOrderProduct.put(objWorkOrder.Id, mapInstalledProduct.get(mapWorkOrderInstalledProduct.get(objWorkOrder.Id)).SVMXC__Product__c);
        }
    }
    
    map<Id, set<Id>> mapProductTechnicians = new map<Id, set<Id>>();
    list<Product2> lstProduct = [Select Id, SVMXC__Product_Line__c, Family from Product2 where Id IN: mapWorkOrderProduct.values()];
    list<SVMXC__Service_Group_Product__c> lstProductSpecialization = [Select Id, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c, SVMXC__Group_Member__c from SVMXC__Service_Group_Product__c where SVMXC__Group_Member__c IN: setTechnicianIds];
    for(SVMXC__Service_Group_Product__c objProductSpecialization: lstProductSpecialization)
    {
        if(isProductSpecializationMatchesProduct(objProductSpecialization, lstProduct))
        {
            if(mapProductTechnicians == NULL || !mapProductTechnicians.containsKey(objProductSpecialization.SVMXC__Product__c))
                mapProductTechnicians.put(objProductSpecialization.SVMXC__Product__c, new set<Id>());
            mapProductTechnicians.get(objProductSpecialization.SVMXC__Product__c).add(objProductSpecialization.SVMXC__Group_Member__c);
        }
    }
    
    for(Id idWorkOrder: mapWorkOrderProduct.keySet())
    {
        if(mapProductTechnicians.containsKey(mapWorkOrderProduct.get(idWorkOrder)))
        {
            mapProductSpecializedTechnician.put(idWorkOrder, mapProductTechnicians.get(mapWorkOrderProduct.get(idWorkOrder)));
        }
        else
            mapProductSpecializedTechnician.put(idWorkOrder, NULL);
    }
    return mapProductSpecializedTechnician;
}

public boolean isProductSpecializationMatchesProduct(SVMXC__Service_Group_Product__c objProductSpecialization, list<Product2> lstProduct)
{
    for(Product2 objProduct: lstProduct)
    {
        if(objProductSpecialization.SVMXC__Product__c == objProduct.Id)
            return true;
        else if(objProductSpecialization.SVMXC__Product_Family__c == objProduct.Family)
            return true;
        else if(objProductSpecialization.SVMXC__Product_Line__c == objProduct.SVMXC__Product_Line__c)
            return true;
    }
    return false;
}

//Finds preferred technicians score for each work order
public map<Id, Id> buildPreferredTechnicianScore(list<SVMXC__Service_Order__c> lstWorkOrder, set<Id> setTechnicianIds)
{
    map<Id, Id> mapWorkOrderPrefferedTechnician = new map<Id, Id>();
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
    {
        if(objWorkOrder.SVMXC__Preferred_Technician__c != NULL && setTechnicianIds.contains(objWorkOrder.SVMXC__Preferred_Technician__c))
        {
            mapWorkOrderPrefferedTechnician.put(objWorkOrder.Id, objWorkOrder.SVMXC__Preferred_Technician__c);
        }
    }
    return mapWorkOrderPrefferedTechnician;
}

//Finds technicians eligibility score for each work order and technician
public map<Id, set<Id>> buildTechnicianEligibilityScore(list<SVMXC__Service_Order__c> lstWorkOrder, list<SVMXC__Service_Group_Members__c> lstTechnicians)
{
    map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
    map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEligibilityMatchExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    // Get the list of all valid Expertise Match rules
    map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
    map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    mapOMaxEligibilityRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Tech Eligibility' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
    mapOMaxEligibilityRulesExpression = getWorkOrderExpression(mapOMaxEligibilityRules,  'Tech_Eligibility');
    system.debug(logginglevel.WARN, 'Technician Eligibility Match: Rule -> Expression ' + mapOMaxEligibilityRules + mapWorkOrderRule.size());
    mapWorkOrderRule = parseWorkOrderExpressions(lstWorkOrder, mapOMaxEligibilityRules, mapOMaxEligibilityRulesExpression);
    system.debug(logginglevel.WARN, 'Technician Eligibility Match: Work Order -> Rules: ' + mapWorkOrderRule);
    list<SVMXC__ServiceMax_Config_Data__c> eligibilities = [Select Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Tech_Match' and SVMXC__Expression_Rule__c IN :mapWorkOrderRule.values() order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    for(SVMXC__ServiceMax_Config_Data__c confData: eligibilities)
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(!mapEligibilityMatchExpressions.containsKey(confData.SVMXC__Expression_Rule__c))
            mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, NULL);
        if(mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c) != NULL)
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
        for(SVMXC__Service_Group_Members__c objTechnicians: lstTechnicians)
        {
            Boolean isTechnicianMatched = matchTechnicianEligibility(objTechnicians, objWorkOrder, lstEligibilities, '');
            if(isTechnicianMatched)
            {
                mapTechnicianScore.add(objTechnicians.Id);
            }
        }
        if(mapTechnicianScore.size() > 0)
            mapMatchedEligibilityScore.put(objWorkOrder.Id, mapTechnicianScore);
    }
    
    return mapMatchedEligibilityScore;
}

// Returns Rule -> Expression
public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getWorkOrderExpression(map<Id, SVMXC__ServiceMax_Processes__c> mapRules, String expressionType)
{
    map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>(); 
    map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    //, SVMXC__Field_Relationship_Name__c
    mapExpression.putAll([SELECT Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c, SVMXC__Field_Relationship_Name__c from SVMXC__ServiceMax_Config_Data__c where (RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapRules.keySet()) and SVMXC__Expression_Type__c = :expressionType order by SVMXC__Sequence__c]);
    for(SVMXC__ServiceMax_Config_Data__c oExp: mapExpression.values())
    {
        if(!mapRulesExpression.ContainsKey(oExp.SVMXC__Expression_Rule__c))
            mapRulesExpression.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
        mapRulesExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
    }
    return mapRulesExpression;
}

// Returns Work Order -> Matched Eligibility Rule
public map<Id, Id> parseWorkOrderExpressions(list<SVMXC__Service_Order__c> lstWorkOrders, map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression)
{
    map<Id, Id> mapRuleMatch = new map<Id, Id>();
    
    for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrders)
    {
        Id IdMatchedRule = clsUtils4.SVMX_ExpressionParsing((SObject)objWorkOrder, mapOMaxEligibilityRulesExpression, mapOMaxEligibilityRules);
        system.debug(logginglevel.WARN, 'TEST_LOG: ' + IdMatchedRule);
        if(IdMatchedRule != NULL)
            mapRuleMatch.put(objWorkOrder.Id, IdMatchedRule);     
    }
    return mapRuleMatch;
}

//This method for before insert process
public map<integer, Id> parseWorkOrderExprForSkills(list<SVMXC__Service_Order__c> lstWorkOrders, map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression)
{
    map<integer, Id> mapRuleMatch = new map<integer, Id>();
    integer i=0;
    for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrders)
    {
        Id IdMatchedRule = clsUtils4.SVMX_ExpressionParsing((SObject)objWorkOrder, mapOMaxEligibilityRulesExpression, mapOMaxEligibilityRules);
        system.debug(logginglevel.WARN, 'TEST_LOG: ' + IdMatchedRule);
        if(IdMatchedRule != NULL){
            mapRuleMatch.put(i, IdMatchedRule);
        }
    i++;     
    }
    return mapRuleMatch;
}

// Apply technician expression and find whether the technician is elligible to work on the work order
public boolean matchTechnicianEligibility(SVMXC__Service_Group_Members__c objTechnician, SVMXC__Service_Order__c objWorkOrder, list<SVMXC__ServiceMax_Config_Data__c> eligibilities, String strAdvanceExpression)
{
    boolean response = false;
    for(SVMXC__ServiceMax_Config_Data__c expression: eligibilities)
    {
        if(expression.SVMXC__Operator__c != NULL)
        {
            expression.SVMXC__Operand__c = expression.SVMXC__Display_Value__c;
            if(expression.SVMXC__Target_Field_Name__c != NULL && objWorkOrder.get(expression.SVMXC__Target_Field_Name__c) != NULL)
            {
                expression.SVMXC__Operand__c = String.valueOf(objWorkOrder.get(expression.SVMXC__Target_Field_Name__c));
                system.debug(logginglevel.warn, 'TEST123: ' + expression.SVMXC__Target_Field_Name__c + ':' + objWorkOrder.get(expression.SVMXC__Target_Field_Name__c));
            }
        }
    }
    response = clsUtils4.SVMX_ExpressionParsing(objTechnician, eligibilities, strAdvanceExpression);
    system.debug(logginglevel.warn, 'TEST123:123 ' + response);
    if(response == NULL) response = false;
    return response;
}

// Get all field in the given field definition
public list<String> getFieldDefinition(map<String, SObjectField> objectFieldDefinition)
{
    list<String> objectFields = new list<String>();
    for(Schema.SObjectField fieldMap: objectFieldDefinition.values())
    {
        // Describe the field to get all properties
        list<SelectOption> lstWofl = new list<SelectOption>();
        Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
        if(fieldDescribe.isAccessible())
            objectFields.add(fieldDescribe.getName());
    }
    return objectFields;
}

// Get technicians current location for given list of technicians Id where working hours is mandatory 

public map<id, techAddress> findCurrentTechnicianLocation(list<SVMXC__Service_Group_Members__c> lstTechnicians, Datetime dtmScheduleStartTime,Map<String, BusinessHours> mapBusinessHours)
{
    SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
    DCON_Utils dcUtils= new DCON_Utils();
    map<Id, list<SVMXC__Service_Group_Members__c>> mapBHTechnicians = new map<Id, list<SVMXC__Service_Group_Members__c>>();
    map<id, techAddress> response = new map<id, techAddress>();
    map<Id, Id> mapTechWO = new map<Id, Id>();
    map<id,SVMXC__Service_Order__c> mapTechWOobj = new map<id,SVMXC__Service_Order__c>();   
    // Get the unique 3 character key prefix of Work Order object. This is used to check if events are related to Work Orders
    Schema.Describesobjectresult woDefinitions;
    Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    if (allObjs.containsKey('SVMXC__Service_Order__c') == TRUE)
        woDefinitions = allObjs.get('SVMXC__Service_Order__c').getDescribe();
    else
        woDefinitions = allObjs.get('Service_Order__c').getDescribe();
    String woKeyPrefix = woDefinitions.getKeyPrefix();
            
    //Build Business Hour Tech Map
    for(SVMXC__Service_Group_Members__c objTech: lstTechnicians)
    {
        if(objTech.SVMXC__Working_Hours__c != NULL)
        {
            list<SVMXC__Service_Group_Members__c> lstTechnicians_Tmp = new list<SVMXC__Service_Group_Members__c>();
            if(!mapBHTechnicians.containsKey(objTech.SVMXC__Working_Hours__c))
                mapBHTechnicians.put(objTech.SVMXC__Working_Hours__c, NULL);
            if(mapBHTechnicians.get(objTech.SVMXC__Working_Hours__c) != NULL)
                lstTechnicians_Tmp = mapBHTechnicians.get(objTech.SVMXC__Working_Hours__c);
            lstTechnicians_Tmp.add(objTech);
            mapBHTechnicians.put(objTech.SVMXC__Working_Hours__c, lstTechnicians_Tmp);
        }
    }
  //below code commented because mapbusiness hours passed as parameter of this method
  /*  map<Id, BusinessHours> mapBusinessHours = new map<Id, BusinessHours>();
    list<BusinessHours> lstBusinessHours = [Select Id, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours
                            where Id IN : mapBHTechnicians.keySet() AND IsActive = TRUE];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
    
    for(BusinessHours objBH: lstBusinessHours)
    {
        mapBusinessHours.put(objBH.Id, objBH);
    }*/
    
    for(Id businessHourId: mapBHTechnicians.keySet())
    {
        if(mapBusinessHours.containsKey(businessHourId))
        {
            map<Id, list<Event>> mapTechEvents = new map<Id, list<Event>>();
            map<Id, list<SVMXC__SVMX_Event__c>> mapTechSVMXEvents = new map<Id, list<SVMXC__SVMX_Event__c>>();
            
            map<String, String> mapUsersTechnicians = new map<String, String>();
            set<String> setAvailTechAsSFUserList = new set<String>();
            set<String> setAvailTechAsSVMXUserList = new set<String>();
            
            
            for(SVMXC__Service_Group_Members__c objTech: mapBHTechnicians.get(businessHourId))
            {
                if(objTech.SVMXC__Salesforce_User__c != NULL)
                {
                    setAvailTechAsSFUserList.add(objTech.SVMXC__Salesforce_User__c);
                    mapUsersTechnicians.put(objTech.SVMXC__Salesforce_User__c, objTech.Id);
                }
                else
                    setAvailTechAsSVMXUserList.add(objTech.Id);
            }
            
            BusinessHours objBusinessHour = mapBusinessHours.get(businessHourId);
            //Find business hour start time in GMT for today
            // Get the start time of the next working day
            Time timStartTime = SMAX_OptiMax_Engine_Ext.getStartEndTime(objBusinessHour, dtmScheduleStartTime.format('EEEE', objBusinessHour.timezonesidkey), 'StartTime');
            Time timEndTime = SMAX_OptiMax_Engine_Ext.getStartEndTime(objBusinessHour, dtmScheduleStartTime.format('EEEE', objBusinessHour.timezonesidkey), 'EndTime');
            system.debug(logginglevel.WARN, 'The Start Time for BH: ' + businessHourId + '(' + dtmScheduleStartTime + ') is ' + timStartTime);
            DateTime dtmStartDateTime,dtmEndDateTime;
            if(timStartTime != null && timEndTime != null){
                dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(dtmScheduleStartTime.dateGMT()), timStartTime, objBusinessHour.TimeZoneSidKey);
                dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(dtmScheduleStartTime.dateGMT()), timEndTime, objBusinessHour.TimeZoneSidKey);
            }
            //Get all Salesforce past and current events for the day related to technician
            if(setAvailTechAsSFUserList.size() > 0)
            {
                list<Event> EventList = [Select OwnerId, WhatId, StartDateTime, EndDateTime from Event where ((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (startDateTime <= :dtmStartDateTime and EndDateTime >= : dtmStartDateTime)) and StartDateTime > :dtmScheduleStartTime and OwnerId IN : setAvailTechAsSFUserList and WhatId != NULL and IsRecurrence = false];
                system.debug(logginglevel.WARN, 'The number of events for BH: ' + businessHourId + '(' + dtmStartDateTime + '-' + dtmEndDateTime + ') is ' + EventList.size());
                for(Event objEvent: EventList)
                {
                    // If it is a work order event, add the work order to the list of work orders
                    if(objEvent.WhatId != NULL && String.valueof(objEvent.WhatId).startsWith(woKeyPrefix) == TRUE)
                    {
                        list<Event> lstEvent_Tmp = new list<Event>();
                        if(!mapTechEvents.containsKey(objEvent.OwnerId))
                            mapTechEvents.put(objEvent.OwnerId, NULL);
                        if(mapTechEvents.get(objEvent.OwnerId) != NULL)
                            lstEvent_Tmp = mapTechEvents.get(objEvent.OwnerId);
                        lstEvent_Tmp.add(objEvent);
                        mapTechEvents.put(objEvent.OwnerId, lstEvent_Tmp);
                    }
                }
                //Identify latest technician work order location
                for(Id techIdSFUser: mapTechEvents.keySet())
                {
                    Datetime latestStartTime;
                    Id relatedWorkOrderId;
                    if(mapTechEvents.get(techIdSFUser) != NULL)
                    {
                        for(Event objEvent: mapTechEvents.get(techIdSFUser))
                        {
                            if(latestStartTime == NULL && objEvent.EndDateTime < dtmEndDateTime)
                            {
                                latestStartTime = objEvent.StartDateTime;
                                relatedWorkOrderId = objEvent.WhatId;
                                
                            }
                            else if(latestStartTime != NULL &&  latestStartTime < objEvent.StartDateTime && objEvent.EndDateTime < dtmEndDateTime)
                            {
                                latestStartTime = objEvent.StartDateTime;
                                relatedWorkOrderId = objEvent.WhatId;
                                
                            }
                            System.debug('relatedWorkOrderId1111 val'+relatedWorkOrderId+'  Time  '+latestStartTime);
                        }
                        system.debug(logginglevel.WARN, 'Technician: ' + techIdSFUser + ' recent start date time is ' + latestStartTime + ' and he is working on ' + relatedWorkOrderId);
                    }
                    mapTechWO.put(techIdSFUser,relatedWorkOrderId);
                    
                }
            }
            if(setAvailTechAsSVMXUserList.size() > 0)
            {
                list<SVMXC__SVMX_Event__c> SVMXEventList = [Select SVMXC__Technician__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) and SVMXC__Technician__c IN : setAvailTechAsSVMXUserList and SVMXC__WhatId__c != NULL];
                system.debug(logginglevel.WARN, 'The number of events for BH: ' + businessHourId + '(' + dtmStartDateTime + '-' + dtmEndDateTime + ') is ' + SVMXEventList.size());

                for(SVMXC__SVMX_Event__c SVMXobjEvent: SVMXEventList)
                {
                    // If it is a work order SVMXC__SVMX_Event__c, add the work order to the list of work orders
                    if(SVMXobjEvent.SVMXC__WhatId__c != NULL && String.valueof(SVMXobjEvent.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE)
                    {
                        list<SVMXC__SVMX_Event__c> lstEvent_Tmp = new list<SVMXC__SVMX_Event__c>();
                        if(!mapTechSVMXEvents.containsKey(SVMXobjEvent.SVMXC__Technician__c))
                            mapTechSVMXEvents.put(SVMXobjEvent.SVMXC__Technician__c, NULL);
                        if(mapTechSVMXEvents.get(SVMXobjEvent.SVMXC__Technician__c) != NULL)
                            lstEvent_Tmp = mapTechSVMXEvents.get(SVMXobjEvent.SVMXC__Technician__c);
                        lstEvent_Tmp.add(SVMXobjEvent);
                        mapTechSVMXEvents.put(SVMXobjEvent.SVMXC__Technician__c, lstEvent_Tmp);
                    }
                }
                
                
                for(Id techIdSFUser: mapTechSVMXEvents.keySet())
                {
                    Datetime latestStartTime;
                    Id relatedWorkOrderId;
                    string strLatLong;
                    if(mapTechSVMXEvents.get(techIdSFUser) != NULL)
                    {
                        for(SVMXC__SVMX_Event__c SVMXobjEvent: mapTechSVMXEvents.get(techIdSFUser))
                        {
                            if(latestStartTime == NULL && SVMXobjEvent.SVMXC__EndDateTime__c < dtmEndDateTime)
                            {
                                latestStartTime = SVMXobjEvent.SVMXC__StartDateTime__c;
                                relatedWorkOrderId = SVMXobjEvent.SVMXC__WhatId__c;
                                
                            }
                            else if(latestStartTime != NULL &&  latestStartTime < SVMXobjEvent.SVMXC__StartDateTime__c && SVMXobjEvent.SVMXC__EndDateTime__c < dtmEndDateTime)
                            {
                                latestStartTime = SVMXobjEvent.SVMXC__StartDateTime__c;
                                relatedWorkOrderId = SVMXobjEvent.SVMXC__WhatId__c;
                            }
                        }
                        system.debug(logginglevel.WARN, 'Technician: ' + techIdSFUser + ' recent start date time is ' + latestStartTime + ' and he is working on ' + relatedWorkOrderId);
                    }
                    if(relatedWorkOrderId != NULL)
                        mapTechWO.put(techIdSFUser,relatedWorkOrderId);
                    
                }
            }
            System.debug('Map of technician and WO obj val'+mapTechWO);
        }
    }
    
    map<id,SVMXC__Service_Order__c> mapServiceOrder = new map<id,SVMXC__Service_Order__c>();
    mapServiceOrder.putall([SELECT Id, SVMXC__Country__c, SVMXC__Zip__c, SVMXC__State__c, SVMXC__City__c, SVMXC__Street__c, SVMXC__Latitude__c,SVMXC__Longitude__c FROM SVMXC__Service_Order__c where id IN:mapTechWO.values()]);
        
    for(Id techId: mapTechWO.keyset()){
        SVMXC__Service_Order__c objWorkOrder = mapServiceOrder.get(mapTechWO.get(techId));
        if(objWorkOrder != NULL)
        {
            String address = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
            techAddress technicianAddress = new techAddress(techId, address, objWorkOrder.SVMXC__Latitude__c, objWorkOrder.SVMXC__Longitude__c);
            response.put(techId, technicianAddress);
        }
    }
    
    return response;   
}

public SMAX_OptiMax_Engine_WS.Technician_WP updateTechnicianCurrentAddress(SMAX_OptiMax_Engine_WS.Technician_WP tech, techAddress techCurrentAddress)
{
    if(techCurrentAddress != NULL && (techCurrentAddress.address != NULL || (techCurrentAddress.latitude != NULL && techCurrentAddress.longitude != NULL)))
    {
        //Get the current location from past/currently working work order
        if(techCurrentAddress.latitude != NULL && techCurrentAddress.longitude != NULL)
        {
            tech.currentLatitude = techCurrentAddress.latitude;
            tech.currentLongitude = techCurrentAddress.longitude;
        }
        else if(techCurrentAddress.address != NULL)
            tech.currentAddress = techCurrentAddress.address;
    }
    else
    {
        tech.currentAddress = tech.Address;
        tech.currentLatitude = tech.latitude;
        tech.currentLongitude = tech.longitude;
    }
    return tech;
}

public String getRunType(BusinessHours objDefTerritoryBH, Boolean isFullRun)
{
    if(isFullRun)
    {
        Datetime dtmNow = system.now();
        Datetime dtmNextWorkingHour = BusinessHours.addGmt(objDefTerritoryBH.id, dtmNow, 1L);
        system.debug('Current Time: ' + dtmNow);
        system.debug('Next Time: ' + dtmNextWorkingHour);
        if(dtmNow.addSeconds(60) >= dtmNextWorkingHour)
            return 'JOBTYPE.FULL_INTRADAY';
        else
            return 'JOBTYPE.FULL_OVERNIGHT';
    }
    else
    {
        return 'JOBTYPE.INCREMENTAL';
    }
}


public void buildSkills(list<SVMXC__Service_Order__c> lstWorkOrder)
{
    system.debug('Start of Skill computation: No of Queries used in this apex code so far: ' + Limits.getQueries());
    map<integer, SVMXC__Service_Order__c> mapWorkOrders = new map<integer, SVMXC__Service_Order__c>();
    map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxAllSkillMatchRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxSkillMatchRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    map<Id, list<SVMXC__ServiceMax_Processes__c>> mapOMaxSkillMatchRulesChildrens = new map<Id, list<SVMXC__ServiceMax_Processes__c>>();
    map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxAllSkillMatchRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxSkillMatchRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    map<integer, Id> mapWorkOrderRule = new map<integer, Id>();
    map<Id, list<skill>> mapRequiredSkills = new map<Id, list<skill>>();
    list<Id> lstAllMatchedRules = new list<Id>();
    map<Id, Id> mapChildRuleToParentRule = new map<Id, Id>();
    map<integer, list<skill>> mapWorkOrderMatchedSkills = new map<integer, list<skill>>();
    mapOMaxAllSkillMatchRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c, SVMXC__Node_Parent__c, SVMXC__Primary_Consolidation_Rule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Skill Matching' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
    system.debug('buildSkills::mapOMaxAllSkillMatchRules: '+mapOMaxAllSkillMatchRules);
    integer iIndex = 0;
    for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder){
        mapWorkOrders.put(iIndex, objWorkOrder);
        iIndex++;
    }
    
    for(SVMXC__ServiceMax_Processes__c rule: mapOMaxAllSkillMatchRules.values()){
        if(rule.SVMXC__Node_Parent__c == NULL)
            mapOMaxSkillMatchRules.put(rule.Id, rule);
        else{
            list<SVMXC__ServiceMax_Processes__c> lstRules = new list<SVMXC__ServiceMax_Processes__c>();
            if(!mapOMaxSkillMatchRulesChildrens.containsKey(rule.SVMXC__Node_Parent__c))
                mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, NULL);
            if(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c) != NULL)
                lstRules.addAll(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c));
            lstRules.add(rule);
            mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, lstRules);
        }
    }
    
    mapOMaxAllSkillMatchRulesExpression = getWorkOrderExpression(mapOMaxAllSkillMatchRules,  'Skill_Eligibility');
    system.debug('buildSkills:mapOMaxAllSkillMatchRulesExpression - ' + mapOMaxAllSkillMatchRulesExpression);
    for(Id ruleId: mapOMaxSkillMatchRules.keySet()){
        mapOMaxSkillMatchRulesExpression.put(ruleId, mapOMaxAllSkillMatchRulesExpression.get(ruleId));
    }
    
    system.debug(logginglevel.WARN,'lstWorkOrder: ' + lstWorkOrder);
    system.debug(logginglevel.WARN,'mapOMaxSkillMatchRulesExpression: ' + mapOMaxSkillMatchRulesExpression);
    // Get the list of all valid Skill Match rules
    mapWorkOrderRule = parseWorkOrderExprForSkills(lstWorkOrder, mapOMaxSkillMatchRules, mapOMaxSkillMatchRulesExpression);
    system.debug('buildSkills::mapWorkOrderRule: '+mapWorkOrderRule);
    //For each Work Order Matched, get all child Rules and Find the Expression Match
    map<integer, set<Id>> mapMatchedWorkOrderSkills = new map<integer, set<Id>>();
    for(integer iWOIndex: mapWorkOrderRule.keySet()){
        set<Id> setMatchedRules = new set<Id>();
        Id parentRule = mapWorkOrderRule.get(iWOIndex);
        if(mapOMaxSkillMatchRulesChildrens.containsKey(parentRule) && mapOMaxSkillMatchRulesChildrens.get(parentRule) != NULL){
            list<SVMXC__ServiceMax_Processes__c> lstChildRules = mapOMaxSkillMatchRulesChildrens.get(parentRule);
            map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxSkillMatchRules2 = new map<Id, SVMXC__ServiceMax_Processes__c>();
            map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxSkillMatchRulesExpression2 = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
            for(SVMXC__ServiceMax_Processes__c childRule: lstChildRules){
                mapOMaxSkillMatchRules2.put(childRule.Id, childRule);
                if(mapOMaxAllSkillMatchRulesExpression.containsKey(childRule.Id))
                    mapOMaxSkillMatchRulesExpression2.put(childRule.Id, mapOMaxAllSkillMatchRulesExpression.get(childRule.Id));
            }
            setMatchedRules = clsUtils4.SVMX_GetChildMatchingExpression((SObject)mapWorkOrders.get(iWOIndex), mapOMaxSkillMatchRulesExpression2, mapOMaxSkillMatchRules2); //#defectFix 047252
            system.debug(logginglevel.WARN,'Parent Rule: ' + parentRule + 'Chile Rules: ' + mapOMaxSkillMatchRules2.keySet());
            system.debug(logginglevel.WARN,'setMatchedRules: ' + setMatchedRules);
            for(Id matchedRuleId: setMatchedRules)
            {
                mapChildRuleToParentRule.put(matchedRuleId, parentRule);
            }
            if(setMatchedRules != NULL)
            {
                lstAllMatchedRules.addAll(setMatchedRules);
            }
        }
        //Add all matched skill matching rule Id for work order
        setMatchedRules.add(parentRule);
        mapMatchedWorkOrderSkills.put(iWOIndex, setMatchedRules);
    }
    lstAllMatchedRules.addAll(mapWorkOrderRule.values());
    system.debug('buildSkills::mapMatchedWorkOrderSkills: '+mapMatchedWorkOrderSkills);
    system.debug(logginglevel.WARN,'lstAllMatchedRules: ' + lstAllMatchedRules);
    list<SVMXC__ServiceMax_Config_Data__c> lstSkillMatches = [Select SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Minimum_Level__c, SVMXC__Required__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Applicable Skills' and SVMXC__Expression_Rule__c IN: lstAllMatchedRules and SVMXC__Skill__r.SVMXC__Active__c = true];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    set<Id> setRequiredSkills = new set<Id>();
    for(SVMXC__ServiceMax_Config_Data__c skillMatches: lstSkillMatches)
    {
        list<skill> wrpSkillValues = new list<skill>();
        //skillMatches.SVMXC__Expression_Rule__c = mapChildRuleToParentRule.containsKey(skillMatches.SVMXC__Expression_Rule__c) ? mapChildRuleToParentRule.get(skillMatches.SVMXC__Expression_Rule__c) : skillMatches.SVMXC__Expression_Rule__c;
        if(!mapRequiredSkills.containsKey(skillMatches.SVMXC__Expression_Rule__c))
            mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, NULL);
        
        if(mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c) != NULL)
            wrpSkillValues = mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c);
        if(skillMatches.SVMXC__Minimum_Level__c == NULL)
            skillMatches.SVMXC__Minimum_Level__c = 0;
        wrpSkillValues.add(new skill(skillMatches.SVMXC__Skill__c, skillMatches.SVMXC__Skill__r.Name, skillMatches.SVMXC__Required__c, (skillMatches.SVMXC__Minimum_Level__c).intValue()));
        setRequiredSkills.add(skillMatches.SVMXC__Skill__c);
        mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, wrpSkillValues);
    }
    
    for(integer iWOIndex: mapWorkOrders.keySet())
    {
        Integer expectedOptionalSkillCount = 0;
        //Getting matched skills for work order
        list<skill> lstMatchedWOSkills = new list<skill>();
        if(mapMatchedWorkOrderSkills != NULL && mapMatchedWorkOrderSkills.containsKey(iWOIndex) && mapMatchedWorkOrderSkills.get(iWOIndex) != NULL)
        {
            for(Id matchedRule: mapMatchedWorkOrderSkills.get(iWOIndex))
            {
                list<skill> setMatchedSkills = mapRequiredSkills.get(matchedRule);
                if(setMatchedSkills != NULL)
                    lstMatchedWOSkills.addAll(setMatchedSkills);
            }
        }
        else
            continue;
        
        if(mapWorkOrderRule.containsKey(iWOIndex) && mapWorkOrderRule.get(iWOIndex) != NULL && lstMatchedWOSkills.size() > 0)
        {
            lstMatchedWOSkills = makeUniqueSkillList(lstMatchedWOSkills);
            mapWorkOrderMatchedSkills.put(iWOIndex, lstMatchedWOSkills);
         }
    
    }
    system.debug('buildSkills::mapWorkOrderMatchedSkills: '+mapWorkOrderMatchedSkills);
        //Update the Work Order with the Skill information
        for(integer iWO: mapWorkOrders.keySet()){
            if(mapWorkOrderMatchedSkills != NULL && mapWorkOrderMatchedSkills.containsKey(iWO) && mapWorkOrderMatchedSkills.get(iWO) != NULL){
                mapWorkOrders.get(iWO).SVMXC__Skill_Set__c = JSON.serialize(mapWorkOrderMatchedSkills.get(iWO));
            }
         }
    system.debug('SOQL already executed after Skill computation(end of buildSkills()) : ' + Limits.getAggregateQueries());
    system.debug('End of Skill computation: No of Queries used in this apex code so far: ' + Limits.getQueries());
    // WSCH_AuditLogger.finish();
    }
    
    public static List<SMAX_OptiMax_Engine_WS.Expertise_WP> fetchSkills(SVMXC__Service_Order__c workOrder)
    {
        List<SMAX_OptiMax_Engine_WS.Expertise_WP> lstSkills = new List<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        if(workOrder != null && String.isNotEmpty(workOrder.SVMXC__Skill_Set__c)) {
            Skill[] skills = (List<Skill>)JSON.deserialize(workOrder.SVMXC__Skill_Set__c,List<Skill>.class);
            for(Skill s : skills){
                SMAX_OptiMax_Engine_WS.Expertise_WP expertise = new SMAX_OptiMax_Engine_WS.Expertise_WP();
                if(s.isSkillMandatory){
                    expertise.id=s.skillId;
                    expertise.level=s.skillLevel;
                    lstSkills.add(expertise);
                }
            }
        }
        return lstSkills;
    }

    // public static String fetchSkills(SVMXC__Service_Order__c workOrder)
    // {
    //     //Parse the skillSet which is in JSON format and extract the skillName and skillLevel from it
    //     String skills;
    //     system.debug('SMAX_OptiMax_EngineUtils::fetchSkills()::Skill set in WO: - '+workOrder.SVMXC__Skill_Set__c);
    //     if(workOrder != null && String.isNotEmpty(workOrder.SVMXC__Skill_Set__c)) {
    //         JSONParser parser = JSON.createParser(workOrder.SVMXC__Skill_Set__c);
    //         String skillName,skillRequired;
    //         while(parser.nextToken() != null)
    //         {
    //             String skill;
    //             if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_ECO_Constants.STR_SKILL_NAME)) {
    //                 //extract the skillName
    //                 parser.nextToken();
    //                 skillName = parser.getText();
    //             }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_ECO_Constants.STR_SKILL_ID)) {
    //                 //extract the skillId
    //                 if(String.isNotEmpty(skillName)){
    //                     parser.nextToken();
    //                     skillRequired = parser.getText(); //send only skillId
    //                 }
    //             }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_ECO_Constants.STR_SKILL_ISMANDATORY)) {
    //                 if(String.isNotEmpty(skillRequired)){
    //                     parser.nextToken();
    //                     if(parser.getText() == 'true'){
    //                         skill=skillRequired; 
    //                     }
    //                 }
    //             }
    //             if(String.isNotEmpty(skill)){
    //                 if(String.isNotEmpty(skills)){
    //                     skills=skills+','+skill;
    //                 }else{
    //                     skills=skill;
    //                 }
    //             }
    //             system.debug('SMAX_OptiMax_EngineUtils::fetchSkills()::Skill set in WO: - '+workOrder.SVMXC__Skill_Set__c);
    //         }
    //     }
    //     system.debug('SMAX_OptiMax_EngineUtils::fetchSkills(): - '+skills);
    //     // WSCH_AuditLogger.finish();
    //     return skills;
    // }
    
    public static Map<String, List<SMAX_OptiMax_Engine_WS.Expertise_WP>> getTechSkillMap(List<SVMXC__Service_Group_Members__c> lstTechs){
        Map<String, List<SMAX_OptiMax_Engine_WS.Expertise_WP>> mapTechIdSkills = new Map<String, List<SMAX_OptiMax_Engine_WS.Expertise_WP>>();
        set<Id> setTechIds = new set<Id>();
        for(SVMXC__Service_Group_Members__c tech : lstTechs){
            setTechIds.add(tech.Id);
        }
        List<SVMXC__Service_Group_Skills__c> lstTechSkills = [SELECT Id,IsDeleted,Name,SVMXC__Group_Member__c,SVMXC__Skill__r.Id, SVMXC__Skill__r.Name,SVMXC__Skill__r.SVMXC__Active__c, SVMXC__Availability_Start_Date__c, SVMXC__Availability_End_Date__c,SVMXC__Skill_Level__c FROM SVMXC__Service_Group_Skills__c WHERE SVMXC__Group_Member__c in :setTechIds AND IsDeleted = false AND SVMXC__Skill__r.SVMXC__Active__c = true];
        //system.debug('SMAX_OptiMax_EngineUtils::getTechSkillMap():: lstTechSkills' +lstTechSkills);
        for(SVMXC__Service_Group_Skills__c groupSkill : lstTechSkills){
            //String skillName = groupSkill.Name+'_'+groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name;
            SMAX_OptiMax_Engine_WS.Expertise_WP techSkill = new SMAX_OptiMax_Engine_WS.Expertise_WP();
            techSkill.id = groupSkill.SVMXC__Skill__r.Id;
            techSkill.level = integer.valueOf(groupSkill.SVMXC__Skill_Level__c);
            techSkill.validFrom = groupSkill.SVMXC__Availability_Start_Date__c;
            techSkill.validTo = groupSkill.SVMXC__Availability_End_Date__c;
            if(!mapTechIdSkills.containsKey(groupSkill.SVMXC__Group_Member__c))
                mapTechIdSkills.put(groupSkill.SVMXC__Group_Member__c, new List<SMAX_OptiMax_Engine_WS.Expertise_WP>());
            
            mapTechIdSkills.get(groupSkill.SVMXC__Group_Member__c).add(techSkill);
        }
        return mapTechIdSkills;
    }

    public static void constructExecTimeWindows(DateTime tempStartDateTime, DateTime tempEndDateTime, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstWOTimeWindows,
                    Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapWrkOrdrTimeWindows, SVMXC__Service_Order__c objWorkOrder, BusinessHours objDefTerritoryBH) {
        
        system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): tempStartDateTime: ' + tempStartDateTime + ' tempEndDateTime: '+ tempEndDateTime);

        Date tempStartDate = Date.valueOf(tempStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date tempEndDate = Date.valueOf(tempEndDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        
        Integer intSLADays = tempStartDate.daysBetween(tempEndDate);
        system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): Work order with SLA; BH: ' + objDefTerritoryBH.id + '; Start date: ' + tempStartDate + '; End date: ' + tempEndDate + '; SLA Days: ' + intSLADays + '; WO Preferred Start: ' + tempStartDateTime + '; WO Preferred End: ' + tempEndDateTime);
        
        // Get the execution time windows in the SLA time window range
        for(Integer i = 0; i <= intSLADays; i++)
        {
            if(mapWrkOrdrTimeWindows.containsKey(tempStartDate.addDays(i)) && mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)) != NULL)
            {
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpExecTime = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                wrpExecTime.startDateTime = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).startDateTime;
                wrpExecTime.endDateTime = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).endDateTime;
                                
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():current date - ' + tempStartDate.addDays(i));
            
                if(i==0) {
                    if(tempStartDateTime > wrpExecTime.endDateTime) {
                        system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): skipping wrapper creation as PST > BH End');
                        continue;
                    } else if(tempEndDateTime < wrpExecTime.startDateTime) {
                        system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): skipping wrapper creation as PET < BH Start');
                        continue;
                    } 
                    //checking if PST(tempStartDateTime is within BH start and end). If so set the PST as the start of the BH
                    else if(tempStartDateTime > wrpExecTime.startDateTime && tempStartDateTime < wrpExecTime.endDateTime) {
                        wrpExecTime.startDateTime = tempStartDateTime;

                        //check if PET(tempEndDateTime) is within the BH endTime. If so set PET as the end of the BH
                        if(tempEndDateTime < wrpExecTime.endDateTime) {
                            wrpExecTime.endDateTime = tempEndDateTime;
                        }
                        if(wrpExecTime.startDateTime < wrpExecTime.endDateTime) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);
                        continue;
                    } else if(tempEndDateTime < wrpExecTime.endDateTime && tempEndDateTime > wrpExecTime.startDateTime) {
                        wrpExecTime.endDateTime = tempEndDateTime;

                        //check if PST(tempStartDateTime) is after the BH startTime. If so set PST as the start of the BH
                        if(tempStartDateTime > wrpExecTime.startDateTime) {
                            wrpExecTime.startDateTime = tempStartDateTime;
                        }
                        if(wrpExecTime.startDateTime < wrpExecTime.endDateTime) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);
                        continue;
                    }
                }

                //This is the case of last date
                if(tempStartDate.addDays(i) == tempEndDate) {
                    if(tempEndDateTime < wrpExecTime.endDateTime && tempEndDateTime > wrpExecTime.startDateTime) {
                        wrpExecTime.endDateTime = tempEndDateTime;
                        if(wrpExecTime.startDateTime < wrpExecTime.endDateTime) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');                        
                    } else if(tempEndDateTime < wrpExecTime.startDateTime) {
                        system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): skipping wrapper creation as PET < BH Start');
                        continue;
                    } else {
                        lstWOTimeWindows.add(wrpExecTime);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');                        
                    }
                } 
                //This is the case of intermediate days(within first and last date of horizon)
                else {
                    lstWOTimeWindows.add(wrpExecTime);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');                    
                }
                system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);              
            }
        } 
    }
    
    //commented the below methos and introduced the refactored method above
    //Below method construct the execution time windows based on the horizon dates passed to it
    /*public static void constructExecTimeWindows(DateTime tempStartDateTime, DateTime tempEndDateTime, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstWOTimeWindows,
                    Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapWrkOrdrTimeWindows, SVMXC__Service_Order__c objWorkOrder, BusinessHours objDefTerritoryBH) {
        
        system.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): tempStartDateTime: ' + tempStartDateTime + ' tempEndDateTime: '+ tempEndDateTime);
        
        Date tempStartDate = Date.valueOf(tempStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date tempEndDate = Date.valueOf(tempEndDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        
        Integer intSLADays = tempStartDate.daysBetween(tempEndDate);
        //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): Work order with SLA; BH: ' + objDefTerritoryBH.id + '; Start date: ' + tempStartDate + '; End date: ' + tempEndDate + '; SLA Days: ' + intSLADays + '; WO Preferred Start: ' + tempStartDateTime + '; WO Preferred End: ' + tempEndDateTime);
        
        // Get the execution time windows in the SLA time window range
        for(Integer i = 0; i <= intSLADays; i++)
        {
            if(mapWrkOrdrTimeWindows.containsKey(tempStartDate.addDays(i)) && mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)) != NULL)
            {
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpExecTime = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                wrpExecTime.startDateTime = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).startDateTime;
                wrpExecTime.endDateTime = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).endDateTime;
                
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);
                
                if(intSLAdays == 0 && tempStartDateTime > wrpExecTime.startDateTime && tempStartDateTime > wrpExecTime.endDateTime){
                    //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                    //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);
                    lstWOTimeWindows.add(wrpExecTime);
                    continue;
                }
                //If it is a first date and PST is present in the WO and if it is later than the BusinessHour startTime for that day, consider
                //PST as the startDateTime for that day
                if(i==0 && tempStartDateTime > wrpExecTime.startDateTime && tempStartDateTime < wrpExecTime.endDateTime) {
                    wrpExecTime.startDateTime = tempStartDateTime;
                }
                
                if(tempStartDate.addDays(i) == tempEndDate)
                {
                    //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows(): Time window for the date ' + tempStartDate.addDays(i) + ': ' + wrpExecTime);
                    // This is the last time window; can also be the first & last time window
                    if(objWorkOrder.SVMXC__Preferred_End_Time__c != null && objWorkOrder.SVMXC__Preferred_End_Time__c > wrpExecTime.startDateTime)
                    {
                        // Take the earliest end date time
                        if(objWorkOrder.SVMXC__Preferred_End_Time__c < wrpExecTime.endDateTime)
                            wrpExecTime.endDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                        
                        // Take this time window if it is valid, i.e., start < end
                        if(wrpExecTime.startDateTime < wrpExecTime.endDateTime) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                            
                    } else {
                        lstWOTimeWindows.add(wrpExecTime);  //newly added. When PET is null then also we should add the execTimeWindows as we consider HorizonEndDate
                                                            //in place of PET
                    }
                }
                else {
                    lstWOTimeWindows.add(wrpExecTime);
                }
                
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.startDateTime - ' + wrpExecTime.startDateTime);
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():wrpExecTime.endDateTime - ' + wrpExecTime.endDateTime);  
             }
         }
         //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_WS::constructExecTimeWIndows():lstWOTimeWindows - '+ lstWOTimeWindows);
    }*/
    
public class OMAX_MultiCriteriaTechMatch {

    private COMM_SVMXC_Utils4 clsUtils4 = new COMM_SVMXC_Utils4();
    private COMM_Utils utils = new COMM_Utils();
    String MSG_QTLCOMPUTED = 'Qualified Technician List Computed';
    String MSG_QTLCOMPUTED_NOTECH_ALLOW = 'No Qualified Technicians (Allow)';
    String MSG_QTLCOMPUTED_NOTECH_DISALLOW = 'No Qualified Technicians (Disallow)';
    String MSG_QTLCOMPUTED_NOTECH_WARN = 'No Qualified Technicians (Warn)';
    String strEligibilityMatchSays = 'ALLOW';
    String strSkillMatchSays = 'ALLOW';
    String strMCTMenabled = 'False';
    Integer defaultPreferredTechnicianScore = 10;
    Integer defaultProductSpecializationScore = 10;
    Integer defaultEligibilityScore = 10;
    Integer defaultSkillScore = 10;
    set<Id> setNonQualifiedWorkOrdersAllow = new set<Id>();
    set<Id> setNonQualifiedWorkOrdersDisallow = new set<Id>();
    map<Id, list<skill>> mapWorkOrderMatchedSkills = new map<Id, list<skill>>();
    map<Id, Integer> mapWorkOrderRequiredSkillCount = new map<Id, Integer>();
    map<Id, Integer> mapWorkOrderOptionalSkillCount = new map<Id, Integer>();
    map<Id, set<Id>> mapMandatoryMatchedSkills = new map<Id, set<Id>>();
    
    Map<Id, List<Id>> mapWOResMand = new Map<Id, List<Id>>();
    Map<Id, List<Id>> mapWOResPref = new Map<Id, List<Id>>();
    Map<Id, List<Id>> mapWOResExcl = new Map<Id, List<Id>>();

    map<Id, SVMXC__ServiceMax_Processes__c> mapWORuleName = new map<Id, SVMXC__ServiceMax_Processes__c>();
    
    /**
        Following method calculate QTL for the work orders when insert.
     **/ 
    public map<Id, SVMXC__Service_Order__c> buildQualifiedTechnicians(list<SVMXC__Service_Order__c> lstWorkOrders, map<string, Map<String, String>> svmxSettingList,set<String> setTerritoryIds, map<Id, SVMXC__ServiceMax_Processes__c> mapOmaxDispatchProcess)
    {    
        list<String> lstWorkOrderFields = new list<String>();
        list<String> lstTechniciansFields = new list<String>();
        map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
        map<Id, Id> mapPreferredTechnicians = new map<Id, Id>();
        map<Id, set<Id>> mapProductSpecialist = new map<Id, set<Id>>();
        map<Id, map<Id, list<skill>>> mapTechnicianSkill = new map<Id, map<Id, list<skill>>>();
        map<Id, list<stachRank>> mapWorkOrderStackRank = new map<Id, list<stachRank>>();
        map<Id, SVMXC__Service_Order__c> mapServiceOrder = new map<Id, SVMXC__Service_Order__c>();
        map<Id, SVMXC__Service_Order__c> mapWorkOrders = new map<Id, SVMXC__Service_Order__c>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapWorkOrdersDP = new map<Id, SVMXC__ServiceMax_Processes__c>();

    
        Integer intLimitCpuTime = Limits.getLimitCpuTime();
        Integer intLimitHeapSize = Limits.getLimitHeapSize();

        try{
            system.debug('QTL computation starts......');
            system.debug('Start of QTL computation: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            //integer iIndex = 0;
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrders){
                //mapWorkOrders.put(iIndex, objWorkOrder);
                //mapWorkOrdersDP.put(iIndex, mapOmaxDispatchProcess.get(objWorkOrder.SVMXC__Dispatch_Process__c));
                //iIndex++;
                mapWorkOrders.put(objWorkOrder.Id, objWorkOrder);
                mapWorkOrdersDP.put(objWorkOrder.Id, mapOmaxDispatchProcess.get(objWorkOrder.SVMXC__Dispatch_Process__c));
            }
            
            //Checking MCTM is enabled OMAX001_SET014
            if(svmxSettingList.containsKey('OMAX001') && svmxSettingList.get('OMAX001') != null && svmxSettingList.get('OMAX001').size() > 0){
                map<String, String> mapEachSetting = new map<String, String>();
                mapEachSetting = svmxSettingList.get('OMAX001');
                system.debug('MCTM Enabled  = ' + mapEachSetting.get('SET014'));
                if(mapEachSetting.containsKey('SET014') && mapEachSetting.get('SET014') != null){
                    strMCTMenabled = mapEachSetting.get('SET014');
                }
            }
            if(strMCTMenabled.equalsIgnoreCase('False')){
                system.debug('MCTM Disabled...');
                return mapServiceOrder;
            }    
            
            //Fetching settings
            if(svmxSettingList.containsKey('OMAX003') && svmxSettingList.get('OMAX003') != null && svmxSettingList.get('OMAX003').size() > 0)
            {
                map<String, String> mapEachSetting = new map<String, String>();
                mapEachSetting = svmxSettingList.get('OMAX003');
                system.debug('mapEachSetting = ' + mapEachSetting.get('SET045'));
                if(mapEachSetting.containsKey('SET045') && mapEachSetting.get('SET045') != null){
                    strSkillMatchSays=mapEachSetting.get('SET045');
                }
        
                system.debug('mapEachSetting = ' + mapEachSetting.get('SET046'));
                if(mapEachSetting.containsKey('SET046') && mapEachSetting.get('SET046') != null){
                    strEligibilityMatchSays=mapEachSetting.get('SET046');
                }
            }
            
            //MPX logic:Populates a map with WorkOrder resource preference from the above qualified work orders
            getWorkOrderResourcePreference(lstWorkOrders);
            system.debug('Workorder Resource Mandatory..: ' + mapWOResMand);
            system.debug('Workorder Resource Preferred...: ' + mapWOResPref);
            system.debug('Workorder Resource Prohibited...: ' + mapWOResExcl);
            //Fetching all technicians territory wise
            String querySelect;
            lstTechniciansFields = getFieldDefinition(Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap());    
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechniciansFields); //Convert the list of strings to coma seperated string
            list<SVMXC__Service_Group_Members__c> lstTechnicians = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Active__c = true and SVMXC__Service_Territory__c =:setTerritoryIds');
            set<Id> setTechnicianIds = new set<Id>();
            
            map<Id, String> mapTechNames = new map<Id, String>(); 
            for(SVMXC__Service_Group_Members__c objTechnicians: lstTechnicians)
            {
                setTechnicianIds.add(objTechnicians.Id);
                mapTechNames.put(objTechnicians.Id, objTechnicians.Name);
            }
            
            system.debug('Before Find Technician Eligibility score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            // Find Technician Eligibility score
            mapMatchedEligibilityScore = buildTechnicianEligibilityScore(mapWorkOrders, lstTechnicians);
            system.debug('After Find Technician Eligibility score results: ' + mapMatchedEligibilityScore);
            system.debug('After Find Technician Eligibility score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            //system.debug(logginglevel.WARN, system.now() + ': Usage Details: After buildTechnicianEligibilityScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            
            system.debug('Before Find Preferred Technician score: No of Queries used in this apex code so far: ' + Limits.getQueries());        
            // Find Preferred Technician score
            mapPreferredTechnicians = buildPreferredTechnicianScore(mapWorkOrders, setTechnicianIds);
            system.debug('After Find Preferred Technician score results: ' + mapPreferredTechnicians);
            system.debug('After Find Preferred Technician score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            system.debug('Before Find Product Specialization score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            // Find Product Specialization score
            //system.debug(logginglevel.WARN, system.now() + ': Usage Details: After buildPreferredTechnicianScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            mapProductSpecialist = buildProductSpecialScore(mapWorkOrders, setTechnicianIds);
            system.debug('After Find Product Specialization score results: ' + mapProductSpecialist);
            system.debug('After Find Product Specialization score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            system.debug('Before Find Technicians Skill score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            // Find Technicians Skill score
            //system.debug( system.now() + ': Usage Details: After buildProductSpecialScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            mapTechnicianSkill = buildSkillScore(mapWorkOrders, setTechnicianIds);
            system.debug('After Find Technicians Skill score results: ' + mapTechnicianSkill);
            system.debug('After Find Technicians Skill score: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            //system.debug(logginglevel.WARN, system.now() + ': Usage Details: After buildSkillScore\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            
            // Build Work Order Qualified Technician List from above scores
            //for(integer iWOIndex: mapWorkOrders.keySet())
            for(Id iWOIndex: mapWorkOrders.keySet())
            {
                List<Id> lstMandTech;
                Set<Id> setMandTechIds;
                List<Id> lstExclTech;
                Set<Id> setExclTechIds;

                //create set of mandatory technician ids from map created using MPX list.            
                if(!mapWOResMand.isEmpty()){
                    lstMandTech=mapWOResMand.get(iWOIndex);
                    if(lstMandTech != null)
                        setMandTechIds = new set<Id>(lstMandTech);
                    system.debug('buildQualifiedTechnicians::Mandatory Technicians...: ' + setMandTechIds);
                }
                //create set of Prohibited technician ids from map created using MPX list.            
                if(!mapWOResExcl.isEmpty()){
                    lstExclTech=mapWOResExcl.get(iWOIndex);
                    if(lstExclTech != null)
                        setExclTechIds = new set<Id>(lstExclTech);
                    system.debug('buildQualifiedTechnicians::Prohibited Technicians...: ' + setExclTechIds);
                }               
                
                getDispatchProcessScores(mapWorkOrdersDP.get(iWOIndex));
                system.debug('buildQTL::Default Score from DP: Pref. Tech- '+defaultPreferredTechnicianScore+'  Product Spl-'+defaultProductSpecializationScore+'  Eligibility -'+defaultEligibilityScore+'  Skill-'+defaultSkillScore);              
                mapServiceOrder.put(iWOIndex, mapWorkOrders.get(iWOIndex));
                Integer intOptionalSkillCount = 0;
                Integer intRequiredSkillCount = 0;   //Jyothsna
                if(mapWorkOrderOptionalSkillCount.containsKey(iWOIndex) && mapWorkOrderOptionalSkillCount.get(iWOIndex) != NULL)
                    intOptionalSkillCount = mapWorkOrderOptionalSkillCount.get(iWOIndex);
                //Jyothsna
                if(mapWorkOrderRequiredSkillCount.containsKey(iWOIndex) && mapWorkOrderRequiredSkillCount.get(iWOIndex) != NULL)
                    intRequiredSkillCount = mapWorkOrderRequiredSkillCount.get(iWOIndex);
                if(mapMatchedEligibilityScore.containsKey(iWOIndex) || mapPreferredTechnicians.containsKey(iWOIndex) || mapProductSpecialist.containsKey(iWOIndex) || mapTechnicianSkill.containsKey(iWOIndex) || setExclTechIds != null)
                {
                    set<Id> setEligibleTechnicians = new set<Id>();
                    set<Id> setProductSpecialist = new set<Id>();
                    map<Id, list<skill>> mapTechSkills = new map<Id, list<skill>>();
                    set<Id> setMatchedRequiredTechs = new set<Id>();
                    id idPreferredTechnician;
                    if(mapMatchedEligibilityScore.containsKey(iWOIndex))
                        setEligibleTechnicians = mapMatchedEligibilityScore.get(iWOIndex);
                    if(mapPreferredTechnicians.containsKey(iWOIndex))
                        idPreferredTechnician = mapPreferredTechnicians.get(iWOIndex);
                    if(mapProductSpecialist.containsKey(iWOIndex))
                        setProductSpecialist = mapProductSpecialist.get(iWOIndex);
                    if(mapTechnicianSkill.containsKey(iWOIndex))
                        mapTechSkills = mapTechnicianSkill.get(iWOIndex);
                    if(mapMandatoryMatchedSkills.containsKey(iWOIndex))
                        setMatchedRequiredTechs = mapMandatoryMatchedSkills.get(iWOIndex);
                    
                    system.debug('Eligibile Technicians - '+setEligibleTechnicians+'  Preferred Technicians -'+idPreferredTechnician+'  Product Expert Technicians -'+setProductSpecialist+'  Skilled Technicians -'+mapTechSkills+'  Match Technicians -'+setMatchedRequiredTechs);    
                    system.debug(logginglevel.warn, 'setMatchedRequiredTechs: ' + setMatchedRequiredTechs);
                    
                    //set Eligibility Technician Rule name for the work order into stack rank object
                    String eligibleRuleName='';
                    if(mapWORuleName != null && mapWORuleName.size() > 0){
                        SVMXC__ServiceMax_Processes__c techMatchRule = mapWORuleName.get(iWOIndex);
                        eligibleRuleName = techMatchRule.SVMXC__Name__c;
                    }
                                        
                    list<stachRank> lstTechnicianStackRanks = new list<stachRank>(); 
                    for(Id techId: setTechnicianIds)
                    {
                        stachRank clsStackRank = new stachRank();
                        clsStackRank.eligibleRuleName = eligibleRuleName;
                        if(setMandTechIds != null){
                            clsStackRank.prefType='Mandatory';
                        }else if(setExclTechIds != null && setExclTechIds.contains(techId)){
                            clsStackRank.prefType='Prohibited';
                        }else{
                            clsStackRank.prefType='Preferred';
                        }
                        clsStackRank.tech = techId;
                        clsStackRank.tName = mapTechNames.get(techId);
                        if(setEligibleTechnicians != NULL && setEligibleTechnicians.contains(techId))
                            clsStackRank.eligible = 1;
                        if(setProductSpecialist != NULL && setProductSpecialist.contains(techId))
                            clsStackRank.prod = 1;
                        if(idPreferredTechnician != NULL && idPreferredTechnician == techId)
                            clsStackRank.prefTech = 1;
                        if(mapTechSkills != NULL && mapTechSkills.containsKey(techId))
                        {
                            integer intOptionalSkillScore = 0;
                            if(setMatchedRequiredTechs != NULL && setMatchedRequiredTechs.contains(techId))
                                clsStackRank.skillR = defaultSkillScore;  // if has all required skill provide the the Score (from settings)
                            //jyothsna
                            if(intRequiredSkillCount == 0 || intRequiredSkillCount >0 && setMatchedRequiredTechs != null && setMatchedRequiredTechs.contains(techId))
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
                              
                            /*for(skill objSkill: mapTechSkills.get(techId))
                            {
                                if(!objSkill.isSkillMandatory)
                                    intOptionalSkillScore++;
                            }
                            if(intOptionalSkillCount > 0)
                            {
                                clsStackRank.skillO = ((decimal)(intOptionalSkillScore * defaultSkillScore)).divide(intOptionalSkillCount, 2);
                            }
                            else
                                clsStackRank.skillO = 0;*/ 
                        }
                        lstTechnicianStackRanks.add(clsStackRank);
                    }
                    mapWorkOrderStackRank.put(iWOIndex, lstTechnicianStackRanks);
                }
                else
                {
                    mapWorkOrderStackRank.put(iWOIndex, new list<stachRank>());
                }
            }
            system.debug('Before ScoreProcessor: Work Orders stack ranks Results: ' + mapWorkOrderStackRank);
            mapWorkOrderStackRank = scoreProcessor(mapWorkOrderStackRank, mapWorkOrdersDP);
            system.debug('After ScoreProcessor: Work Orders stack ranks Results : ' + mapWorkOrderStackRank);
            //Update the Work Order with the Qualified Technician and Skill information
            for(Id iWO: mapWorkOrderStackRank.keySet())
            {
                mapServiceOrder.get(iWO).SVMXC__Qualified_Technicians__c = JSON.serialize(mapWorkOrderStackRank.get(iWO));
                if(setNonQualifiedWorkOrdersAllow.contains(iWO))
                    mapServiceOrder.get(iWO).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED_NOTECH_ALLOW;
                else if(setNonQualifiedWorkOrdersDisallow.contains(iWO))
                    mapServiceOrder.get(iWO).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED_NOTECH_DISALLOW;
                else
                    mapServiceOrder.get(iWO).SVMXC__QTL_Status__c = MSG_QTLCOMPUTED; 
                if(mapWorkOrderMatchedSkills != NULL && mapWorkOrderMatchedSkills.containsKey(iWO) && mapWorkOrderMatchedSkills.get(iWO) != NULL)
                    mapServiceOrder.get(iWO).SVMXC__Skill_Set__c = JSON.serialize(mapWorkOrderMatchedSkills.get(iWO));
            }
            system.debug('End of QTL computation: No of Queries used in this apex code so far: ' + Limits.getQueries());
            //WSCH_AuditLogger.finish();
            
        }catch(Exception ex){
            system.debug('Exception Occured while QTL computation: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return mapServiceOrder;
    }

    public map<Id, set<Id>> buildTechnicianEligibilityScore(map<Id, SVMXC__Service_Order__c> mapWorkOrders, list<SVMXC__Service_Group_Members__c> lstTechnicians)
    {
        map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEligibilityMatchExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        // Get the list of all valid Expertise Match rules
        map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        mapOMaxEligibilityRules.putAll([SELECT Id, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Tech Eligibility' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
        mapOMaxEligibilityRulesExpression = getWorkOrderExpression(mapOMaxEligibilityRules,  'Tech_Eligibility');
        system.debug(logginglevel.WARN, 'Technician Eligibility Match: Rule -> Expression ' + mapOMaxEligibilityRules + mapWorkOrderRule.size());
        mapWorkOrderRule = parseWorkOrderExpressions(mapWorkOrders, mapOMaxEligibilityRules, mapOMaxEligibilityRulesExpression);
        system.debug(logginglevel.WARN, 'Technician Eligibility Match: Work Order -> Rules: ' + mapWorkOrderRule);
        //create map of work order id and rule name for adding it to QTL
        for(Id woId : mapWorkOrderRule.keySet()){
            //String ruleName='';
            SVMXC__ServiceMax_Processes__c ruleProcess;
            if(mapOMaxEligibilityRules != null && mapOMaxEligibilityRules.size() > 0){
                ruleProcess = mapOMaxEligibilityRules.get(mapWorkOrderRule.get(woId));
                //ruleName = ruleProcess.SVMXC__Name__c;
            }
            mapWORuleName.put(woId,ruleProcess);
        }
        system.debug('buildTechnicianEligibilityScore::mapWORuleName:- ' + mapWORuleName);    
        list<SVMXC__ServiceMax_Config_Data__c> eligibilities = [Select Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Tech_Match' and SVMXC__Expression_Rule__c IN :mapWorkOrderRule.values() order by SVMXC__Sequence__c];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c confData: eligibilities)
        {
            list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
            if(!mapEligibilityMatchExpressions.containsKey(confData.SVMXC__Expression_Rule__c))
                mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, NULL);
            if(mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c) != NULL)
                lstEligibilities = mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c);
            lstEligibilities.add(confData);
            mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, lstEligibilities);
        }
        for(Id iWOIndex: mapWorkOrders.keySet())
        {
            List<Id> lstMandTech;
            Set<Id> setMandTechIds;
            List<Id> lstExclTech;
            Set<Id> setExclTechIds;     
            //create set of mandatory technician ids from map created using MPX list.            
            if(!mapWOResMand.isEmpty()){
                lstMandTech=mapWOResMand.get(iWOIndex);
                if(lstMandTech != null)
                    setMandTechIds = new set<Id>(lstMandTech);
                system.debug('buildTechnicianEligibilityScore::Mandatory Technicians...: ' + setMandTechIds);
            }
            //create set of Prohibited technician ids from map created using MPX list.            
            if(!mapWOResExcl.isEmpty()){
                lstExclTech=mapWOResExcl.get(iWOIndex);
                if(lstExclTech != null)
                    setExclTechIds = new set<Id>(lstExclTech);
                system.debug('buildTechnicianEligibilityScore::Prohibited Technicians...: ' + setExclTechIds);
            }            
            set<Id> mapTechnicianScore = new set<Id>();
            list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
            //Getting eligibility for this work order
            if(mapEligibilityMatchExpressions.containsKey(mapWorkOrderRule.get(iWOIndex)))
                lstEligibilities = mapEligibilityMatchExpressions.get(mapWorkOrderRule.get(iWOIndex));
            else//Go to next work order, there is no expression to match for tech eligibility
                continue;
            
            system.debug('buildTechnicianEligibilityScore::lstEligibilities...: ' + lstEligibilities);
            
            //Getting advanced express for technician match expression
            String strAdvanceExp='';
            SVMXC__ServiceMax_Processes__c techMatchRuleProcess = mapWORuleName.get(iWOIndex);
            if(techMatchRuleProcess != null && techMatchRuleProcess.SVMXC__Primary_Consolidation_Rule__c != ''){
                strAdvanceExp = techMatchRuleProcess.SVMXC__Primary_Consolidation_Rule__c;
            }
            for(SVMXC__Service_Group_Members__c objTechnicians: lstTechnicians)
            {
                system.debug('buildTechnicianEligibilityScore::Technician Name...: ' + objTechnicians.Name);
                Boolean isTechnicianMatched = false;
                
                if(setExclTechIds != null && setExclTechIds.contains(objTechnicians.Id))
                    continue;           
                
                //if Mandatory tech is available for the work order then processs only mandatory technicians from MPX and ignore all tech list.
                //if Mandatory tech is not available for the work order then process all technicians from the list.
                if(setMandTechIds != null && setMandTechIds.contains(objTechnicians.Id)){
                    isTechnicianMatched = matchTechnicianEligibility(objTechnicians, mapWorkOrders.get(iWOIndex), lstEligibilities, strAdvanceExp);
                }else if(setMandTechIds == null){
                    isTechnicianMatched = matchTechnicianEligibility(objTechnicians, mapWorkOrders.get(iWOIndex), lstEligibilities, strAdvanceExp);
                }
                system.debug('buildTechnicianEligibilityScore::isTechnicianMatched...: ' + isTechnicianMatched);
                if(isTechnicianMatched)
                {
                    mapTechnicianScore.add(objTechnicians.Id);
                }
                system.debug('buildTechnicianEligibilityScore::mapTechnicianScore...: ' + mapTechnicianScore);               
            }
            if(mapTechnicianScore.size() > 0)
                mapMatchedEligibilityScore.put(iWOIndex, mapTechnicianScore);       
        }
        
        return mapMatchedEligibilityScore;
    }

    // Returns Work Order -> Matched Eligibility Rule
    public map<Id, Id> parseWorkOrderExpressions(map<Id, SVMXC__Service_Order__c> mapWorkOrders, map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression)
    {
        map<Id, Id> mapRuleMatch = new map<Id, Id>();
        
        for(Id iWOIndex: mapWorkOrders.keySet())
        {
            Id IdMatchedRule = clsUtils4.SVMX_ExpressionParsing((SObject)mapWorkOrders.get(iWOIndex), mapOMaxEligibilityRulesExpression, mapOMaxEligibilityRules);
            system.debug(logginglevel.WARN, 'TEST_LOG: ' + IdMatchedRule);
            if(IdMatchedRule != NULL)
                mapRuleMatch.put(iWOIndex, IdMatchedRule);     
        }
        return mapRuleMatch;
    }

    //Finds preferred technicians score for each work order
    public map<Id, Id> buildPreferredTechnicianScore(map<Id, SVMXC__Service_Order__c> mapWorkOrders, set<Id> setTechnicianIds)
    {
        map<Id, Id> mapWorkOrderPrefferedTechnician = new map<Id, Id>();
        for(Id iWOIndex: mapWorkOrders.keySet())
        {
            List<Id> lstMandTech;
            Set<Id> setMandTechIds;
            List<Id> lstPrefTech;
            Set<Id> setPrefTechIds;  
            List<Id> lstExclTech;
            Set<Id> setExclTechIds;     
            //create set of mandatory technician ids from map created using MPX list.            
            if(!mapWOResMand.isEmpty()){
                lstMandTech=mapWOResMand.get(iWOIndex);
                if(lstMandTech != null)
                    setMandTechIds = new set<Id>(lstMandTech);
                system.debug('buildPreferredTechnicianScore::Mandatory Technicians...: ' + setMandTechIds);
            }
            
            //create set of Preferred technician ids from map created using MPX list. 
            if(!mapWOResPref.isEmpty()){
                lstPrefTech=mapWOResPref.get(iWOIndex);
                if(lstPrefTech != null)
                    setPrefTechIds = new set<Id>(lstPrefTech);
                system.debug('buildPreferredTechnicianScore::Preferred Technicians...: ' + setPrefTechIds);
            }        
            
            //create set of Prohibited technician ids from map created using MPX list.            
            if(!mapWOResExcl.isEmpty()){
                lstExclTech=mapWOResExcl.get(iWOIndex);
                if(lstExclTech != null)
                    setExclTechIds = new set<Id>(lstExclTech);
                system.debug('buildPreferredTechnicianScore:: Prohibited Technicians...: ' + setExclTechIds);
            }            
            
            for(Id techId :setTechnicianIds)
            {
                if(setExclTechIds != null && setExclTechIds.contains(techId))
                    continue;           
                
                //if Mandatory tech is available for the work order then processs only mandatory technicians from MPX and ignore all tech list.
                //if Mandatory tech is not available for the work order then validate preferred tech.
                //If Preferred tech is available then check PT is work order PT or MPX PT and both case we need to include for score
                if(setMandTechIds != null && setMandTechIds.contains(techId)){
                    if(mapWorkOrders.get(iWOIndex).SVMXC__Preferred_Technician__c != NULL && setTechnicianIds.contains(mapWorkOrders.get(iWOIndex).SVMXC__Preferred_Technician__c))
                    {
                        mapWorkOrderPrefferedTechnician.put(iWOIndex, mapWorkOrders.get(iWOIndex).SVMXC__Preferred_Technician__c);
                    }               
                }else if(setMandTechIds == null){
                    if(mapWorkOrders.get(iWOIndex).SVMXC__Preferred_Technician__c != NULL && setTechnicianIds.contains(mapWorkOrders.get(iWOIndex).SVMXC__Preferred_Technician__c))
                    {
                        mapWorkOrderPrefferedTechnician.put(iWOIndex, mapWorkOrders.get(iWOIndex).SVMXC__Preferred_Technician__c);
                    }else if(setPrefTechIds != null && setPrefTechIds.contains(techId)){
                        mapWorkOrderPrefferedTechnician.put(iWOIndex, techId);
                    } 
                }
                
            }
            

        }
        return mapWorkOrderPrefferedTechnician;
    }

    public map<Id, set<Id>> buildProductSpecialScore(map<Id, SVMXC__Service_Order__c> mapWorkOrders, set<Id> setTechnicianIds)
    {
        map<Id, set<Id>> mapProductSpecializedTechnician = new map<Id, set<Id>>();
        map<Id, String> mapWorkOrderProduct = new map<Id, String>();
        map<Id, Id> mapWorkOrderInstalledProduct = new map<Id, Id>();
        
        for(Id iWOIndex: mapWorkOrders.keySet())
        {
            if(mapWorkOrders.get(iWOIndex).SVMXC__Product__c != NULL)
                mapWorkOrderProduct.put(iWOIndex, mapWorkOrders.get(iWOIndex).SVMXC__Product__c);
            if(mapWorkOrders.get(iWOIndex).SVMXC__Component__c != NULL)
                mapWorkOrderInstalledProduct.put(iWOIndex, mapWorkOrders.get(iWOIndex).SVMXC__Component__c);
        }
        
        map<Id, SVMXC__Installed_Product__c> mapInstalledProduct = new map<Id, SVMXC__Installed_Product__c>();
        mapInstalledProduct.putAll([Select Id, SVMXC__Product__c from SVMXC__Installed_Product__c where Id IN: mapWorkOrderInstalledProduct.values()]);
        for(Id iWOIndex: mapWorkOrders.keySet())
        {
            // If Work Order is having IB and Product, IB will get preferrence
            if(mapWorkOrderInstalledProduct.containsKey(iWOIndex))
            {
                mapWorkOrderProduct.put(iWOIndex, mapInstalledProduct.get(mapWorkOrderInstalledProduct.get(iWOIndex)).SVMXC__Product__c);
            }
        }
        
        map<Id, set<Id>> mapProductTechnicians = new map<Id, set<Id>>();
        list<Product2> lstProduct = [Select Id, SVMXC__Product_Line__c, Family from Product2 where Id IN: mapWorkOrderProduct.values()];
        list<SVMXC__Service_Group_Product__c> lstProductSpecialization = [Select Id, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c, SVMXC__Group_Member__c from SVMXC__Service_Group_Product__c where SVMXC__Group_Member__c IN: setTechnicianIds];
        for(SVMXC__Service_Group_Product__c objProductSpecialization: lstProductSpecialization)
        {
            if(isProductSpecializationMatchesProduct(objProductSpecialization, lstProduct))
            {
                if(mapProductTechnicians == NULL || !mapProductTechnicians.containsKey(objProductSpecialization.SVMXC__Product__c))
                    mapProductTechnicians.put(objProductSpecialization.SVMXC__Product__c, new set<Id>());
                mapProductTechnicians.get(objProductSpecialization.SVMXC__Product__c).add(objProductSpecialization.SVMXC__Group_Member__c);
            }
        }
        
        for(Id iWOIndex: mapWorkOrderProduct.keySet())
        {
            if(mapProductTechnicians.containsKey(mapWorkOrderProduct.get(iWOIndex)))
            {
                mapProductSpecializedTechnician.put(iWOIndex, mapProductTechnicians.get(mapWorkOrderProduct.get(iWOIndex)));
            }
            else
                mapProductSpecializedTechnician.put(iWOIndex, NULL);
        }
        return mapProductSpecializedTechnician;
    }

    public map<Id, map<Id, list<skill>>> buildSkillScore(map<Id, SVMXC__Service_Order__c> mapWorkOrders, set<Id> setTechnicianIds)
    {
        map<Id, map<Id, list<skill>>> mapSkillMatch = new map<Id, map<Id, list<skill>>>();
        //map<Id, SVMXC__Service_Order__c> mapWorkOrders = new map<Id, SVMXC__Service_Order__c>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxAllSkillMatchRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxSkillMatchRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Processes__c>> mapOMaxSkillMatchRulesChildrens = new map<Id, list<SVMXC__ServiceMax_Processes__c>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxAllSkillMatchRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxSkillMatchRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
        map<Id, list<skill>> mapRequiredSkills = new map<Id, list<skill>>();
        list<Id> lstAllMatchedRules = new list<Id>();
        map<Id, Id> mapChildRuleToParentRule = new map<Id, Id>();
        mapOMaxAllSkillMatchRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c, SVMXC__Node_Parent__c, SVMXC__Primary_Consolidation_Rule__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Skill Matching' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
        
        /*for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder){
            mapWorkOrders.put(iWOIndex, objWorkOrder);
        }*/
        
        for(SVMXC__ServiceMax_Processes__c rule: mapOMaxAllSkillMatchRules.values()){
            if(rule.SVMXC__Node_Parent__c == NULL)
                mapOMaxSkillMatchRules.put(rule.Id, rule);
            else{
                list<SVMXC__ServiceMax_Processes__c> lstRules = new list<SVMXC__ServiceMax_Processes__c>();
                if(!mapOMaxSkillMatchRulesChildrens.containsKey(rule.SVMXC__Node_Parent__c))
                    mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, NULL);
                if(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c) != NULL)
                    lstRules.addAll(mapOMaxSkillMatchRulesChildrens.get(rule.SVMXC__Node_Parent__c));
                lstRules.add(rule);
                mapOMaxSkillMatchRulesChildrens.put(rule.SVMXC__Node_Parent__c, lstRules);
            }
        }
        
        mapOMaxAllSkillMatchRulesExpression = getWorkOrderExpression(mapOMaxAllSkillMatchRules,  'Skill_Eligibility');
        for(Id ruleId: mapOMaxSkillMatchRules.keySet()){
            mapOMaxSkillMatchRulesExpression.put(ruleId, mapOMaxAllSkillMatchRulesExpression.get(ruleId));
        }
        
        //system.debug(logginglevel.WARN,'lstWorkOrder: ' + lstWorkOrder);
        system.debug(logginglevel.WARN,'mapOMaxSkillMatchRulesExpression: ' + mapOMaxSkillMatchRulesExpression);
        // Get the list of all valid Skill Match rules
        mapWorkOrderRule = parseWorkOrderExpressions(mapWorkOrders, mapOMaxSkillMatchRules, mapOMaxSkillMatchRulesExpression);
        system.debug('buildSkillScore::mapWorkOrderRule: ' + mapWorkOrderRule);
        //For each Work Order Matched, get all child Rules and Find the Expression Match
        map<Id, set<Id>> mapMatchedWorkOrderSkills = new map<Id, set<Id>>();
        for(Id iWOIndex: mapWorkOrderRule.keySet()){
            set<Id> setMatchedRules = new set<Id>();
            Id parentRule = mapWorkOrderRule.get(iWOIndex);
            if(mapOMaxSkillMatchRulesChildrens.containsKey(parentRule) && mapOMaxSkillMatchRulesChildrens.get(parentRule) != NULL){
                list<SVMXC__ServiceMax_Processes__c> lstChildRules = mapOMaxSkillMatchRulesChildrens.get(parentRule);
                map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxSkillMatchRules2 = new map<Id, SVMXC__ServiceMax_Processes__c>();
                map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxSkillMatchRulesExpression2 = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
                for(SVMXC__ServiceMax_Processes__c childRule: lstChildRules){
                    mapOMaxSkillMatchRules2.put(childRule.Id, childRule);
                    if(mapOMaxAllSkillMatchRulesExpression.containsKey(childRule.Id))
                        mapOMaxSkillMatchRulesExpression2.put(childRule.Id, mapOMaxAllSkillMatchRulesExpression.get(childRule.Id));
                }
                setMatchedRules = clsUtils4.SVMX_GetAllMatchingExpression((SObject)mapWorkOrders.get(iWOIndex), mapOMaxSkillMatchRulesExpression2, mapOMaxSkillMatchRules2);
                system.debug(logginglevel.WARN,'Parent Rule: ' + parentRule + 'Chile Rules: ' + mapOMaxSkillMatchRules2.keySet());
                system.debug(logginglevel.WARN,'setMatchedRules: ' + setMatchedRules);
                for(Id matchedRuleId: setMatchedRules)
                {
                    mapChildRuleToParentRule.put(matchedRuleId, parentRule);
                }
                if(setMatchedRules != NULL)
                {
                    lstAllMatchedRules.addAll(setMatchedRules);
                }
            }
            //Add all matched skill matching rule Id for work order
            setMatchedRules.add(parentRule);
            mapMatchedWorkOrderSkills.put(iWOIndex, setMatchedRules);
        }
        lstAllMatchedRules.addAll(mapWorkOrderRule.values());
        
        system.debug(logginglevel.WARN,'lstAllMatchedRules: ' + lstAllMatchedRules);
        list<SVMXC__ServiceMax_Config_Data__c> lstSkillMatches = [Select SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Minimum_Level__c, SVMXC__Required__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Applicable Skills' and SVMXC__Expression_Rule__c IN: lstAllMatchedRules and SVMXC__Skill__r.SVMXC__Active__c = true];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        set<Id> setRequiredSkills = new set<Id>();
        for(SVMXC__ServiceMax_Config_Data__c skillMatches: lstSkillMatches)
        {
            list<skill> wrpSkillValues = new list<skill>();
            //skillMatches.SVMXC__Expression_Rule__c = mapChildRuleToParentRule.containsKey(skillMatches.SVMXC__Expression_Rule__c) ? mapChildRuleToParentRule.get(skillMatches.SVMXC__Expression_Rule__c) : skillMatches.SVMXC__Expression_Rule__c;
            if(!mapRequiredSkills.containsKey(skillMatches.SVMXC__Expression_Rule__c))
                mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, NULL);
            
            if(mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c) != NULL)
                wrpSkillValues = mapRequiredSkills.get(skillMatches.SVMXC__Expression_Rule__c);
            if(skillMatches.SVMXC__Minimum_Level__c == NULL)
                skillMatches.SVMXC__Minimum_Level__c = 0;
            wrpSkillValues.add(new skill(skillMatches.SVMXC__Skill__c, skillMatches.SVMXC__Skill__r.Name, skillMatches.SVMXC__Required__c, (skillMatches.SVMXC__Minimum_Level__c).intValue()));
            setRequiredSkills.add(skillMatches.SVMXC__Skill__c);
            mapRequiredSkills.put(skillMatches.SVMXC__Expression_Rule__c, wrpSkillValues);
        }
        
        list<SVMXC__Service_Group_Skills__c> lstExpertise = [Select SVMXC__Skill__c, SVMXC__Skill_Level__c, SVMXC__Group_Member__c from SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__c IN :setTechnicianIds and SVMXC__Skill__c IN: setRequiredSkills and SVMXC__Is_Applicable__c = 'TRUE'];
        map<Id, map<Id, Integer>> mapTechnicianSkillScore = new map<Id, map<Id, Integer>>();
        for(SVMXC__Service_Group_Skills__c objExperts: lstExpertise)
        {
            map<Id, Integer> mapSkillScore = new map<Id, Integer>();
            if(!mapTechnicianSkillScore.containsKey(objExperts.SVMXC__Group_Member__c))
                mapTechnicianSkillScore.put(objExperts.SVMXC__Group_Member__c, NULL);
            if(mapTechnicianSkillScore.get(objExperts.SVMXC__Group_Member__c) != NULL)
                mapSkillScore = mapTechnicianSkillScore.get(objExperts.SVMXC__Group_Member__c);
            if(objExperts.SVMXC__Skill_Level__c == NULL)
                objExperts.SVMXC__Skill_Level__c = 0;
            mapSkillScore.put(objExperts.SVMXC__Skill__c, (objExperts.SVMXC__Skill_Level__c).intValue());
            mapTechnicianSkillScore.put(objExperts.SVMXC__Group_Member__c, mapSkillScore);
        }
        for(Id iWOIndex: mapWorkOrderRule.keySet()){
            List<Id> lstMandTech;
            Set<Id> setMandTechIds; 
            List<Id> lstExclTech;
            Set<Id> setExclTechIds;
            map<Id, list<skill>> mapTechnicianMatchedSkillScores = new map<Id, list<skill>>();
            Integer expectedOptionalSkillCount = 0;
            Integer expectedRequiredSkillCount = 0;  //jyothsna
            //Getting matched skills for work order
            list<skill> lstMatchedWOSkills = new list<skill>();
            if(mapMatchedWorkOrderSkills != NULL && mapMatchedWorkOrderSkills.containsKey(iWOIndex) && mapMatchedWorkOrderSkills.get(iWOIndex) != NULL)
            {
                for(Id matchedRule: mapMatchedWorkOrderSkills.get(iWOIndex))
                {
                    list<skill> setMatchedSkills = mapRequiredSkills.get(matchedRule);
                    if(setMatchedSkills != NULL)
                        lstMatchedWOSkills.addAll(setMatchedSkills);
                }
            }
            else
                continue;
            system.debug('buildSkillScore::lstMatchedWOSkills: ' + lstMatchedWOSkills);
            if(mapWorkOrderRule.containsKey(iWOIndex) && mapWorkOrderRule.get(iWOIndex) != NULL && lstMatchedWOSkills.size() > 0)
            {
                lstMatchedWOSkills = makeUniqueSkillList(lstMatchedWOSkills);
                mapWorkOrderMatchedSkills.put(iWOIndex, lstMatchedWOSkills);
                
                //create set of mandatory technician ids from map created using MPX list.            
                if(!mapWOResMand.isEmpty()){
                    lstMandTech=mapWOResMand.get(iWOIndex);
                    if(lstMandTech != null)
                        setMandTechIds = new set<Id>(lstMandTech);
                    system.debug('buildSkillScore::Mandatory Technicians...: ' + setMandTechIds);
                }            
                
                //create set of Prohibited technician ids from map created using MPX list.            
                if(!mapWOResExcl.isEmpty()){
                    lstExclTech=mapWOResExcl.get(iWOIndex);
                    if(lstExclTech != null)
                        setExclTechIds = new set<Id>(lstExclTech);
                    system.debug('buildSkillScore:: Prohibited Technicians...: ' + setExclTechIds);
                }                
                set<Id> setMatchedTechnicianIds = new set<Id>();
                for(Id idTechnician: setTechnicianIds)
                {
                    if(!mapTechnicianSkillScore.containsKey(idTechnician))
                        continue;

                    if(setExclTechIds != null && setExclTechIds.contains(idTechnician))
                        continue;           
                        
                    Boolean isOneMandatorySkillMatched = false;
                    Boolean isAllMandatorySkillsMatched = true;
                    map<Id, Integer> mapTechniciansSkills = new map<Id, Integer>();
                    list<skill> lstMatchedTechnicianRequiredSkills = new list<skill>();
                    list<skill> lstMatchedTechnicianOptionalSkills = new list<skill>();
                    
                    //if Mandatory tech is available for the work order then processs only mandatory technicians from MPX and ignore all tech list.
                    //if Mandatory tech is not available for the work order then process all technicians from the list.
                    if(setMandTechIds != null && setMandTechIds.contains(idTechnician)){                
                        //Get technicians skills
                        mapTechniciansSkills = mapTechnicianSkillScore.get(idTechnician);
                    }else if(setMandTechIds == null){
                        mapTechniciansSkills = mapTechnicianSkillScore.get(idTechnician);
                    }
                    if(mapTechniciansSkills == NULL || lstMatchedWOSkills == NULL)
                        continue;
                    for(skill objSkill: lstMatchedWOSkills)
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
                            {
                                lstMatchedTechnicianRequiredSkills.add(new skill(objSkill.skillId, objSkill.skillName, objSkill.isSkillMandatory, mapTechniciansSkills.get(objSkill.skillId)));
                                isOneMandatorySkillMatched = true;
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
                
                mapMandatoryMatchedSkills.put(iWOIndex, setMatchedTechnicianIds);
                mapSkillMatch.put(iWOIndex, mapTechnicianMatchedSkillScores);
            }
            if(lstMatchedWOSkills != NULL)
            for(skill objSkill: lstMatchedWOSkills)
            {
                if(!objSkill.isSkillMandatory)
                    expectedOptionalSkillCount++;
                if(objSkill.isSkillMandatory)
                    expectedRequiredSkillCount++;
            }
            mapWorkOrderRequiredSkillCount.put(iWOIndex, expectedRequiredSkillCount);   //jyothsna
            mapWorkOrderOptionalSkillCount.put(iWOIndex, expectedOptionalSkillCount);
        }
        system.debug('buildSkillScore::mapWorkOrderRequiredSkillCount: ' + mapWorkOrderRequiredSkillCount);
        system.debug('buildSkillScore::mapWorkOrderOptionalSkillCount: ' + mapWorkOrderOptionalSkillCount);
        system.debug('buildSkillScore::mapWorkOrderMatchedSkills: ' + mapWorkOrderMatchedSkills);
        system.debug('buildSkillScore::mapSkillMatch: ' + mapSkillMatch);
        //system.debug(logginglevel.WARN,'mapWorkOrderOptionalSkillCount: ' + mapWorkOrderOptionalSkillCount);
        //system.debug(logginglevel.WARN,'mapWorkOrderMatchedSkills: ' + mapWorkOrderMatchedSkills);
        //system.debug(logginglevel.WARN,'mapSkillMatch: ' + mapSkillMatch);
        
        return mapSkillMatch;
    }
    
    // Get all field in the given field definition
    public list<String> getFieldDefinition(map<String, SObjectField> objectFieldDefinition)
    {
        list<String> objectFields = new list<String>();
        for(Schema.SObjectField fieldMap: objectFieldDefinition.values())
        {
            // Describe the field to get all properties
            list<SelectOption> lstWofl = new list<SelectOption>();
            Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
            if(fieldDescribe.isAccessible())
                objectFields.add(fieldDescribe.getName());
        }
        return objectFields;
    }
    
    // Returns Rule -> Expression
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getWorkOrderExpression(map<Id, SVMXC__ServiceMax_Processes__c> mapRules, String expressionType)
    {
        map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>(); 
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        //, SVMXC__Field_Relationship_Name__c
        mapExpression.putAll([SELECT Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c, SVMXC__Field_Relationship_Name__c from SVMXC__ServiceMax_Config_Data__c where (RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapRules.keySet()) and SVMXC__Expression_Type__c = :expressionType order by SVMXC__Sequence__c]);
        system.debug('getWorkOrderExpression::mapExpression: ' + mapExpression);
        for(SVMXC__ServiceMax_Config_Data__c oExp: mapExpression.values())
        {
            if(!mapRulesExpression.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                mapRulesExpression.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
            mapRulesExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
        }
        return mapRulesExpression;
    }

    // Apply technician expression and find whether the technician is elligible to work on the work order
    public boolean matchTechnicianEligibility(SVMXC__Service_Group_Members__c objTechnician, SVMXC__Service_Order__c objWorkOrder, list<SVMXC__ServiceMax_Config_Data__c> eligibilities, String strAdvanceExpression)
    {
        boolean response = false;
        for(SVMXC__ServiceMax_Config_Data__c expression: eligibilities)
        {
            if(expression.SVMXC__Operator__c != NULL)
            {
                expression.SVMXC__Operand__c = expression.SVMXC__Display_Value__c;
                if(expression.SVMXC__Target_Field_Name__c != NULL && objWorkOrder.get(expression.SVMXC__Target_Field_Name__c) != NULL)
                {
                    expression.SVMXC__Operand__c = String.valueOf(objWorkOrder.get(expression.SVMXC__Target_Field_Name__c));
                    system.debug(logginglevel.warn, 'TEST123: ' + expression.SVMXC__Target_Field_Name__c + ':' + objWorkOrder.get(expression.SVMXC__Target_Field_Name__c));
                }
            }
        }
        response = clsUtils4.SVMX_ExpressionParsing(objTechnician, eligibilities, strAdvanceExpression);
        system.debug(logginglevel.warn, 'TEST123:123 ' + response);
        if(response == NULL) response = false;
        return response;
    }
    
    public map<Id, list<stachRank>> scoreProcessor(map<Id, list<stachRank>> mapWorkOrderStackRank, map<Id, SVMXC__ServiceMax_Processes__c> mapWorkOrdersDP)
    {
        /*Integer maxScore = defaultPreferredTechnicianScore + defaultProductSpecializationScore + defaultEligibilityScore + (defaultSkillScore * 2);
        if(maxScore == 0 ) return mapWorkOrderStackRank; *///jyothsna
        for(Id iWO: mapWorkOrderStackRank.keySet())
        {   
            getDispatchProcessScores(mapWorkOrdersDP.get(iWO));
            system.debug('scoreProcessor::Default Score from DP: Pref. Tech- '+defaultPreferredTechnicianScore+'  Product Spl-'+defaultProductSpecializationScore+'  Eligibility -'+defaultEligibilityScore+'  Skill-'+defaultSkillScore);
            Integer tempSkillScore = 0;
            If(mapWorkOrderOptionalSkillCount.get(iWO) > 0 && mapWorkOrderRequiredSkillCount.get(iWO) > 0)
            {
                tempSkillScore = defaultSkillScore * 2; 
            }
            else
            {
                tempSkillScore = defaultSkillScore;         
            }   
            Integer maxScore = defaultPreferredTechnicianScore + defaultProductSpecializationScore + defaultEligibilityScore + tempSkillScore;  
            system.debug('scoreProcessor: iWO - ' + iWO + 'maxScore: ' + maxScore);
            if(maxScore == 0 ) continue;//return mapWorkOrderStackRank;
            list<stachRank> lstStackRank = mapWorkOrderStackRank.get(iWO);
            list<stachRank> lstProcessedStackRank = new list<stachRank>();
            Integer intEligibilityMatchedTechnicianCount = 0;
            Integer intSkillMatchedTechnicianCount = 0;
            for(stachRank objStackRank: lstStackRank)
            {
                //WSCH_AuditLogger.debug('scoreProcessor::objStackRank: ' + objStackRank);
                //If the technician is not having any QTL values, skip this technician
                //If the technician preferred type is Prohibited, do not skip this technician
                if((objStackRank.eligible == NULL || objStackRank.eligible == 0 ) && (objStackRank.prefTech == NULL || objStackRank.prefTech == 0 ) && (objStackRank.prod == NULL || objStackRank.prod == 0 ) && (objStackRank.skillO == NULL || objStackRank.skillO == 0 ) && (objStackRank.skillR == NULL || objStackRank.skillR == 0) && !(objStackRank.prefType.equals('Prohibited')))
                    continue;
                objStackRank.valid = true;
                // If Expertise match is not available and configuration says don't send Work Order to OptiMax
                if((defaultEligibilityScore > 0 && strEligibilityMatchSays == 'DISALLOW' && (objStackRank.eligible == NULL || objStackRank.eligible == 0)))
                {
                    objStackRank.valid = false;
                }
                else
                    intEligibilityMatchedTechnicianCount++;
                // If Skill match is not available and configuration says don't send Work Order to OptiMax
                if((defaultSkillScore > 0 && strSkillMatchSays == 'DISALLOW' && (objStackRank.skillR == NULL || objStackRank.skillR == 0)))
                {
                    objStackRank.valid = false;
                }
                else
                    intSkillMatchedTechnicianCount++;
                    
                // Update corresponding scores based on default property
                if(objStackRank.eligible == NULL || defaultEligibilityScore == 0)
                    objStackRank.eligible = 0;
                else if(objStackRank.eligible == 1)
                    objStackRank.eligible = defaultEligibilityScore;
                    
                if(defaultSkillScore == 0)
                {
                    objStackRank.skillR = 0;
                    objStackRank.skillO = 0;
                }
                if(objStackRank.prod == NULL || defaultProductSpecializationScore == 0)
                    objStackRank.prod = 0;
                else if(objStackRank.prod == 1)
                    objStackRank.prod = defaultProductSpecializationScore;
                if(objStackRank.prefTech == NULL || defaultPreferredTechnicianScore == 0)
                    objStackRank.prefTech = 0;
                else if(objStackRank.prefTech == 1)
                    objStackRank.prefTech = defaultPreferredTechnicianScore;
                    
                if(objStackRank.skillO == NULL)
                    objStackRank.skillO = 0;
                if(objStackRank.skillR == NULL)
                    objStackRank.skillR = 0;
                //Populate Stack Rank
                double totalScore;
                If(objStackRank.skillR == 0)
                    totalScore = 0;
                else
                    totalScore = objStackRank.prefTech + objStackRank.prod + objStackRank.skillO + objStackRank.skillR + objStackRank.eligible;
                double dblStackRnk = ((decimal)(totalScore * 10)).divide(maxScore, 2);
                system.debug('scoreProcessor::dblStackRnk : ' + dblStackRnk);
                objStackRank.stackRank = integer.valueOf(dblStackRnk.round());
                
                //WSCH_AuditLogger.debug('scoreProcessor::objStackRank before add it into list: ' + objStackRank);
                if(objStackRank.stackRank == 0 && !(objStackRank.prefType.equals('Prohibited')))
                    continue;
                lstProcessedStackRank.add(objStackRank);
            }
            mapWorkOrderStackRank.put(iWO,lstProcessedStackRank);
            if(intEligibilityMatchedTechnicianCount == 0)
            {
                if(strEligibilityMatchSays == 'ALLOW')
                {
                    if(intSkillMatchedTechnicianCount == 0 && strSkillMatchSays == 'DISALLOW')
                        setNonQualifiedWorkOrdersDisallow.add(iWO);
                    else
                        setNonQualifiedWorkOrdersAllow.add(iWO);
                }
                if(strEligibilityMatchSays == 'DISALLOW')
                    setNonQualifiedWorkOrdersDisallow.add(iWO);
            }
            else if(intSkillMatchedTechnicianCount == 0)
            {
                if(strSkillMatchSays == 'ALLOW')
                {
                    setNonQualifiedWorkOrdersAllow.add(iWO);
                }
                if(strSkillMatchSays == 'DISALLOW')
                    setNonQualifiedWorkOrdersDisallow.add(iWO);
            }
        }
        return mapWorkOrderStackRank;
    }
    
    public boolean isProductSpecializationMatchesProduct(SVMXC__Service_Group_Product__c objProductSpecialization, list<Product2> lstProduct)
    {
        for(Product2 objProduct: lstProduct)
        {
            if(objProductSpecialization.SVMXC__Product__c == objProduct.Id)
                return true;
            else if(objProductSpecialization.SVMXC__Product_Family__c == objProduct.Family)
                return true;
            else if(objProductSpecialization.SVMXC__Product_Line__c == objProduct.SVMXC__Product_Line__c)
                return true;
        }
        return false;
    }

    public list<skill> makeUniqueSkillList(list<skill> lstMatchedWOSkills)
    {
        list<skill> response = new list<skill>();
        map<Id, Integer> mapMandatoryLevel = new map<Id, Integer>();
        set<Id> setAddedMandatory = new set<Id>();
        set<Id> setAddedOptional = new set<Id>();
        for(skill objSkill: lstMatchedWOSkills)
        {
            if(objSkill.isSkillMandatory)
            {
                if(mapMandatoryLevel.containsKey(objSkill.skillId))
                {
                    if(mapMandatoryLevel.get(objSkill.skillId) < objSkill.skillLevel)
                        mapMandatoryLevel.put(objSkill.skillId, objSkill.skillLevel);
                }
                else
                    mapMandatoryLevel.put(objSkill.skillId, objSkill.skillLevel);
            }
        }
        for(skill objSkill: lstMatchedWOSkills)
        {
            //Add mandatory
            if(objSkill.isSkillMandatory && !setAddedMandatory.contains(objSkill.skillId) && mapMandatoryLevel.get(objSkill.skillId) == objSkill.skillLevel)
            {
                response.add(objSkill);
                setAddedMandatory.add(objSkill.skillId);
            }
            else
            {
                if((mapMandatoryLevel == NULL || !mapMandatoryLevel.containsKey(objSkill.skillId)) && !setAddedOptional.contains(objSkill.skillId))
                {
                    response.add(objSkill);
                    setAddedOptional.add(objSkill.skillId);
                }
            }
        }
        return response;
    } 
    
    public void getDispatchProcessScores(SVMXC__ServiceMax_Processes__c objSVMXProcess)
    {
        if(objSVMXProcess != null){
            if(objSVMXProcess.SVMXC__Weight_Tech_Eligibility__c != NULL)
                defaultEligibilityScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Tech_Eligibility__c);
            if(objSVMXProcess.SVMXC__Weight_Skill_Match__c != NULL)
                defaultSkillScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Skill_Match__c);
            if(objSVMXProcess.SVMXC__Weight_Product_Specialization__c != NULL)
                defaultProductSpecializationScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Product_Specialization__c);
            if(objSVMXProcess.SVMXC__Weight_Preferred_Technician__c != NULL)
                defaultPreferredTechnicianScore = Integer.valueOf(objSVMXProcess.SVMXC__Weight_Preferred_Technician__c);
        }
    }
      
    public void getWorkOrderResourcePreference(List<SVMXC__Service_Order__c> lstWOs){
        //Populates a static map with WorkOrder resource preference from the above qualified work orders
        system.debug('Start populating map of work orders preference wise... ');
        List<Work_Order_Resource__c> lstWORes = new List<Work_Order_Resource__c>();
        lstWORes = WORD_Service_Order_Resources.getWorkOrderResources(lstWOs);
        ID woID;
        List<String> lstTechMpx;
        for(Work_Order_Resource__c woRes: lstWORes){
            if((woRes.SVMXC__Group_Member__c != null) && ((woRes.SVMXC__Preference_Type__c != null))){
                //below logic creates the map of WOId and 'technician-PreferenceType for a Particular WO Id
                if(woID != woRes.SVMXC__Work_Order__c){//if it is a different WOId, then create a new List
                    woID = woRes.SVMXC__Work_Order__c;
                }
                if('Mandatory'.equalsIgnoreCase(woRes.SVMXC__Preference_Type__c)){
                    if(!mapWOResMand.containsKey(woID))
                        mapWOResMand.put(woID, new List<Id>());
                    
                    mapWOResMand.get(woID).add(woRes.SVMXC__Group_Member__c);                   
                
                }else if('Preferred'.equalsIgnoreCase(woRes.SVMXC__Preference_Type__c)){
                    if(!mapWOResPref.containsKey(woID))
                        mapWOResPref.put(woID, new List<Id>());
                    
                    mapWOResPref.get(woID).add(woRes.SVMXC__Group_Member__c);                   

                }else if('Prohibited'.equalsIgnoreCase(woRes.SVMXC__Preference_Type__c)){
                    if(!mapWOResExcl.containsKey(woID))
                        mapWOResExcl.put(woID, new List<Id>());
                    
                    mapWOResExcl.get(woID).add(woRes.SVMXC__Group_Member__c);                   
                }
                woID = woRes.SVMXC__Work_Order__c;
            }
        }
        //WSCH_AuditLogger.debug('End populating map of work orders preference wise... ');
    }

}
  

  public class SkillSet
  {
        public String skillName{ get; set; }
        public String skillId{ get; set; }
        public String skillLevel{ get; set; }
        public String isSkillMandatory{ get; set; }
  }
  public class OMAX_ViolationsUtils
  {
    
        public String getOMAX002TAG001(){ return system.label.OMAX002_TAG001;}//The assigned technician does not meet one of the following work order requirements or preferences: Skill, Preferred Technician, Eligibility or Product Expertise.
        public String getOMAX002TAG002(){ return system.label.OMAX002_TAG002;}//The scheduled date and time is outside of the preferred start time and the preferred end time of this work order.
        public String getOMAX002TAG003(){ return system.label.OMAX002_TAG003;}//This scheduled date and time is not a working day in the preferred business hours of this work order.
        public String getOMAX002TAG004(){ return system.label.OMAX002_TAG004;}//This scheduled date and time is outside of the preferred business hours of this work order.
        public String getOMAX002TAG005(){ return system.label.OMAX002_TAG005;}//The scheduled date and time of this work order is not a working day in the working hours of the assigned technician.
        public String getOMAX002TAG006(){ return system.label.OMAX002_TAG006;}//The scheduled date and time of this work order is outside of the technician working hours and beyond the overtime tolerance.
        public String getOMAX002TAG008(){ return system.label.OMAX002_TAG008;}//The scheduled date and time of this work order is outside of the technician working hours.
  
        // Entry point to the Technician violations check
        public String checkViolations(SVMXC__Service_Order__c wo, String jobId, Map<String, BusinessHours> mapBusinessHours, SVMXC__ServiceMax_Processes__c objSVMXProcess, List<SVMXC__Service_Group_Members__c> lstOptiMaxSchdldTechs, String strLogger, String strDefaultBHourId){       
                
            String strViolationMsg = '';
            
            try
            {
                // QTL violations
                strViolationMsg += checkQTLViolations(wo, jobId, strLogger);
                
                // Workorder SLA times and Preferred Business Hour violations using Scheduled datetime 
                strViolationMsg += checkAccessHourViolations(wo, jobId, mapBusinessHours, objSVMXProcess, strLogger);
                            
                // Technician working hours and overtime violations
                strViolationMsg += checkWorkingHourViolations(wo, jobId, mapBusinessHours, objSVMXProcess, lstOptiMaxSchdldTechs, strLogger, strDefaultBHourId);

                strLogger += system.now() + strViolationMsg+'\n';
            
            }catch(Exception ex)
            {
                strLogger += system.now() + ': Error: while checking the Technician and Workorder Violations in the class SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils \n' + ex.getStackTraceString();
                throw new SVMXException(strLogger);          
            }
            
             return strViolationMsg;
        }
        
                        
        // Check QTL violations             
        public String checkQTLViolations(SVMXC__Service_Order__c wo, String jobId, String strLogger){
        
            String violations_QTL = '';
            String assignedTechId = wo.SVMXC__Group_Member__c;
                        
            if(wo != null && wo.SVMXC__Qualified_Technicians__c != null)
            {
                List<stachRank> lstTechnicianStackRanks1 = (List<stachRank>)JSON.deserialize(wo.SVMXC__Qualified_Technicians__c, List<stachRank>.class);
                map<String,Integer> qtlMap =  new map<String,Integer>();
                
                for(stachRank objQTL: lstTechnicianStackRanks1){
                  qtlMap.put(objQTL.tech, objQTL.stackRank);
                }
        
                Integer stackRankValue;
                Integer maxStackRankValue = 0;
                
                if(qtlMap != null && !qtlMap.isEmpty()) 
                {
                    
                    //strLogger += system.now() + '--*********--qtlMap--' + qtlMap +'\n';
                    //strLogger += system.now() + '--*********--assignedTechId--' + assignedTechId +'\n';
                    //strLogger += system.now() + '--*********--lstTechnicianStackRanks--' + lstTechnicianStackRanks1 +'\n';
                    //strLogger += system.now() + '--*********--wo.SVMXC__Group_Member__c--' + wo.SVMXC__Group_Member__c +'\n';
                    //strLogger += system.now() + '--*********--qtlMap.containsKey(assignedTechId)--' + qtlMap.containsKey(assignedTechId) +'\n';
                    
                    if (qtlMap.containsKey(assignedTechId))
                    {
                        //strLogger += system.now() + '--*********--11111111111--'+'\n';
                        
                        stackRankValue = qtlMap.get(assignedTechId);
                        //String maxKey = new List<String>(qtlMap.keySet())[0];
                                        
                        if(qtlMap.size() > 1)
                        {               
                            //strLogger += system.now() + '--*********--2222222222222--'+'\n';
                                                        
                            List<Integer> listOfStackrankValues = (List<Integer>) qtlMap.values();
                            listOfStackrankValues.sort();
                            maxStackRankValue = listOfStackrankValues[listOfStackrankValues.size()-1];
                            
                            //strLogger += system.now() + '--******inside***--maxStackRankValue--'+maxStackRankValue+'\n';
                            
                        }
                        else
                        {
                            maxStackRankValue = stackRankValue;
                        }
                        
                        //strLogger += system.now() + '--*********--maxStackRankValue--' + maxStackRankValue+'\n';
                        //strLogger += system.now() + '--*********--stackRankValue--' + stackRankValue+'\n';
                        
                        if(stackRankValue < maxStackRankValue)
                        {
                           violations_QTL += getOMAX002TAG001()+';'+'\n';
                        }
                    }
                    else
                    {
                           violations_QTL += getOMAX002TAG001()+';'+'\n';
                    }
                }   
                
            }

            //Attachment objbusinessHourWithTolerance = new Attachment(Name = 'QTL violations Logsss', ParentId = jobId, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
            //insert objbusinessHourWithTolerance;
                
            return violations_QTL;
       }

        
      // Check the work order SLA times and Preferred Business Hour violations using Scheduled datetime 
      public String checkAccessHourViolations(SVMXC__Service_Order__c wo, String jobId, Map<String, BusinessHours> mapBusinessHours , SVMXC__ServiceMax_Processes__c objSVMXProcess, String strLogger){
        
             DateTime schDatetime = wo.SVMXC__Scheduled_Date_Time__c;
             DateTime startDateTime = schDatetime.addMinutes(-(Integer.valueOf(wo.SVMXC__Driving_Time__c)));
             DateTime endDateTime = schDatetime.addSeconds(Integer.valueOf(wo.SVMXC__Service_Duration__c));
                         
             String violations_AccessHours = '';
             SMAX_OptiMax_Engine_Ext optExt = new SMAX_OptiMax_Engine_Ext();
             
             //below code commented because this method validate only Accesshours not SLA.
             // Comparison with SLA times, if there in the WO
             /*if (wo.SVMXC__Preferred_End_Time__c != null && wo.SVMXC__Preferred_Start_Time__c!= null && (startDateTime < wo.SVMXC__Preferred_Start_Time__c || endDateTime > wo.SVMXC__Preferred_End_Time__c)) 
             {
                //violations_AccessHours += getOMAX002TAG002() +';'+'\n';
                if(wo.SVMXC__Preferred_Start_Time__c > startDateTime){
                    integer accessHourTimeDiffrnsInMints = Integer.valueOf((wo.SVMXC__Preferred_Start_Time__c.getTime() - startDateTime.getTime())/(1000*60));
                    violations_AccessHours += '< Time : Access Hours : Outside Hours : ' + accessHourTimeDiffrnsInMints + ' >' + ';'+'\n';
                }else if(endDateTime > wo.SVMXC__Preferred_End_Time__c){
                    integer accessHourTimeDiffrnsInMints = Integer.valueOf((endDateTime.getTime() - wo.SVMXC__Preferred_End_Time__c.getTime())/(1000*60));
                    violations_AccessHours += '< Time : Access Hours : Outside Hours : ' + accessHourTimeDiffrnsInMints + ' >' + ';'+'\n';
                }    
             }*/
                         
             BusinessHours bhID = mapBusinessHours.get(wo.SVMXC__Preferred_Business_hours__c);
             
             //strLogger += system.now() + '--*********--bhID--in checkAccessHourViolations---' + bhID +'\n';
             //strLogger += system.now() + '--*********--wo.name--in checkAccessHourViolations---' + wo.name +'\n';
             //strLogger += system.now() + '--*********--schDatetime--in checkAccessHourViolations---' + schDatetime +'\n';
            
             if (bhID != null){
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(schDatetime, 'GMT', bhID.TimeZoneSidKey);
                boolean isWorkingDay = optExt.isWorkingDay(bhID, startDatetimeBH.dateGMT());                
                //boolean isWorkingDay = optExt.isWorkingDay(bhID, schDatetime.dateGMT());
                
                //Check if the scheduled Datetime is a working day in the preferred business hours of the Workorders
                if (!isWorkingDay) {
                    violations_AccessHours += getOMAX002TAG003() + ';'+'\n';
                } 
                else 
                {
                    //Check if the scheduled Datetime is within the Preferred Business Hours of the Workorders 
                    if(!Businesshours.isWithin(bhID.ID, schDatetime) || !Businesshours.isWithin(bhID.ID, endDatetime.addMinutes(-1))){
                        violations_AccessHours += getOMAX002TAG004() + ';'+'\n';
                      }
                }
            }
            
            //Attachment objbusinessHourWithTolerance = new Attachment(Name = 'Preffered BusinessHour violations Logsss', ParentId = jobId, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
            //insert objbusinessHourWithTolerance;
            
            return violations_AccessHours;
        }
        
        
      // Check Technician working hours and overtime violations using the Scheduled datetime 
      public String checkWorkingHourViolations(SVMXC__Service_Order__c wo, String jobId, Map<String, BusinessHours> mapBusinessHours , SVMXC__ServiceMax_Processes__c objSVMXProcess, List<SVMXC__Service_Group_Members__c> lstOptiMaxSchdldTechs, String strLogger, String strDefaultBHourId){
        
             DateTime schDatetime = wo.SVMXC__Scheduled_Date_Time__c;
             DateTime startDateTime = schDatetime.addMinutes(-(Integer.valueOf(wo.SVMXC__Driving_Time__c)));
             DateTime endDateTime = schDatetime.addSeconds(Integer.valueOf(wo.SVMXC__Service_Duration__c));
             
             String violations_AccessHours = '';
             SMAX_OptiMax_Engine_Ext optExt = new SMAX_OptiMax_Engine_Ext();
             
             String techBHId = null;
             for(SVMXC__Service_Group_Members__c eachTechnician : lstOptiMaxSchdldTechs) {
                if(eachTechnician.Id == wo.SVMXC__Group_Member__c) {
                    techBHId = eachTechnician.SVMXC__Working_Hours__c;
                }
             }
             strLogger += system.now() + 'checkWorkingHourViolations():: WO Name: '+wo.Name+'\n'+'WO Scheduled DT: '+schDatetime+'\n'+' End DT: '+endDateTime+'\n'+' Technician BH Id :'+techBHId+'\n';
             
             BusinessHours bhID = mapBusinessHours.get(techBHId);
             
             //strLogger += system.now() + '--*********-1111---bhID--in checkWorkingHourViolations---' + bhID +'\n';
             //strLogger += system.now() + '--*********--mapBusinessHours--in checkWorkingHourViolations---' + mapBusinessHours +'\n';
             //strLogger += system.now() + '--*********--wo.SVMXC__Group_Member__r.SVMXC__Working_Hours__c--in checkWorkingHourViolations---' + wo.SVMXC__Group_Member__r.SVMXC__Working_Hours__c +'\n';
             
             if (bhID == null)
             {
                bhID = mapBusinessHours.get(wo.SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c);
             }
             
             if (bhID == null)
             {
                 bhID = mapBusinessHours.get(strDefaultBHourId);
             }
             
             //strLogger += system.now() + '--*********--bhID--in checkWorkingHourViolations---' + bhID +'\n';
             //strLogger += system.now() + '--*********--wo.name--in checkWorkingHourViolations---' + wo.name +'\n';
             //strLogger += system.now() + '--*********--schDatetime--in checkWorkingHourViolations---' + schDatetime +'\n';
            
             if (bhID != null){
                DateTime schDatetimeAfterTZConversion = WSCH_DateUtils.doTZConversion(schDatetime, 'GMT', bhID.TimeZoneSidKey);
                boolean isWorkingDay = optExt.isWorkingDay(bhID, schDatetimeAfterTZConversion.dateGMT());
                
                /*DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(schDatetime, 'GMT', bhID.TimeZoneSidKey);
                boolean isWorkingDay = optExt.isWorkingDay(bhID, startDatetimeBH.dateGMT());*/
                //boolean isWorkingDay = optExt.isWorkingDay(bhID, schDatetime.dateGMT());

                DateTime startDateTimeAfterTZConversion = WSCH_DateUtils.doTZConversion(startDateTime, 'GMT', bhID.TimeZoneSidKey);
                DateTime endDateTimeAfterTZConversion = WSCH_DateUtils.doTZConversion(endDateTime, 'GMT', bhID.TimeZoneSidKey);
                
                //Check if the scheduled Datetime is a working day in the in the assinged technician's working hours
                if (!isWorkingDay) {
                    violations_AccessHours += getOMAX002TAG005() + ';'+'\n';
                } 
                else 
                {
                    //strLogger += system.now() + '--*********--WorkOrder Name---in checkWorkingHourViolations---' +wo.Name+'---Workorder ID---'+wo.id+'\n';
                    //strLogger += system.now() + '--*********--schDatetime---in checkWorkingHourViolations---' +schDatetime+'\n';
                    //strLogger += system.now() + '--*********--startDateTime---in checkWorkingHourViolations---' +startDateTime+'\n';
                    //strLogger += system.now() + '--*********--endDatetime---in checkWorkingHourViolations---' +endDatetime+'\n';
                    //strLogger += system.now() + '--*********--endDatetime.addMinutes(-1)---in checkWorkingHourViolations---' +endDatetime.addMinutes(-1)+'\n';
                    //strLogger += system.now() + '--*********--Businesshours.isWithin(bhID.ID, startDateTime)---in checkWorkingHourViolations---' + Businesshours.isWithin(bhID.ID, startDateTime)+'\n';
                    //strLogger += system.now() + '--*********--Businesshours.isWithin(bhID.ID, endDatetime.addMinutes(-1))---in checkWorkingHourViolations---' + Businesshours.isWithin(bhID.ID, endDatetime.addMinutes(-1))+'\n';
                    
                    
                    //Check if the scheduled Datetime is within the Business Hours of the Technicians 
                    if(!Businesshours.isWithin(bhID.ID, startDateTimeAfterTZConversion) || !Businesshours.isWithin(bhID.ID, endDateTimeAfterTZConversion.addMinutes(-1))){
                    //if(!Businesshours.isWithin(bhID.ID, startDateTime) || !Businesshours.isWithin(bhID.ID, endDatetime.addMinutes(-1))){
                        //violations_AccessHours += getOMAX002TAG008() + ';'+'\n';
                        //List<DateTime> lstOfBHDateTime = WSCH_CommonUtils.getBHStartEndDateTime(schDatetime.dateGMT(), bhID);
                        List<DateTime> lstOfBHDateTime = WSCH_CommonUtils.getBHStartEndDateTime(schDatetimeAfterTZConversion.dateGMT(), bhID);
                        if(lstOfBHDateTime != null && lstOfBHDateTime.size() == 2) {
                                DateTime bhStartDateTime = lstOfBHDateTime.get(0);
                                DateTime bhEndDateTime = lstOfBHDateTime.get(1);
                                //if(schDatetime < bhStartDateTime){
                                if(schDatetimeAfterTZConversion < bhStartDateTime){     
                                    //integer workingHourTimeDiffrnsInMints = Integer.valueOf((bhStartDateTime.getTime() - schDatetime.getTime())/(1000*60));
                                    integer workingHourTimeDiffrnsInMints = Integer.valueOf((bhStartDateTime.getTime() - schDatetimeAfterTZConversion.getTime())/(1000*60));
                                    violations_AccessHours += '< Time : Working Hours : Outside Hours : ' + workingHourTimeDiffrnsInMints + ' >' + ';'+'\n';
                                //}else if(schDatetime > bhEndDateTime){
                                }else if(schDatetimeAfterTZConversion > bhEndDateTime){     
                                    //integer workingHourTimeDiffrnsInMints = Integer.valueOf((schDatetime.getTime() - bhEndDateTime.getTime())/(1000*60));
                                    integer workingHourTimeDiffrnsInMints = Integer.valueOf((schDatetimeAfterTZConversion.getTime() - bhEndDateTime.getTime())/(1000*60));
                                    violations_AccessHours += '< Time : Working Hours : Outside Hours : ' + workingHourTimeDiffrnsInMints + ' >' + ';'+'\n';
                                }
                         }
                         
                         //strLogger += system.now() + 'in checkWorkingHourViolations---lstOfBHDateTime.get(0) == >' +lstOfBHDateTime.get(0)+'\n';
                         //strLogger += system.now() + 'in checkWorkingHourViolations---lstOfBHDateTime.get(1) == >' +lstOfBHDateTime.get(1)+'\n';
                         //strLogger += system.now() + 'in checkWorkingHourViolations---schDatetime == >' +schDatetime+'\n';
                    }
                    
                    // Check the overtime voilations of the Technician Working hours            
                    if(objSVMXProcess.SVMXC__Tolerance__c != NULL && objSVMXProcess.SVMXC__Tolerance__c > 0){
                        violations_AccessHours += checkOvertimeViolations(endDateTimeAfterTZConversion, bhID, objSVMXProcess, strLogger);                
                    }                   
                }
            }
            
            //Attachment objbusinessHourWithTolerance = new Attachment(Name = 'Technician BusinessHour violations Logsss', ParentId = jobId, Body = Blob.valueOf(violations_AccessHours), IsPrivate = TRUE);
            //insert objbusinessHourWithTolerance;
            
            return violations_AccessHours;
        }       
        
        // Check the overtime violations of the Technician Working hours
        public String checkOvertimeViolations(DateTime endDateTimeGmt, BusinessHours bhID, SVMXC__ServiceMax_Processes__c objSVMXProcess, String strLogger){
        
            Datetime dt = DateTime.newInstance(endDateTimeGmt.dateGMT(), Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dt.formatGMT('EEEE');
            String violations_AccessHours = '';
            try
            {
                //convert gmt end datetime into business hour timezone.
                DateTime endDateTime = WSCH_DateUtils.doTZConversion(endDateTimeGmt, 'GMT', bhID.TimeZoneSidKey);
                strLogger += system.now() + 'checkWorkingHourViolations()::after converting to territory timezone : ' +endDateTime+'\n';
                strLogger += system.now() + 'checkWorkingHourViolations()::endDateTime.timeGMT(): ' +endDateTime.timeGMT()+'\n';
                if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Monday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.MondayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Monday: BH endtime after add tolerance duration....'+bhID.MondayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }else if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Tuesday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.TuesdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Tuesday: BH endtime after add tolerance duration....'+bhID.TuesdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }else if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Wednesday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.WednesdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Wednesday: BH endtime after add tolerance duration....'+bhID.WednesdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }else if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Thursday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.ThursdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Thursday: BH endtime after add tolerance duration....'+bhID.ThursdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }else if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Friday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.FridayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Friday: BH endtime after add tolerance duration....'+bhID.FridayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }else if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Saturday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.SaturdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Saturday: BH endtime after add tolerance duration....'+bhID.SaturdayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }else if(dayOfWeek != null && dayOfWeek.equalsIgnoreCase('Sunday'))
                {
                    if(endDateTime != null && (endDateTime.timeGMT() > bhID.SundayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())))
                    {
                        strLogger += system.now() + 'checkWorkingHourViolations()::Sunday: BH endtime after add tolerance duration....'+bhID.SundayEndTime.addMinutes(objSVMXProcess.SVMXC__Tolerance__c.intValue())+'\n';
                        violations_AccessHours += getOMAX002TAG006() + ';'+'\n';
                    }
                }   
                
            }catch(Exception ex)
            {
                strLogger += system.now() + ': Error: while checking the overtime violations of the Technician Working hours in the class SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils \n' + ex.getStackTraceString();
            }
            
            return violations_AccessHours;
        }
        // OPT-154      
        // Checks the Skill violations
        public List<SVMXC__SM_Scheduling_Violation__c> checkSkillViolations(Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills, SVMXC__Service_Order__c objWorkOrder, String strLogger, String jobId){
                        
            List<SVMXC__SM_Scheduling_Violation__c> listViolationsDetails = new List<SVMXC__SM_Scheduling_Violation__c>();          
            List<SkillSet> lstSkillSet = new List<SkillSet>();       
                    
            if(objWorkOrder.SVMXC__Skill_Set__c != null){
                lstSkillSet = (List<SkillSet>)JSON.deserialize(objWorkOrder.SVMXC__Skill_Set__c, List<SkillSet>.class);    
            }       
                    
            if(mapTechIdSkills != null){
                List<SVMXC__Service_Group_Skills__c> lstSkill = mapTechIdSkills.get(objWorkOrder.SVMXC__Group_Member__c);
                
                String skillViolationMssgs = '';
                if(lstSkill == null){               
                    for(SkillSet skillSet: lstSkillSet){                                 
                      SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                      violationsDetails.Name = 'Skill Violations';                
                      violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                      //violationsDetails.SVMXC__SM_Violation_Name__c = 'Skill';
                      violationsDetails.SVMXC__SM_Value__c = skillSet.skillName;
                      violationsDetails.SVMXC__SM_Param_Value_1__c = 'true'.equalsIgnoreCase(skillSet.isSkillMandatory) ? 'Required' : 'Optional';
                      violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                      violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;    
                      violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                                  
                      listViolationsDetails.add(violationsDetails);     
                      
                      skillViolationMssgs += '< Capability : Skill : ' + skillSet.skillName + ' : ' + ('true'.equalsIgnoreCase(skillSet.isSkillMandatory) ? 'Required' : 'Optional') +' >'+ '\n';                                      
                    }
                    
                }else{
                    set<string> setSkill = new set<string>();       
                    for(SVMXC__Service_Group_Skills__c objSkill : lstSkill){          
                        setSkill.add(objSkill.SVMXC__Skill__c);
                    }
                                            
                     for(SkillSet skillSet: lstSkillSet){
                         
                       if(setSkill != null && !setSkill.contains(skillSet.skillId)){    
                          SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                          violationsDetails.Name = 'Skill Violations';                    
                          violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                          //violationsDetails.SVMXC__SM_Violation_Name__c = 'Skill';
                          violationsDetails.SVMXC__SM_Value__c = skillSet.skillName;
                          violationsDetails.SVMXC__SM_Param_Value_1__c = 'true'.equalsIgnoreCase(skillSet.isSkillMandatory) ? 'Required' : 'Optional';
                          violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                          violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                          violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                                      
                          listViolationsDetails.add(violationsDetails);     
                          
                          skillViolationMssgs += '< Capability : Skill : ' + skillSet.skillName + ' : ' + ('true'.equalsIgnoreCase(skillSet.isSkillMandatory) ? 'Required' : 'Optional') +' >'+ '\n';
                       }
                    }
                
                }
                            
                if(skillViolationMssgs != null && skillViolationMssgs.length()>0 && !skillViolationMssgs.equalsIgnoreCase('null')){
                    if(objWorkOrder.SVMXC__Violation_Message__c == null){
                        objWorkOrder.SVMXC__Violation_Message__c = skillViolationMssgs + '\n';
                    }else{
                        objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c + '\n';
                        objWorkOrder.SVMXC__Violation_Message__c += skillViolationMssgs;
                    }
                    objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation'; 
                }
            
            }
                            
            return listViolationsDetails;        
         }
         
         // It retrieves skills per technician from database and creates a map of the technicians with their corresponding skills.
         public Map<Id, List<SVMXC__Service_Group_Skills__c>>  skillsPerTech(set<String> setScheduledTechs)
         {
            List<SVMXC__Service_Group_Skills__c> lstOptiMaxSkill = new List<SVMXC__Service_Group_Skills__c>();
            lstOptiMaxSkill = [SELECT SVMXC__Group_Member__c, SVMXC__Skill__c FROM SVMXC__Service_Group_Skills__c WHERE SVMXC__Group_Member__c IN :setScheduledTechs AND SVMXC__Skill__r.SVMXC__Active__c = true];

            Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills= new Map<Id, List<SVMXC__Service_Group_Skills__c>>();

            for(SVMXC__Service_Group_Skills__c objSkill: lstOptiMaxSkill)
            {           
                 if(!(mapTechIdSkills.containsKey(objSkill.SVMXC__Group_Member__c)))
                  mapTechIdSkills.put(objSkill.SVMXC__Group_Member__c, new List<SVMXC__Service_Group_Skills__c>());
                  
                 mapTechIdSkills.get(objSkill.SVMXC__Group_Member__c).add(objSkill);
                        
            }
            return mapTechIdSkills;
              
        }   

        // Checks SLA violations
        public List<SVMXC__SM_Scheduling_Violation__c> checkSLAViolations(SVMXC__Service_Order__c objWorkOrder, Map<String, BusinessHours> mapBusinessHours, String jobId, String strLogger){
            
             DateTime schDatetime = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
             DateTime startDateTime = schDatetime.addMinutes(-(Integer.valueOf(objWorkOrder.SVMXC__Driving_Time__c)));
             DateTime endDateTime = schDatetime.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
             
             //strLogger += system.now() + ': schDatetime: ' + schDatetime + '--startDateTime=='+startDateTime+'---objWorkOrder.SVMXC__Preferred_Start_Time__c==='+objWorkOrder.SVMXC__Preferred_Start_Time__c+'---objWorkOrder.Name=='+objWorkOrder.Name+' \n';
             
             List<SVMXC__SM_Scheduling_Violation__c> listViolationsDetails = new List<SVMXC__SM_Scheduling_Violation__c>(); 
             String slaViolationMssgs = '';
             
             if (objWorkOrder.SVMXC__Preferred_Start_Time__c!= null && (startDateTime < objWorkOrder.SVMXC__Preferred_Start_Time__c) && (endDateTime > objWorkOrder.SVMXC__Preferred_Start_Time__c)) 
             {
                  //Attachment objBadWorkOrderAttach = new Attachment(Name = 'Early Arrival', ParentId = completeJobDetail.jobId, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
                  //insert objBadWorkOrderAttach;
                
                  integer timeDiffrnsInMints = Integer.valueOf((objWorkOrder.SVMXC__Preferred_Start_Time__c.getTime() - startDateTime.getTime())/(1000*60));
                  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();     
                  violationsDetails.Name = 'SLA Violations';              
                  violationsDetails.SVMXC__SM_Category__c = 'Time' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'SLA';
                  violationsDetails.SVMXC__SM_Value__c = 'Early Arrival';
                  violationsDetails.SVMXC__SM_Param_Value_2__c = timeDiffrnsInMints;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;    
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  slaViolationMssgs += '< Time : SLA : Early Arrival : '+ String.valueOf(timeDiffrnsInMints) +' >'+ '\n';
             }else if(objWorkOrder.SVMXC__Preferred_Start_Time__c!= null && (startDateTime < objWorkOrder.SVMXC__Preferred_Start_Time__c) && (endDateTime < objWorkOrder.SVMXC__Preferred_Start_Time__c)) 
             {
                
                  //Attachment objBadWorkOrderAttach = new Attachment(Name = 'Early Arrival', ParentId = completeJobDetail.jobId, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
                  //insert objBadWorkOrderAttach;
                  
                  integer timeDiffrnsInMints = Integer.valueOf((objWorkOrder.SVMXC__Preferred_Start_Time__c.getTime() - startDateTime.getTime())/(1000*60));
                  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();     
                  violationsDetails.Name = 'SLA Violations';              
                  violationsDetails.SVMXC__SM_Category__c = 'Time' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'SLA';
                  violationsDetails.SVMXC__SM_Value__c = 'Early Arrival';
                  violationsDetails.SVMXC__SM_Param_Value_2__c = timeDiffrnsInMints;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;    
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  slaViolationMssgs += '< Time : SLA : Early Arrival : '+ String.valueOf(timeDiffrnsInMints) +' >'+ '\n';
                  
                  timeDiffrnsInMints = Integer.valueOf((objWorkOrder.SVMXC__Preferred_Start_Time__c.getTime() - endDateTime.getTime())/(1000*60));
                  violationsDetails = new SVMXC__SM_Scheduling_Violation__c();     
                  violationsDetails.Name = 'SLA Violations';              
                  violationsDetails.SVMXC__SM_Category__c = 'Time' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'SLA';
                  violationsDetails.SVMXC__SM_Value__c = 'Early Resolution';
                  violationsDetails.SVMXC__SM_Param_Value_2__c = timeDiffrnsInMints;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;    
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  slaViolationMssgs += '< Time : SLA : Early Resolution : ' + String.valueOf(timeDiffrnsInMints) +' >'+ '\n';
             }
             
             if (objWorkOrder.SVMXC__Preferred_End_Time__c != null && (startDateTime < objWorkOrder.SVMXC__Preferred_End_Time__c) && (endDateTime > objWorkOrder.SVMXC__Preferred_End_Time__c)) 
             {
                  integer timeDiffrnsInMints = Integer.valueOf((endDateTime.getTime() - objWorkOrder.SVMXC__Preferred_End_Time__c.getTime())/(1000*60));  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();     
                  violationsDetails.Name = 'SLA Violations';              
                  violationsDetails.SVMXC__SM_Category__c = 'Time' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'SLA';
                  violationsDetails.SVMXC__SM_Value__c = 'Late Resolution';
                  violationsDetails.SVMXC__SM_Param_Value_2__c = timeDiffrnsInMints;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;    
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;                  
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  slaViolationMssgs += '< Time : SLA : Late Resolution : ' + String.valueOf(timeDiffrnsInMints) +' >'+ '\n';
             }else if(objWorkOrder.SVMXC__Preferred_End_Time__c != null && (startDateTime > objWorkOrder.SVMXC__Preferred_End_Time__c) && (endDateTime > objWorkOrder.SVMXC__Preferred_End_Time__c)) 
             {
                  integer timeDiffrnsInMints = Integer.valueOf((startDateTime.getTime() - objWorkOrder.SVMXC__Preferred_End_Time__c.getTime())/(1000*60));
                  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();     
                  violationsDetails.Name = 'SLA Violations';              
                  violationsDetails.SVMXC__SM_Category__c = 'Time' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'SLA';
                  violationsDetails.SVMXC__SM_Value__c = 'Late Arrival';
                  violationsDetails.SVMXC__SM_Param_Value_2__c = timeDiffrnsInMints;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;    
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  slaViolationMssgs += '< Time : SLA : Late Arrival : '+ String.valueOf(timeDiffrnsInMints) +' >'+ '\n';
                  
                  timeDiffrnsInMints = Integer.valueOf((endDateTime.getTime() - objWorkOrder.SVMXC__Preferred_End_Time__c.getTime())/(1000*60));
                  violationsDetails = new SVMXC__SM_Scheduling_Violation__c();     
                  violationsDetails.Name = 'SLA Violations';              
                  violationsDetails.SVMXC__SM_Category__c = 'Time' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'SLA';
                  violationsDetails.SVMXC__SM_Value__c = 'Late Resolution';
                  violationsDetails.SVMXC__SM_Param_Value_2__c = timeDiffrnsInMints;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;    
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c; 
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  slaViolationMssgs += '< Time : SLA : Late Resolution : '+ String.valueOf(timeDiffrnsInMints) +' >'+ '\n';
             }
                            
             if(slaViolationMssgs != null && slaViolationMssgs.length() > 0 && !slaViolationMssgs.equalsIgnoreCase('null')){
                if(objWorkOrder.SVMXC__Violation_Message__c == null){
                    objWorkOrder.SVMXC__Violation_Message__c = slaViolationMssgs + '\n';
                }else{
                    objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c + '\n';
                    objWorkOrder.SVMXC__Violation_Message__c += slaViolationMssgs;
                }
                objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
            }
            
            return listViolationsDetails;               
          
        }   
                
        // It retrieves product expertise per technician from database and creates a map of the technicians with their corresponding product expertise.     
        public Map<Id, String>  expertisePerTech(set<String> setScheduledTechs)
        {   
            List<SVMXC__Service_Group_Product__c> lstProduct = new List<SVMXC__Service_Group_Product__c>();
            lstProduct = [SELECT SVMXC__Group_Member__c, SVMXC__Product__c FROM SVMXC__Service_Group_Product__c WHERE SVMXC__Group_Member__c IN :setScheduledTechs];

            Map<Id, String> mapTechIdProduct= new Map<Id, String>();

              for(SVMXC__Service_Group_Product__c objProduct: lstProduct)
            {           
                 if(!(mapTechIdProduct.containsKey(objProduct.SVMXC__Group_Member__c)))
                  mapTechIdProduct.put(objProduct.SVMXC__Group_Member__c, objProduct.SVMXC__Product__c);
                    
            }
            
            return mapTechIdProduct;    
        }    
        
        // Checks product expertise violations
        public List<SVMXC__SM_Scheduling_Violation__c> checkProductExprtseViolations(Map<Id, String> mapTechIdProduct, SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger){
            
            List<SVMXC__SM_Scheduling_Violation__c> listViolationsDetails = new List<SVMXC__SM_Scheduling_Violation__c>();
        
            String strProduct = mapTechIdProduct.get(objWorkOrder.SVMXC__Group_Member__c);                    
                            
            String productViolationMssgs = '';
            if(strProduct == null && objWorkOrder.SVMXC__Product__c != null){                                                              
                  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                  violationsDetails.Name = 'Product Expertise Violations';                
                  violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'Product Expertise';                  
                  violationsDetails.SVMXC__SM_Value__c = objWorkOrder.SVMXC__Product__r.Name;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  productViolationMssgs += '< Capability : Product Expertise : ' + objWorkOrder.SVMXC__Product__r.Name +' >'+ '\n';                                 
                                
            }else if((strProduct != null && objWorkOrder.SVMXC__Product__c != null) && !strProduct.equalsIgnoreCase(objWorkOrder.SVMXC__Product__c)){
                  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                  violationsDetails.Name = 'Product Expertise Violations';                
                  violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'Product Expertise';                  
                  violationsDetails.SVMXC__SM_Value__c = objWorkOrder.SVMXC__Product__r.Name;
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;    
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  productViolationMssgs += '< Capability : Product Expertise : ' + objWorkOrder.SVMXC__Product__r.Name +' >'+ '\n'; 
            }
            
            if(productViolationMssgs != null && productViolationMssgs.length() > 0 && !productViolationMssgs.equalsIgnoreCase('null')){
                if(objWorkOrder.SVMXC__Violation_Message__c == null){
                    objWorkOrder.SVMXC__Violation_Message__c = productViolationMssgs + '\n';
                }else{
                    objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c + '\n';
                    objWorkOrder.SVMXC__Violation_Message__c += productViolationMssgs;
                }
                objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
             }                              
            
            return listViolationsDetails;   
        }
        
        // Checks eligibility rule violations
        public List<SVMXC__SM_Scheduling_Violation__c> checkEligibilityRuleViolations(SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger){
            
            List<SMAX_OptiMax_EngineUtils.stachRank> listQTL = (List<SMAX_OptiMax_EngineUtils.stachRank>)JSON.deserialize(objWorkOrder.SVMXC__Qualified_Technicians__c, List<SMAX_OptiMax_EngineUtils.stachRank>.class);
            
            Map<Id, Integer> mapTechEligible = new Map<Id, Integer>();
            Map<Id, String> mapTechEligibilityRule = new Map<Id, String>();
            for(SMAX_OptiMax_EngineUtils.stachRank stachRnk : listQTL){
                mapTechEligible.put(stachRnk.tech, stachRnk.eligible);
                mapTechEligibilityRule.put(stachRnk.tech, stachRnk.eligibleRuleName);
            }
            
            List<SVMXC__SM_Scheduling_Violation__c> listViolationsDetails = new List<SVMXC__SM_Scheduling_Violation__c>();
            String eligibilityRuleViolationMssgs = '';
            
            if((mapTechEligibilityRule.get(objWorkOrder.SVMXC__Group_Member__c) != null && !mapTechEligibilityRule.get(objWorkOrder.SVMXC__Group_Member__c).equalsIgnoreCase('')) && mapTechEligible.containsKey(objWorkOrder.SVMXC__Group_Member__c) && mapTechEligible.get(objWorkOrder.SVMXC__Group_Member__c) <= 0){
                  SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                  violationsDetails.Name = 'Eligibility Rule Violations';                 
                  violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                  //violationsDetails.SVMXC__SM_Violation_Name__c = 'Eligibility';                
                  violationsDetails.SVMXC__SM_Value__c = mapTechEligibilityRule.get(objWorkOrder.SVMXC__Group_Member__c);
                  violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                  violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;    
                  violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                  
                  listViolationsDetails.add(violationsDetails);     
                  
                  eligibilityRuleViolationMssgs += '< Capability : Eligibility : '+ mapTechEligibilityRule.get(objWorkOrder.SVMXC__Group_Member__c) +' >'+ '\n';      
                
            }
            
            if(eligibilityRuleViolationMssgs != null && eligibilityRuleViolationMssgs.length() > 0 && !eligibilityRuleViolationMssgs.equalsIgnoreCase('null')){
                if(objWorkOrder.SVMXC__Violation_Message__c == null){
                    objWorkOrder.SVMXC__Violation_Message__c = eligibilityRuleViolationMssgs + '\n';
                }else{
                    objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c + '\n';
                    objWorkOrder.SVMXC__Violation_Message__c += eligibilityRuleViolationMssgs;
                }
                objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
             }
            
            return listViolationsDetails;   
        }
        
        // Check Mandatory, Preferred, Prohibited Technician violations
        public List<SVMXC__SM_Scheduling_Violation__c> checkPrefrdMandtProhbtTechViolations(SVMXC__Service_Order__c objWorkOrder, String jobId, String strLogger, String techName){
            
            List<SMAX_OptiMax_EngineUtils.stachRank> listQTL = (List<SMAX_OptiMax_EngineUtils.stachRank>)JSON.deserialize(objWorkOrder.SVMXC__Qualified_Technicians__c, List<SMAX_OptiMax_EngineUtils.stachRank>.class);
            
            Map<Id, String> mapTechPref = new Map<Id, String>();
            Set<String> setPrefType = new Set<String>();
            for(SMAX_OptiMax_EngineUtils.stachRank stachRnk : listQTL){
                mapTechPref.put(stachRnk.tech, stachRnk.prefType);
                setPrefType.add(stachRnk.prefType);
            }
            
            List<SVMXC__SM_Scheduling_Violation__c> listViolationsDetails = new List<SVMXC__SM_Scheduling_Violation__c>();
            String prefTechRuleViolationMssgs = '';
            
            if(setPrefType != null && setPrefType.contains('Mandatory')){
                  if(mapTechPref.containsKey(objWorkOrder.SVMXC__Group_Member__c) && !mapTechPref.get(objWorkOrder.SVMXC__Group_Member__c).equalsIgnoreCase('Mandatory')){
                      SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                      violationsDetails.Name = 'Mandatory Technician Rule Violations';                 
                      violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                      //violationsDetails.SVMXC__SM_Violation_Name__c = 'Mandatory Technician';                
                      violationsDetails.SVMXC__SM_Value__c = techName; 
                      violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                      violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;    
                      violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                      listViolationsDetails.add(violationsDetails);     
                      prefTechRuleViolationMssgs += '< Capability : Mandatory Technician : ' + techName +' >'+ '\n';                    
                  }            
            }else if(setPrefType != null && setPrefType.contains('Preferred')){
                  if(mapTechPref.containsKey(objWorkOrder.SVMXC__Group_Member__c) && !mapTechPref.get(objWorkOrder.SVMXC__Group_Member__c).equalsIgnoreCase('Preferred')){
                      SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                      violationsDetails.Name = 'Preferred Technician Rule Violations';                 
                      violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                      //violationsDetails.SVMXC__SM_Violation_Name__c = 'Preferred Technician';                
                      violationsDetails.SVMXC__SM_Value__c = techName;
                      violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                      violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;    
                      violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                      listViolationsDetails.add(violationsDetails);     
                      prefTechRuleViolationMssgs += '< Capability : Preferred Technician : '+ techName +' >'+ '\n';      
                   }
            }
            
            if(setPrefType != null && setPrefType.contains('Prohibited')){
                if(mapTechPref.containsKey(objWorkOrder.SVMXC__Group_Member__c) && mapTechPref.get(objWorkOrder.SVMXC__Group_Member__c).equalsIgnoreCase('Prohibited')){
                      SVMXC__SM_Scheduling_Violation__c violationsDetails = new SVMXC__SM_Scheduling_Violation__c();    
                      violationsDetails.Name = 'Prohibited Technician Rule Violations';                 
                      violationsDetails.SVMXC__SM_Category__c = 'Capability' ;
                      //violationsDetails.SVMXC__SM_Violation_Name__c = 'Prohibited Technician';                
                      violationsDetails.SVMXC__SM_Value__c = techName;
                      violationsDetails.SVMXC__SM_Work_Order__c = objWorkOrder.id;
                      violationsDetails.SVMXC__SM_Servicemax_Job__c = jobId;    
                      violationsDetails.SVMXC__SM_Technician__c =  objWorkOrder.SVMXC__Group_Member__c;                   
                      listViolationsDetails.add(violationsDetails);     
                      prefTechRuleViolationMssgs += '< Capability : Prohibited Technician : '+ techName +' >'+'\n';      
                }
            }
            
            if(prefTechRuleViolationMssgs != null && prefTechRuleViolationMssgs.length() > 0 && !prefTechRuleViolationMssgs.equalsIgnoreCase('null')){
                if(objWorkOrder.SVMXC__Violation_Message__c == null){
                    objWorkOrder.SVMXC__Violation_Message__c = prefTechRuleViolationMssgs + '\n';
                }else{
                    objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c + '\n';
                    objWorkOrder.SVMXC__Violation_Message__c += prefTechRuleViolationMssgs;
                }
                objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
             }
            
            return listViolationsDetails;   
        }
        
   }
   
  //OMAX_OvernightUtils - had util  methods releated to overnight policy object
  public class OMAX_OvernightUtils{
    
    //This method retuurn a map of technician ids and overnight policy of the technician
    public Map<String,SVMXC__SM_Overnight_Stay_Policy__c> getTerritoryOvernightPolicy(SVMXC__Territory__c territory,List<SVMXC__Service_Group_Members__c> technicians){
        Map<String,SVMXC__SM_Overnight_Stay_Policy__c> technicianOvernightMap = new Map<String,SVMXC__SM_Overnight_Stay_Policy__c>();
        
        String territoryOvernightPolicyId = territory.SVMXC__SM_Overnight_Stay_Policy__c;
        
       Map<String,String> technicianNPolicyMap = new Map<String,String>();
       if(null!=technicians && technicians.size()>0){
          for(SVMXC__Service_Group_Members__c tech: technicians){
            if(null != tech.SVMXC__SM_Overnight_Stay_Policy__c){
                technicianNPolicyMap.put(tech.id,tech.SVMXC__SM_Overnight_Stay_Policy__c);
            }
       }
       }
       
       List<String> overnightIds = technicianNPolicyMap.values();
       overnightIds.add(territoryOvernightPolicyId);
       
       Map<Id,SVMXC__SM_Overnight_Stay_Policy__c> overnightPolicies = new Map<Id,SVMXC__SM_Overnight_Stay_Policy__c>([SELECT CreatedById,CreatedDate,Id,IsDeleted,
        LastModifiedById,LastModifiedDate,Name,OwnerId,SVMXC__SM_Active__c,SVMXC__SM_Allow_Friday_ONS__c,SVMXC__SM_Allow_Monday_ONS__c,SVMXC__SM_Allow_Saturday_ONS__c,
        SVMXC__SM_Allow_Sunday_ONS__c,SVMXC__SM_Allow_Thursday_ONS__c,SVMXC__SM_Allow_Tuesday_ONS__c,SVMXC__SM_Allow_Wednesday_ONS__c,SVMXC__SM_Consecutive_ONS_Per_Week__c,
        SVMXC__SM_Drive_Distance_Threshold__c,SVMXC__SM_Drive_Time_Threshold__c,SVMXC__SM_Policy_Override__c,SVMXC__SM_Total_ONS_Per_Week__c,SVMXC__SM_Minimum_Recovery_Days__c,SystemModstamp
        FROM SVMXC__SM_Overnight_Stay_Policy__c where SVMXC__SM_Active__c=true AND id IN: overnightIds]);
        
        //Fetch the ploicy of the technician, If not available fetch it from the territory.
        String technicianId;
        for(SVMXC__Service_Group_Members__c tech: technicians){
            technicianId = tech.id;
            if(technicianNPolicyMap.containsKey(technicianId) && technicianNPolicyMap.get(technicianId) != null){
                technicianOvernightMap.put(technicianId,overnightPolicies.get(technicianNPolicyMap.get(technicianId)));
            }else{
                if(overnightPolicies.containsKey(territoryOvernightPolicyId) && overnightPolicies.get(territoryOvernightPolicyId) != null )
                    technicianOvernightMap.put(technicianId,overnightPolicies.get(territoryOvernightPolicyId));
            }
         
        }
        return technicianOvernightMap;
     
    }
    
    
     //Returns the active overnight policy associated to the territory
    public SVMXC__SM_Overnight_Stay_Policy__c  getOvernightPoliciesByTeritory(String territory){
     SVMXC__Territory__c ter = [Select id, SVMXC__SM_Overnight_Stay_Policy__c from SVMXC__Territory__c where id =:territory ];
     
     SVMXC__SM_Overnight_Stay_Policy__c tpolicy = null;
     
     if(null != ter.SVMXC__SM_Overnight_Stay_Policy__c){
         tpolicy =  [SELECT CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,SVMXC__SM_Active__c,SVMXC__SM_Allow_Friday_ONS__c,
        SVMXC__SM_Allow_Monday_ONS__c,SVMXC__SM_Allow_Saturday_ONS__c, SVMXC__SM_Allow_Sunday_ONS__c,SVMXC__SM_Allow_Thursday_ONS__c,SVMXC__SM_Allow_Tuesday_ONS__c,
        SVMXC__SM_Allow_Wednesday_ONS__c,SVMXC__SM_Consecutive_ONS_Per_Week__c,SVMXC__SM_Drive_Distance_Threshold__c,SVMXC__SM_Drive_Time_Threshold__c,
        SVMXC__SM_Policy_Override__c,SVMXC__SM_Total_ONS_Per_Week__c,SystemModstamp 
        FROM SVMXC__SM_Overnight_Stay_Policy__c where SVMXC__SM_Active__c=true AND id=:ter.SVMXC__SM_Overnight_Stay_Policy__c];
        
     }
        
     return tpolicy;
     
    }
  
    //This method sets all the overnight parameters to the technician additional details obbject
    public SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP updateTechnicianAddtionalWithOvernightPlicy(SVMXC__Service_Group_Members__c tech,
                Map<String,SVMXC__SM_Overnight_Stay_Policy__c> technicianOvernightMap,SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP techAdditionalDetails,
                Boolean isMile){
    
       SVMXC__SM_Overnight_Stay_Policy__c  opolicy = technicianOvernightMap.get(tech.id);
       if(null != opolicy){
            if(null != opolicy.SVMXC__SM_Drive_Time_Threshold__c){
                 techAdditionalDetails.thresholdDuration  = (opolicy.SVMXC__SM_Drive_Time_Threshold__c)* 60;
            }
            if(null != opolicy.SVMXC__SM_Drive_Distance_Threshold__c)
            {
                if(isMile){
                    techAdditionalDetails.thresholdDistance= (opolicy.SVMXC__SM_Drive_Distance_Threshold__c)*(1609.34);
                }else{
                    techAdditionalDetails.thresholdDistance= (opolicy.SVMXC__SM_Drive_Distance_Threshold__c)*(1000);
                }
                
            }
           techAdditionalDetails.totalStaysOut = opolicy.SVMXC__SM_Total_ONS_Per_Week__c;
           techAdditionalDetails.staysOutInRow  = opolicy.SVMXC__SM_Consecutive_ONS_Per_Week__c;
           techAdditionalDetails.isPolicyOverRidesEfficiency = opolicy.SVMXC__SM_Policy_Override__c;
           techAdditionalDetails.minRecoverHours   = 0 ;
           //techAdditionalDetails.minRecoverHours = opolicy.SVMXC__SM_Min_Recovery_Hours__c;
           //techAdditionalDetails.startOfTheWeek = opolicy.SVMXC__Start_of_the_week__c; 
       }
       
       return techAdditionalDetails;
    }
    
    //This method constructs the workorder additional details object
     public SMAX_OptiMax_Engine_WS.WorkOrderAdditionalDetails_WP  buildWorkOrderAddtiionalDetails(){
    
      SMAX_OptiMax_Engine_WS.WorkOrderAdditionalDetails_WP workorderAddtionalDetails = new SMAX_OptiMax_Engine_WS.WorkOrderAdditionalDetails_WP();
      workorderAddtionalDetails.isAvailableForOvernightStay  = true;
      
      return workorderAddtionalDetails;
      
    }
    
  }
}

/* Test Code
SMAX_OptiMax_EngineUtils clsTest = new SMAX_OptiMax_EngineUtils();
list<Id> lstWOId = new list<Id>();
lstWOId.add('a0q70000001dEW8');
clsTest.getDispatchProcessProperties('a0K70000008qxM2EAI');
map<Id, SVMXC__Service_Order__c> mapWO = clsTest.buildQualifiedTechnicians(lstWOId, null, 'a0x700000003Phz');
update mapWO.values();

list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
DPKeyVal.name = 'DISPATCHPROCESSID';
DPKeyVal.value = 'a1170000000ilIK';
TEKeyVal.name = 'TERRITORYID';
TEKeyVal.value = 'a1b70000000RiFt_FULL';
keyValuePairs.add(DPKeyVal);
keyValuePairs.add(TEKeyVal);
SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
*/