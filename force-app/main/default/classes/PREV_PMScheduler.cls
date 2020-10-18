global with sharing class PREV_PMScheduler implements Database.Batchable<SObject>
{
  public Map<ID ,SVMXC__PM_Plan__c> validPMPlanMap;
  public List<SVMXC__PM_Plan__c> validPMPlan  ;
  public List<SVMXC__PM_Coverage__c> pmCoverage;
  public Map<string ,List<SVMXC__PM_Coverage__c>> validPMCoverageMap;
  public map<string, List<SVMXC__Service_Order__c>>  mapPMPlanWO,mapPMPlanNewWO ;
  public map<string, integer> mapPMPlanNoofWO; 
  public List<SVMXC__Service_Order__c> lstWO ;
  public map<string, List<SVMXC__Service_Order_Line__c>>  mapWOWOLine ;
  public map<string, integer> mapWONoofWOLine; 
  public List<SVMXC__Service_Order_Line__c> lstWOLine;
  public Map<ID ,list<SVMXC__Service_Order_Line__c>> woLineRecords;
  public ID RTypId; 
  public List<SVMXC__Service_Order_Line__c> sOrderLine ;
  public List<SVMXC__PM_Plan__c> pmplantoupdate;
  public map<string, map<string, string>> mapFieldmap ; 
  public map<string, list<SVMXC__ServiceMax_Config_Data__c>> mapMapIdConfigData ;
  public Map<ID, case> mapWOCases;
  public Map<ID, case> mapPMPlanCases;
  public Map<String, String> mapIBIDNAME;
  public map<string, SVMXC__ServiceMax_Processes__c> mapSVMXMap ;
  public map<string, set<string>> mapSCWOFields;
  public map<string, set<string>> mapIBWOFields;
  public map<string, set<string>> mapWOCaseFields ;
  public map<string, set<string>> mapSCCaseFields ;
  public map<string, set<string>> mapIBCaseFields ;
  public map<string, Map<string,string>> mapPmplanWOWNumber;
  public map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapSCWOFieldsMap ;
  public map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapIBWOFieldsMap ;
  public map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapWOCaseFieldsMap;
  public map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapSCCaseFieldsMap;
  public map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapIBCaseFieldsMap;
  public set<string> setIBIds;
  public set<string> setWoIds;
  public List<Task> tasklist ;
  public SVMXC.COMM_Utils utils;
  public SVMXC.COMM_Utils_ManageTags commUtil;
  public Map<String, String> svmxTagList;
  public String ExceptionSting='';
  public String WarrningSting='';
  
  global Database.QueryLocator start(Database.BatchableContext BC)
  {
      /* (Defect 002243): Neeraj(Nov-16th): Check the status of SCON by adding s.SVMXC__Service_Contract__r.SVMXC__Active__c = true in where clause. */
        return   Database.getQueryLocator('Select s.SystemModstamp,s.SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c, s.SVMXC__Service_Contract__r.Name, s.SVMXC__Service_Contract__c,s.SVMXC__Dispatch_Process__c, s.SVMXC__Work_Order_Date__c, s.SVMXC__Work_Order_Assign_To__c, s.SVMXC__Work_Order_Assign_To_User__c, s.SVMXC__Work_Order_Assign_To_Queue__c, s.SVMXC__Time_and_Counters__c, s.SVMXC__Success_Email_ID__c, s.SVMXC__Status__c, s.SVMXC__Start_Date__c, s.SVMXC__Schedule_Type__c, s.SVMXC__Select__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Processed__c, s.SVMXC__Number_of_Work_orders__c, s.SVMXC__Number_of_Cases__c, s.SVMXC__Next_PM_Date__c, s.SVMXC__Last_PM_Date__c, s.SVMXC__Frequency__c, s.SVMXC__Frequency_Unit__c, s.SVMXC__Field_map_for_wo__c, s.SVMXC__Field_map_for_Case__c, s.SVMXC__Error_Email_ID__c,s.SVMXC__End_Date__c, s.SVMXC__Description__c, s.SVMXC__Create_Parts_Requests__c, s.SVMXC__Create_Work_Order__c, s.SVMXC__Create_Case__c, s.SVMXC__Case_Assign_To__c, s.SVMXC__Case_Assign_To_User__c, s.SVMXC__Case_Assign_To_Queue__c, s.SVMXC__Activity_On_Success__c, s.SVMXC__Activity_On_Error__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById,SVMXC__Service_Contract__r.SVMXC__Primary_Technician__r.SVMXC__Salesforce_User__c From SVMXC__PM_Plan__c s where s.SVMXC__Status__c =\'Active\' and s.SVMXC__Schedule_Type__c=\'Time Based\' and s.SVMXC__Service_Contract__r.SVMXC__Active__c = true and s.SVMXC__Work_Order_Date__c ='+String.valueOf(Date.Today()));
    
    
  }
  global void execute(Database.BatchableContext BC, List<sObject> sObjectList)
  {
    utils = new SVMXC.COMM_Utils(); 
    commUtil = new SVMXC.COMM_Utils_ManageTags();
    //svmxTagList = commUtil.SVMX_getTagList('PREV003');
    lstWOLine = new List<SVMXC__Service_Order_Line__c>();
    mapWONoofWOLine = new map<string, integer>(); 
    mapPMPlanWO = new map<string, List<SVMXC__Service_Order__c>>();
    mapPMPlanNewWO = new map<string, List<SVMXC__Service_Order__c>>();
    mapPMPlanNoofWO = new map<string, integer>();
    lstWO =  new List<SVMXC__Service_Order__c>();
    mapWOWOLine = new map<string, List<SVMXC__Service_Order_Line__c>>();
    mapFieldmap = new map<string, map<string, string>>(); 
    mapMapIdConfigData = new map<string, list<SVMXC__ServiceMax_Config_Data__c>>();
    mapSVMXMap = new map<string, SVMXC__ServiceMax_Processes__c>();
    mapWOCases=new Map<ID, case>();
    mapPMPlanCases=new Map<ID, case>();
    mapSCWOFields = new map<string, set<string>>();
    mapIBWOFields = new map<string, set<string>>();
    mapWOCaseFields = new map<string, set<string>>();
    mapSCCaseFields = new map<string, set<string>>();
    mapIBCaseFields = new map<string, set<string>>();
    mapIBIDNAME = new map<String,string>();
    setIBIds = new set<string>();
    setWoIds = new set<string>();
    tasklist =new List<Task>();
     
    mapSCWOFieldsMap = new map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
    mapIBWOFieldsMap = new map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
    mapWOCaseFieldsMap = new map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
    mapSCCaseFieldsMap = new map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
    mapIBCaseFieldsMap = new map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
    List<SVMXC__PM_Plan__c>  PMPlans =(List<SVMXC__PM_Plan__c>)(sObjectList);
    
    List<SVMXC__PM_Plan__c>  lstPMPlan =new List<SVMXC__PM_Plan__c>();  
    for(SVMXC__PM_Plan__c allplans:PMPlans){
      
      if(allplans.SVMXC__Next_PM_Date__c <=allplans.SVMXC__End_Date__c && allplans.SVMXC__Start_Date__c <= System.today()){
        if(allplans.SVMXC__Processed__c != true)
        allplans.SVMXC__Processed__c =true;
        lstPMPlan.add(allplans);
      }
      
    }
    
    if(lstPMPlan!=null && lstPMPlan.size()>0 ){   
        upsert lstPMPlan;
    }
    validPMPlan = new List<SVMXC__PM_Plan__c>();
    validPMPlanMap = new Map<ID ,SVMXC__PM_Plan__c>();
    set<string> setCaseMapIDs = new set<string>();
    set<string> setWOMapIDs = new set<string>();
    set<string> setSCFields = new set<string>();
    set<string> setIBFields = new set<string>();
    map<string, string> mapPMPlanSC = new map<string, string>();
    try
    {
      if(lstPMPlan != null && lstPMPlan.size()>0)
      {  
        validPMPlanMap.putAll(lstPMPlan);
        validPMPlan.addAll(lstPMPlan);
        for(SVMXC__PM_Plan__c oPMPlan :lstPMPlan)
        {
          if(!mapFieldmap.ContainsKey(oPMPlan.id))
            mapFieldmap.put(oPMPlan.id, new map<string, string>());
          if(oPMPlan.SVMXC__Field_map_for_Case__c != null && oPMPlan.SVMXC__Field_map_for_Case__c.length() > 0)
          {
            mapFieldmap.get(oPMPlan.id).put('CASE', oPMPlan.SVMXC__Field_map_for_Case__c);
            setCaseMapIDs.add(oPMPlan.SVMXC__Field_map_for_Case__c);
          }
          if(oPMPlan.SVMXC__Field_map_for_wo__c != null && oPMPlan.SVMXC__Field_map_for_wo__c.length() > 0)
          {
            mapFieldmap.get(oPMPlan.id).put('WORKORDER', oPMPlan.SVMXC__Field_map_for_wo__c);
            setWOMapIDs.add(oPMPlan.SVMXC__Field_map_for_wo__c);
          }
          mapPMPlanWO.put(oPMPlan.id, new List<SVMXC__Service_Order__c>());
          mapPMPlanSC.put(oPMPlan.Id, oPMPlan.SVMXC__Service_Contract__c);
          mapPMPlanNoofWO.put(oPMPlan.Id, 0);
        }
        list<SVMXC__ServiceMax_Processes__c> lstSVMXMaps = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c From SVMXC__ServiceMax_Processes__c where SVMXC__MapID__c in :setCaseMapIDs OR SVMXC__MapID__c in :setWOMapIDs];
        List<SVMXC__ServiceMax_Config_Data__c> retFldMappings = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> tmpretFldMappings = new List<SVMXC__ServiceMax_Config_Data__c>();
            tmpretFldMappings = [SELECT SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, 
                                  SVMXC__MapID__r.SVMXC__MapID__c, SVMXC__MapID__c, SVMXC__Active__c 
                                  From SVMXC__ServiceMax_Config_Data__c 
                                  where (SVMXC__MapID__r.SVMXC__MapID__c in :setCaseMapIDs 
                                      OR SVMXC__MapID__r.SVMXC__MapID__c in :setWOMapIDs) 
                                  AND SVMXC__Active__c = true 
                                  AND recordType.Name = 'Field Mapping'];
                                 

        //--------------------------- this part is added by Sharad for bug  No : 004115 for escape field which name is null------------------------------------------------------------------------------------------------------------------------
              for(SVMXC__ServiceMax_Config_Data__c cfgdta : tmpretFldMappings)
              {
                if(cfgdta.SVMXC__Source_Field_Name__c != null )
                    retFldMappings.add(cfgdta);
              }
        //---------------------------------------------------------------------------------------------------------------------------     
              if(lstSVMXMaps != null && lstSVMXMaps.size() > 0)
            {
              for(SVMXC__ServiceMax_Processes__c SVMXProcess :lstSVMXMaps)
              {
                mapSVMXMap.put(SVMXProcess.SVMXC__MapID__c ,SVMXProcess);
              }
            }                
              for(SVMXC__ServiceMax_Config_Data__c SVMXConfigData : retFldMappings)
              {
                if(!mapMapIdConfigData.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                  mapMapIdConfigData.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                mapMapIdConfigData.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData);
          
                if( mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Source_Object_Name__c == 'SVMXC__Service_Contract__c' && mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Target_Object_Name__c == 'SVMXC__Service_Order__c')
                {
                  if(!mapSCWOFields.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapSCWOFields.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new set<string>());
                  mapSCWOFields.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData.SVMXC__Source_Field_Name__c);

                  if(!mapSCWOFieldsMap.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapSCWOFieldsMap.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                  mapSCWOFieldsMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData);
                }
             if( mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Source_Object_Name__c == 'SVMXC__Installed_Product__c' && mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Target_Object_Name__c == 'SVMXC__Service_Order__c')
                {
                  if(!mapIBWOFields.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapIBWOFields.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new set<string>());
                  mapIBWOFields.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData.SVMXC__Source_Field_Name__c);
                  
                  if(!mapIBWOFieldsMap.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapIBWOFieldsMap.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                  mapIBWOFieldsMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData);
                }
             if( mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Source_Object_Name__c == 'SVMXC__Service_Order__c' && mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Target_Object_Name__c == 'Case')
                {
                  if(!mapWOCaseFields.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapWOCaseFields.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new set<string>());
                  mapWOCaseFields.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData.SVMXC__Source_Field_Name__c);
                  
                  if(!mapWOCaseFieldsMap.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapWOCaseFieldsMap.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                  mapWOCaseFieldsMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData);
                }
            if( mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Source_Object_Name__c == 'SVMXC__Service_Contract__c' && mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Target_Object_Name__c == 'Case')
                {
                  if(!mapSCCaseFields.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapSCCaseFields.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new set<string>());
                  mapSCCaseFields.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData.SVMXC__Source_Field_Name__c);
                  
                  if(!mapSCCaseFieldsMap.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                    mapSCCaseFieldsMap.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                  mapSCCaseFieldsMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData);
                }
                //setSCFields.add(SVMXConfigData.SVMXC__Source_Field_Name__c);
                //not applicable to this realise
                /*
            if( mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Source_Object_Name__c == 'SVMXC__Installed_Product__c' && mapSVMXMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).SVMXC__Target_Object_Name__c == 'Case')
            {
              if(!mapIBCaseFields.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                mapIBCaseFields.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new set<string>());
              mapIBCaseFields.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData.SVMXC__Source_Field_Name__c);
              
              if(!mapIBCaseFieldsMap.containsKey(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c))
                mapIBCaseFieldsMap.put(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c, new list<SVMXC__ServiceMax_Config_Data__c>());
              mapIBCaseFieldsMap.get(SVMXConfigData.SVMXC__MapID__r.SVMXC__MapID__c).add(SVMXConfigData);
            }
            */
              }
           
              
              for( set<string> setstr :mapSCCaseFields.values())
              {
                setSCFields.addAll(setstr);
              }
              for( set<string> setstr :mapSCWOFields.values())
              {
                setSCFields.addAll(setstr);
              }
              /*
              for( set<string> setstr :mapIBCaseFields.values())
              {
                setIBFields.addAll(setstr);
              }*/
              
              
            map<string, SVMXC__Service_Contract__c> mapSC = new map<string, SVMXC__Service_Contract__c>();
        string strSCIds = getStringFromList(mapPMPlanSC.Values());
        string strSCFields = getFieldsStringFromSet(SetSCFields);
        try
        {
              if(strSCFields.length() > 0 && strSCIds.length() > 0)
                mapSC.putAll((list<SVMXC__Service_Contract__c>)database.Query('select '+ strSCFields + ' from SVMXC__Service_Contract__c where ID in (' + strSCIds + ')'));
        }
        catch(exception ex)
        {
            ExceptionSting=ex.getMessage();
        }  
            SVMXPDEV_ValidPMCoverage();
            map<string, SVMXC__Installed_Product__c> mapIB = new map<string, SVMXC__Installed_Product__c>();
            string strIBIds = getStringFromSet(setIBIds);
            string strIBFields = getAllFields(mapIBWOFields);
            string strIBFields2=''; 
            /*
            if(setIBFields!=null && setIBFields.size()>0)
            {
              for(String ibf:setIBFields)
              {
                if(strIBFields2.length() > 0)
                  strIBFields2 += ',';
                strIBFields2 += ibf;
              }
            }
            //string strIBFields2 = getAllFields(setIBFields);
            if(strIBFields.length() > 0 && strIBFields2.length() > 0)
                {
                    strIBFields += ', '+strIBFields2;
                }
            if(strIBFields.length() == 0 && strIBFields2.length() > 0)
                {
                    strIBFields += strIBFields2;
                }
                */
                
            try
        {
          if(strIBFields.length() > 0 && strIBIds.length() > 0)
          {
              mapIB.putAll((list<SVMXC__Installed_Product__c>)database.Query('select '+ strIBFields + ' from SVMXC__Installed_Product__c where ID in (' + strIBIds + ')'));
          }
        }
        catch(exception ex)
        {
          ExceptionSting=ExceptionSting+ex.getMessage();
        }
            
            
        for(string strPMId :validPMPlanMap.KeySet())
        {
          if(validPMPlanMap.get(strPMId).SVMXC__Number_of_Work_orders__c.ToUpperCase() == 'ONE PER PRODUCT' && validPMCoverageMap.containskey(strPMId))
          {
            for(SVMXC__PM_Coverage__c oPMCoverage :validPMCoverageMap.get(strPMId))
            {
              SVMXC__Service_Order__c sOrder = new SVMXC__Service_Order__c();
              
              if( mapSCWOFieldsMap.ContainsKey(validPMPlanMap.get(strPMId).SVMXC__Field_map_for_wo__c)){
                sOrder = getServiceOrder(mapSCWOFieldsMap.get(validPMPlanMap.get(strPMId).SVMXC__Field_map_for_wo__c), mapSC.get(validPMPlanMap.get(strPMId).SVMXC__Service_Contract__c));
              }
              else if( mapIBWOFieldsMap.ContainsKey(validPMPlanMap.get(strPMId).SVMXC__Field_map_for_wo__c))
                sOrder = getServiceOrder(mapIBWOFieldsMap.get(validPMPlanMap.get(strPMId).SVMXC__Field_map_for_wo__c), mapIB.get(oPMCoverage.SVMXC__Product_Name__c));
              
              sOrder.SVMXC__Is_PM_Work_Order__c = true;                    
              sOrder.SVMXC__PM_Plan__c = validPMPlanMap.get(strPMId).id;
              sOrder.SVMXC__Scheduled_Date__c = validPMPlanMap.get(strPMId).SVMXC__Next_PM_Date__c;
              sOrder.SVMXC__Component__c = oPMCoverage.SVMXC__Product_Name__c;
  
              if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'USER')
              {
                if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_User__c != null)
                  sOrder.OwnerId= validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_User__c;
              }
              if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'QUEUE')
              {
                if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_Queue__c != null)
                  sOrder.OwnerId= validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_Queue__c;
              }
              if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'DISPATCH PROCESS')
              {
                if(validPMPlanMap.get(strPMId).SVMXC__Dispatch_Process__c != null)
                  sOrder.SVMXC__Dispatch_Process__c= validPMPlanMap.get(strPMId).SVMXC__Dispatch_Process__c;
              }
              if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'PRIMARY TECHNICIAN')
              {
                if(validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c != null){
                    sOrder.SVMXC__Group_Member__c = validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c;
                if( validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c != null && validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__r.SVMXC__Salesforce_User__c != null)
                    sOrder.OwnerId = validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__r.SVMXC__Salesforce_User__c;
                }
              }
              
              mapPMPlanWO.get(strPMId).add(sOrder);
              mapPMPlanNoofWO.put(strPMId, mapPMPlanNoofWO.get(strPMId) + 1);
            }
          }
          if(validPMPlanMap.get(strPMId).SVMXC__Number_of_Work_orders__c.ToUpperCase() == 'ONE PER PLAN')
          {
            SVMXC__Service_Order__c sOrder = new SVMXC__Service_Order__c();
            
            if( mapSCWOFieldsMap.ContainsKey(validPMPlanMap.get(strPMId).SVMXC__Field_map_for_wo__c))
              sOrder = getServiceOrder(mapSCWOFieldsMap.get(validPMPlanMap.get(strPMId).SVMXC__Field_map_for_wo__c), mapSC.get(validPMPlanMap.get(strPMId).SVMXC__Service_Contract__c));
            
            sOrder.SVMXC__Is_PM_Work_Order__c = true;                    
            sOrder.SVMXC__PM_Plan__c = validPMPlanMap.get(strPMId).id;
            sOrder.SVMXC__Scheduled_Date__c = validPMPlanMap.get(strPMId).SVMXC__Next_PM_Date__c;
  
            if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'USER' && validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_User__c != null)
              sOrder.OwnerId= validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_User__c;
            if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'QUEUE' && validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_Queue__c != null)
              sOrder.OwnerId= validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To_Queue__c;
            if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'DISPATCH PROCESS' && validPMPlanMap.get(strPMId).SVMXC__Dispatch_Process__c != null)
              sOrder.SVMXC__Dispatch_Process__c= validPMPlanMap.get(strPMId).SVMXC__Dispatch_Process__c;
            if(validPMPlanMap.get(strPMId).SVMXC__Work_Order_Assign_To__c.toUpperCase() == 'PRIMARY TECHNICIAN')
              {
                if(validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c != null){
                    sOrder.SVMXC__Group_Member__c = validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c;
                if( validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c != null && validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__r.SVMXC__Salesforce_User__c != null)
                    sOrder.OwnerId = validPMPlanMap.get(strPMId).SVMXC__Service_Contract__r.SVMXC__Primary_Technician__r.SVMXC__Salesforce_User__c;
              }
                
              }
            mapPMPlanWO.get(strPMId).add(sOrder);
            mapPMPlanNoofWO.put(strPMId, mapPMPlanNoofWO.get(strPMId) + 1);
          }
        }
        for(string str :mapPMPlanWO.KeySet())
        {
          lstWO.addAll(mapPMPlanWO.get(str));
        }
        try
        {        
          
          if(lstWO != null && lstWO.size() > 0){
               
                    List<SVMXC__Service_Order__c> templist=new List<SVMXC__Service_Order__c>();
                    List<SVMXC__Service_Order__c> finallist=new List<SVMXC__Service_Order__c>();
                        for(SVMXC__Service_Order__c wo:lstWO){
                            templist.add(wo);
                            if(templist.size()==100){
                                upsert templist;
                                finallist.addAll(templist);
                                templist.clear();
                            }                            
                        }                        
                        lstWO.clear();
                        if(templist.size()>0){
                        upsert templist;
                        lstWO.addAll(templist);
                        }
                        if(finallist.size()>0){
                            lstWO.addAll(finallist);
                        } 
             
            for(SVMXC__Service_Order__c oWO :lstWO)
            {
              setWoIds.add(oWO.id);
            }
            
          }
            
            
        }
        catch(exception ex)
        {
          ExceptionSting=ExceptionSting+ex.getMessage();
        }
        RTypId = getRecordType().id;
        for(string strPMId :validPMPlanMap.KeySet())
        {
          if(validPMPlanMap.get(strPMId).SVMXC__Number_of_Work_orders__c.ToUpperCase() == 'ONE PER PLAN')
          {
            for(SVMXC__PM_Coverage__c oPMCoverage :validPMCoverageMap.get(strPMId))
            {
              for(SVMXC__Service_Order__c oWO :mapPMPlanWO.get(strPMId))
              {
                if(!mapWOWOLine.ContainsKey(oWO.Id))
                {
                  mapWOWOLine.put(oWO.Id, new List<SVMXC__Service_Order_Line__c>());
                  mapWONoofWOLine.put(oWO.Id, 0);
                }
                mapWOWOLine.get(oWO.Id).add(new SVMXC__Service_Order_Line__c(   
                                              SVMXC__Serial_Number__c=oPMCoverage.SVMXC__Product_Name__c,
                                              SVMXC__Service_Order__c=oWO.Id,
                                              RecordTypeId =RTypId,
                                              SVMXC__Actual_Quantity2__c =1 
                                               ));
                mapWONoofWOLine.put(oWO.Id, mapWONoofWOLine.get(oWO.Id) + 1);
              }
            }
          }
        }
        
        for(string str :mapWOWOLine.KeySet())
        {
          lstWOLine.addAll(mapWOWOLine.get(str));
        }
        try
        {
          if(lstWOLine != null && lstWOLine.size() > 0)
          {  
            
            //upsert lstWOLine;
              List<SVMXC__Service_Order_Line__c> templistwl=new List<SVMXC__Service_Order_Line__c>();
              List<SVMXC__Service_Order_Line__c> finallistwl=new List<SVMXC__Service_Order_Line__c>();
                    
                    for(SVMXC__Service_Order_Line__c woli:lstWOLine){
                            templistwl.add(woli);
                            if(templistwl.size()==100){
                                upsert templistwl;
                                finallistwl.addAll(templistwl);
                                templistwl.clear();
                            }
                            
                        }
                        
                        lstWOLine.clear();
                        if(templistwl.size()>0){
                        upsert templistwl;
                        lstWOLine.addAll(templistwl);
                        }
                        if(finallistwl.size()>0){
                            lstWOLine.addAll(finallistwl);
                        }
            
          }
        }
        catch(exception ex)
        {
            WarrningSting=WarrningSting+ex.getMessage();
        }
        for(ID vpmp : validPMPlanMap.keySet())
        {
          SVMXC__PM_Plan__c planObj= validPMPlanMap.get(vpmp);
          if(planObj.SVMXC__Create_Case__c ==true)
          {
            if(planObj.SVMXC__Number_of_Cases__c.toUpperCase()== 'ONE PER WORK ORDER')
            {
              for(SVMXC__Service_Order__c sorder: mapPMPlanWO.get(vpmp))
              {
                if(sorder.SVMXC__PM_Plan__c == planObj.id)
                {
                  Case caseObj = new Case();
                  if( mapWOCaseFieldsMap.ContainsKey(planObj.SVMXC__Field_map_for_Case__c))
                    caseObj = getCase(mapWOCaseFieldsMap.get(planObj.SVMXC__Field_map_for_Case__c), sorder);
                  else if( mapSCCaseFieldsMap.ContainsKey(planObj.SVMXC__Field_map_for_Case__c))
                    caseObj = getCase(mapSCCaseFieldsMap.get(planObj.SVMXC__Field_map_for_Case__c), mapSC.get(planObj.SVMXC__Service_Contract__c));
                 // this is for ib to case 
                 /*
                  else if( mapIBCaseFieldsMap.ContainsKey(planObj.SVMXC__Field_map_for_Case__c))
                  {
                    system.debug('1234hari'+ mapIB.get(sorder.SVMXC__Component__c));
                    caseObj = getCase(mapIBCaseFieldsMap.get(planObj.SVMXC__Field_map_for_Case__c), mapIB.get(sorder.SVMXC__Component__c));
                  } 
                  */
                  
                  if(planObj.SVMXC__Case_Assign_To_User__c != null && planObj.SVMXC__Case_Assign_To__c.toUpperCase() == 'USER')
                    caseObj.OwnerId = planObj.SVMXC__Case_Assign_To_User__c;
                  if(planObj.SVMXC__Case_Assign_To_Queue__c != null && planObj.SVMXC__Case_Assign_To__c.toUpperCase() == 'QUEUE')
                    caseObj.OwnerId = planObj.SVMXC__Case_Assign_To_Queue__c;
                  
                  caseObj.SVMXC__Is_PM_Case__c =true;
                  caseObj.SVMXC__PM_Plan__c = planObj.id;
                  caseObj.SVMXC__Scheduled_Date__c = planObj.SVMXC__Next_PM_Date__c;
                  
                  mapWOCases.put(sorder.id, caseObj);
                }
              }
            }
            if(planObj.SVMXC__Number_of_Cases__c.toUpperCase()== 'ONE PER PLAN')
            {
              Case caseObj = new Case();
              
              if( mapSCCaseFieldsMap.ContainsKey(planObj.SVMXC__Field_map_for_Case__c))
              {
                 caseObj = getCase(mapSCCaseFieldsMap.get(planObj.SVMXC__Field_map_for_Case__c), mapSC.get(planObj.SVMXC__Service_Contract__c));
                 caseObj.SVMXC__Is_PM_Case__c =true;
                 caseObj.SVMXC__PM_Plan__c = planObj.id;
                 caseObj.SVMXC__Scheduled_Date__c = planObj.SVMXC__Next_PM_Date__c;
                 mapPMPlanCases.put(planObj.id, caseObj);
              }
            }
          }
        }
        try
        {
          if(mapWOCases != null && mapWOCases.size() > 0)
          {
            Map<ID,Case> tempmapWOCases=new Map<ID,Case>();
            
                for(ID woid:mapWOCases.keySet() ){
                        tempmapWOCases.put(woid,mapWOCases.get(woid));
                        
                        if(tempmapWOCases.size()==100){
                            insert tempmapWOCases.values();
                            for(ID twoid:tempmapWOCases.keySet()){
                                mapWOCases.put(twoid,tempmapWOCases.get(twoid));
                            } 
                            tempmapWOCases.clear();
                            
                        }
                        
                    
                }
                if(tempmapWOCases.size()>0){
                    insert tempmapWOCases.values();
                    for(ID twoid:tempmapWOCases.keySet()){
                                mapWOCases.put(twoid,tempmapWOCases.get(twoid));
                        }
                }
          
            
          }
            //insert mapWOCases.values();
          if(mapPMPlanCases != null && mapPMPlanCases.size() > 0)
            {
                Map<ID,Case> tempPMPlanCases=new Map<ID,Case>(); 
                
                for(ID pmid:mapPMPlanCases.keySet() ){
                        tempPMPlanCases.put(pmid,mapPMPlanCases.get(pmid));
                        
                        if(tempPMPlanCases.size()==100){
                            insert tempPMPlanCases.values();
                            for(ID tpmid:tempPMPlanCases.keySet()){
                                mapPMPlanCases.put(tpmid,tempPMPlanCases.get(tpmid));
                            } 
                            tempPMPlanCases.clear();
                            
                        }                        
                    
                }
                if(tempPMPlanCases.size()>0){
                    insert tempPMPlanCases.values();
                    for(ID ttpmid:tempPMPlanCases.keySet()){
                                mapPMPlanCases.put(ttpmid,tempPMPlanCases.get(ttpmid));
                        }
                }
                
           }
            //insert mapPMPlanCases.values();
        }
        catch(exception ex)
        {
          //ExceptionSting=ExceptionSting+ex.getMessage();
          WarrningSting=WarrningSting+ex.getMessage();
        }
        try
        {
          
          if((mapWOCases != null && mapWOCases.size() > 0 && lstWO != null && lstWO.size() > 0) || (mapPMPlanCases  != null && mapPMPlanCases.size() > 0))
          {
            for(SVMXC__Service_Order__c oWO :lstWO)
            {
                if(mapWOCases.ContainsKey(oWO.id))
                {
                    case cobj=mapWOCases.get(oWO.id);
                    oWO.SVMXC__Case__c=cobj.id;
                }
                else
                {
                    if(mapPMPlanCases.containsKey(oWO.SVMXC__PM_Plan__c))
                        oWO.SVMXC__Case__c=mapPMPlanCases.get(oWO.SVMXC__PM_Plan__c).Id;
                }
            }
            //upsert lstWO;
          
           
              List<SVMXC__Service_Order__c> templist=new List<SVMXC__Service_Order__c>();
                  List<SVMXC__Service_Order__c> finallist=new List<SVMXC__Service_Order__c>();
                        for(SVMXC__Service_Order__c wo:lstWO){
                            templist.add(wo);
                            if(templist.size()==100){
                                upsert templist;
                                finallist.addAll(templist);
                                templist.clear();
                                
                            }
                            
                        }
                        
                        lstWO.clear();
                        if(templist.size()>0){
                        upsert templist;
                        lstWO.addAll(templist);
                        }
                        if(finallist.size()>0){
                            lstWO.addAll(finallist);
                        }
          
            
          }
            
          for(SVMXC__Service_Order__c oWO :lstWO)
          {
            setWoIds.add(oWO.id);
          }
        }
        catch(exception ex)
        {
          WarrningSting=WarrningSting+ex.getMessage();
        }
      }
    }
    catch(exception ex)
    {
      ExceptionSting=ExceptionSting+ex.getMessage();
    }//*/
    list<Messaging.SingleEmailMessage> lstmails = new list<Messaging.SingleEmailMessage>();
    for(string strPMId :validPMPlanMap.KeySet())
    {
      SVMXC__PM_Plan__c oPMPlan = validPMPlanMap.get(strPMId);
      boolean isValidMail = false;
      boolean isInValidMail = false;
      
      try
      {
        for(SVMXC__Service_Order__c oWO :mapPMPlanWO.get(strPMId))
        {
          if(oWO == null || oWO.Id == null || ((string)oWO.ID).length() == 0)
            {isInValidMail = true;}
         
          else  
          {
            isValidMail = true;
            //System.debug('test area'+oPMPlan.SVMXC__Create_Case__c+(mapWOCases.get(oWO.Id))+(mapWOCases.get(oWO.Id).Id)+((string)mapWOCases.get(oWO.Id).Id).length());
           /*
            if(oPMPlan.SVMXC__Create_Case__c && (mapWOCases.get(oWO.Id) == null || mapWOCases.get(oWO.Id).Id == null || ((string)mapWOCases.get(oWO.Id).Id).length() == 0))
               {System.debug('block 0');isInValidMail = true;}
               */
          } 
          /*
          if(oPMPlan.SVMXC__Number_of_Work_orders__c.ToUpperCase() == 'ONE PER PLAN')
          {
            System.debug('This block one'+mapWOWOLine+mapWONoofWOLine+oWO.Id);
            if(mapWOWOLine != null && mapWONoofWOLine != null && mapWOWOLine.get(oWO.Id) != null)
            {
                System.debug('This block two'+mapWOWOLine);
              for(SVMXC__Service_Order_Line__c oWOLine :mapWOWOLine.get(oWO.Id))
              {
                    System.debug('This block Three'+oWOLine);
                if(oWOLine == null || oWOLine.Id == null || ((string)oWOLine.ID).length() == 0)
                  {System.debug('block 3');isInValidMail = true;}
                else
                  {System.debug('block 2');isValidMail = true;}
              }
            }
            else
              {System.debug('block 3');isInValidMail = true;}
          }
          */
         
        }
      }
      catch(exception ex)
      {
      }//*/
      try
      {
        //setWoIds
        
        Map<String , String> mapWOIdWONo=new Map<String, String>();
        Map<String , String> mapWOIdIBname=new Map<String, String>();
        Map<String , String> mapWOIdAccName=new Map<String, String>();
        Map<String , String> mapWOIdOwnerName=new Map<String, String>();
        Map<String , String> mapWOIdCaseNumber=new Map<String, String>();
        String WOId='';
        if(setWoIds.size()>0){
          
          for( String  st: setWoIds)
          {  
            if(WOId.length() > 0)
              WOId += ',';
            WOId += '\'' + st+ '\'';
          }
          if(WOId.length()>0)
          {
            String SOQL = ' Select s.SVMXC__PM_Plan__c, SVMXC__Case__r.CaseNumber ,Owner.Name,SVMXC__Company__r.Name, s.Name,s.SVMXC__Order_Type__c, s.SVMXC__Component__r.Name, s.Id From SVMXC__Service_Order__c s where s.id in ('+WOId+')'; 
            List<SVMXC__Service_Order__c> Service_Order = Database.query(SOQL);
            //Map<String ,String>  mapWOIdWONo = new Map<String ,String>();
            if(Service_Order!=null){
              for(SVMXC__Service_Order__c sorder:Service_Order){
                mapWOIdWONo.put(sorder.id,sorder.Name);
                mapWOIdIBname.put(sorder.id,sorder.SVMXC__Component__r.Name);
                mapWOIdAccName.put(sorder.id,sorder.SVMXC__Company__r.Name);
                mapWOIdOwnerName.put(sorder.id,sorder.Owner.Name);
                mapWOIdCaseNumber.put(sorder.id,sorder.SVMXC__Case__r.CaseNumber);
              }
              
            }
          }
        }
        
        
        if(isValidMail)
        {
          string strEmailBody = '';
          strEmailBody += getTAG011()+' '+oPMPlan.SVMXC__Service_Contract__r.Name +'/'+oPMPlan.Name+ ' '+getTAG013()+' ' + datetime.now() +' ' + getTAG012()+'\n';
          for(SVMXC__Service_Order__c oWO :mapPMPlanWO.get(strPMId))
          {
            strEmailBody += '-------------------------\n';
            strEmailBody += getTAG001()+' '+ mapWOIdWONo.get(oWO.id) +'\n';
            strEmailBody += getTAG002()+' ' + mapWOIdAccName.get(oWO.id)+ '\n';
            strEmailBody += getTAG003()+' ' + oWO.SVMXC__Order_Type__c +'\n';
            
            strEmailBody += getTAG015() + mapWOIdCaseNumber.get(oWO.id)  +'\n';
            
            if(oPMPlan.SVMXC__Number_of_Work_orders__c.ToUpperCase() != 'ONE PER PLAN')
            strEmailBody += getTAG004()+' ' + mapWOIdIBname.get(oWO.id) +'\n';
             if(oPMPlan.SVMXC__Number_of_Work_orders__c.ToUpperCase() == 'ONE PER PLAN')
            {
                strEmailBody += getTAG004()+' ';
                List<SVMXC__Service_Order_Line__c> oWOLine=new List<SVMXC__Service_Order_Line__c>();
                oWOLine = mapWOWOLine.get(oWO.Id);
                for(Integer j=0;j<oWOLine.size()-1;j++){
                    if(mapIBIDNAME.ContainsKey(oWOLine[j].SVMXC__Serial_Number__c)){
                          strEmailBody += mapIBIDNAME.get(oWOLine[j].SVMXC__Serial_Number__c)+',';
                    }
                }
                if(mapIBIDNAME.ContainsKey(oWOLine[oWOLine.size()-1].SVMXC__Serial_Number__c)){
                          strEmailBody += mapIBIDNAME.get(oWOLine[oWOLine.size()-1].SVMXC__Serial_Number__c)+'.';
                }                
              
              strEmailBody += '\n';
            }
            strEmailBody += getTAG005()+' ' + mapWOIdOwnerName.get(oWO.id)+'\n';
            strEmailBody += getTAG006()+' ' + oWO.SVMXC__Dispatch_Process__c +'\n';
            strEmailBody += '-------------------------\n';
            strEmailBody +=WarrningSting;
          
            
          }
          if(oPMPlan.SVMXC__Activity_On_Success__c == true){
            
          tasklist.add(new Task(WhatId = oPMPlan.id,  Subject =getTAG007(),Status = getTAG009(),Priority = getTAG010(),OwnerId =oPMPlan.OwnerId,IsReminderSet =False ,Description =strEmailBody ) );
          }
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setToAddresses(new String[] {oPMPlan.SVMXC__Success_Email_ID__c});
          mail.setSubject(getTAG007());
          mail.setPlainTextBody(strEmailBody);
          lstmails.add(mail);  
        }
        if(isInValidMail)
        {  /*
          if(oPMPlan.SVMXC__Error_Activity__c == true){
          tasklist.add(new Task(WhatId = oPMPlan.id,  Subject =getTAG008()+oPMPlan.Name,Status = 'Completed',Priority = 'Normal',OwnerId =oPMPlan.OwnerId,IsReminderSet =False ,Description = 'Error PM Completion' ) );
          }
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setToAddresses(new String[] {oPMPlan.SVMXC__Success_Email_ID__c});
          mail.setSubject('ERROR: PM Plan');
          mail.setPlainTextBody('ERROR: PM Plan1 '+oPMPlan.Name);
          lstmails.add(mail);
          */ 
          string strEmailBody = '';
          strEmailBody += getTAG011()+' '+oPMPlan.SVMXC__Service_Contract__r.Name +'/'+oPMPlan.Name+ ' '+getTAG014()+' ' + datetime.now()+' ' + getTAG012()+'\n';
          for(SVMXC__Service_Order__c oWO :mapPMPlanWO.get(strPMId))
          {
            strEmailBody += '-------------------------\n';
            
            strEmailBody += getTAG001()+' ' + mapWOIdWONo.get(oWO.id) +'\n';
            strEmailBody += getTAG002()+' ' + mapWOIdAccName.get(oWO.id)+ '\n';
            strEmailBody += getTAG003()+' ' + oWO.SVMXC__Order_Type__c +'\n';
             if(oPMPlan.SVMXC__Number_of_Work_orders__c.ToUpperCase() != 'ONE PER PLAN')
            strEmailBody += getTAG004()+' ' + mapWOIdIBname.get(oWO.id) +'\n';
             if(oPMPlan.SVMXC__Number_of_Work_orders__c.ToUpperCase() == 'ONE PER PLAN')
            {
               
               strEmailBody += getTAG004()+' ';
                List<SVMXC__Service_Order_Line__c> oWOLine=new List<SVMXC__Service_Order_Line__c>();
                oWOLine = mapWOWOLine.get(oWO.Id);
                for(Integer j=0;j<oWOLine.size()-1;j++){
                    if(mapIBIDNAME.ContainsKey(oWOLine[j].SVMXC__Serial_Number__c)){
                          strEmailBody += mapIBIDNAME.get(oWOLine[j].SVMXC__Serial_Number__c)+',';
                    }
                }
                if(mapIBIDNAME.ContainsKey(oWOLine[oWOLine.size()-1].SVMXC__Serial_Number__c)){
                          strEmailBody += mapIBIDNAME.get(oWOLine[oWOLine.size()-1].SVMXC__Serial_Number__c)+'.';
                }    
                /*strEmailBody += getTAG004()+' ';
              for(SVMXC__Service_Order_Line__c oWOLine :mapWOWOLine.get(oWO.Id))
              {
                if(mapIBIDNAME.ContainsKey(oWOLine.SVMXC__Serial_Number__c))
                strEmailBody += mapIBIDNAME.get(oWOLine.SVMXC__Serial_Number__c)+',';
              }*/
              strEmailBody += '\n';
            }
            
            strEmailBody += getTAG005()+' ' + mapWOIdOwnerName.get(oWO.id)+'\n';
            strEmailBody += getTAG006()+' ' + oWO.SVMXC__Dispatch_Process__c +'\n';
            strEmailBody += '-------------------------\n';
            strEmailBody +=ExceptionSting;
          
            
          }
          if(oPMPlan.SVMXC__Activity_On_Error__c == true){
          tasklist.add(new Task(WhatId = oPMPlan.id,  Subject =getTAG008(),Status = getTAG009(),Priority = getTAG010(),OwnerId =oPMPlan.OwnerId,IsReminderSet =False ,Description =strEmailBody ) );
          }
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setToAddresses(new String[] {oPMPlan.SVMXC__Success_Email_ID__c});
          mail.setSubject(getTAG008());
          mail.setPlainTextBody(strEmailBody);
          lstmails.add(mail);  
        }
        
      }
      catch(exception ex)
      {
        
      }//*/
      
      try
      {
        if(isValidMail)
        {
          try
          {
            if(oPMPlan.SVMXC__Frequency__c != null)
            {
              if(oPMPlan.SVMXC__Frequency_Unit__c.toUpperCase() == 'DAYS')
              {
                oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addDays(oPMPlan.SVMXC__Frequency__c.intValue());
                if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
                  oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addDays(oPMPlan.SVMXC__Number_of_Failures__c.intValue() * -1);
              }
              if(oPMPlan.SVMXC__Frequency_Unit__c.toUpperCase()== 'MONTHS')
              {
                oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addMonths(oPMPlan.SVMXC__Frequency__c.intValue());
                if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
                  oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addDays(oPMPlan.SVMXC__Number_of_Failures__c.intValue() * -1);
              }
              if(oPMPlan.SVMXC__Frequency_Unit__c.toUpperCase()== 'YEARS')
              {
                oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addYears(oPMPlan.SVMXC__Frequency__c.intValue());
                if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
                  oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addDays (oPMPlan.SVMXC__Number_of_Failures__c.intValue() * -1);
              }
              if(oPMPlan.SVMXC__Frequency_Unit__c.toUpperCase() == 'DAYS')
              {
                oPMPlan.SVMXC__Work_Order_Date__c = oPMPlan.SVMXC__Work_Order_Date__c.addDays(oPMPlan.SVMXC__Frequency__c.intValue());
                if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
                  oPMPlan.SVMXC__Work_Order_Date__c = oPMPlan.SVMXC__Work_Order_Date__c.addDays(oPMPlan.SVMXC__Number_of_Failures__c.intValue() * -1);
              }
              if(oPMPlan.SVMXC__Frequency_Unit__c.toUpperCase()== 'MONTHS')
              {
                oPMPlan.SVMXC__Work_Order_Date__c = oPMPlan.SVMXC__Work_Order_Date__c.addMonths(oPMPlan.SVMXC__Frequency__c.intValue());
                if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
                  oPMPlan.SVMXC__Work_Order_Date__c = oPMPlan.SVMXC__Work_Order_Date__c.addDays(oPMPlan.SVMXC__Number_of_Failures__c.intValue() * -1);
              }
              if(oPMPlan.SVMXC__Frequency_Unit__c.toUpperCase()== 'YEARS')
              {
                oPMPlan.SVMXC__Work_Order_Date__c = oPMPlan.SVMXC__Work_Order_Date__c.addYears(oPMPlan.SVMXC__Frequency__c.intValue());
                if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
                  oPMPlan.SVMXC__Work_Order_Date__c = oPMPlan.SVMXC__Work_Order_Date__c.addDays (oPMPlan.SVMXC__Number_of_Failures__c.intValue() * -1);
              }
              oPMPlan.SVMXC__Last_PM_Date__c = date.Today();
              oPMPlan.SVMXC__Number_of_Failures__c = 0;
            }
            if(oPMPlan.SVMXC__Processed__c ==true) {
                oPMPlan.SVMXC__Processed__c =false;
                
            }
          }catch(exception ex){}
        }
        else
        {
          oPMPlan.SVMXC__Next_PM_Date__c = oPMPlan.SVMXC__Next_PM_Date__c.addDays(1);
          if(oPMPlan.SVMXC__Number_of_Failures__c != null && oPMPlan.SVMXC__Number_of_Failures__c > 0)
            oPMPlan.SVMXC__Number_of_Failures__c += 1;
          else
            oPMPlan.SVMXC__Number_of_Failures__c = 1;
          oPMPlan.SVMXC__Last_PM_Date__c = date.Today();
        }
      }
      catch(exception ex)
      {
        
      }//*/
    }
    try
    {
      if(validPMPlanMap != null && validPMPlanMap.size() > 0)
       {
         //upsert validPMPlanMap.values();
            Map<ID,SVMXC__PM_Plan__c> tempvalidPMPlanMap=new Map<ID,SVMXC__PM_Plan__c>();
            
           
                
                for(ID pmid:validPMPlanMap.keySet() ){
                        tempvalidPMPlanMap.put(pmid,validPMPlanMap.get(pmid));
                        
                        if(tempvalidPMPlanMap.size()==100){
                            upsert tempvalidPMPlanMap.values();
                            for(ID tpmid:tempvalidPMPlanMap.keySet()){
                                validPMPlanMap.put(tpmid,tempvalidPMPlanMap.get(tpmid));
                            } 
                            tempvalidPMPlanMap.clear();                             
                        }                       
                    
                }
                if(tempvalidPMPlanMap.size()>0){
                    upsert tempvalidPMPlanMap.values();
                    for(ID twoid:tempvalidPMPlanMap.keySet()){
                                validPMPlanMap.put(twoid,tempvalidPMPlanMap.get(twoid));
                        }
                }
            
         }
       
    }catch(exception ex){}
    try
    {
      if(tasklist != null && tasklist.size() > 0)
        //upsert tasklist;
        {
            
                List<Task> templistTask=new List<Task>();
                  List<Task> finallistTask=new List<Task>();
                        for(Task tt:tasklist){
                            templistTask.add(tt);
                            if(templistTask.size()==100){
                                upsert templistTask;
                                finallistTask.addAll(templistTask);
                                templistTask.clear();
                            }
                            
                        }
                        
                        tasklist.clear();
                        if(templistTask.size()>0){
                        upsert templistTask;
                         tasklist.addAll(templistTask);
                        }
                        if(finallistTask.size()>0){
                            tasklist.addAll(finallistTask);
                        }
            
        }
        
    }catch(exception ex){}
    try
    {
      Messaging.sendEmail(lstmails);
    }catch(exception ex){}
  }
  global void finish(Database.BatchableContext BC)
  {
    /*
     if( validPMPlanMap.values().size()>0 && validPMPlanMap !=null){
        for(SVMXC__PM_Plan__c pmobj:validPMPlanMap.values())
        {
            if(pmobj.SVMXC__Processed__c ==true) {
                pmobj.SVMXC__Processed__c =false;
                
            }
        }
        
        update validPMPlanMap.values();
     }
     
     */
    
    /*AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =  :BC.getJobId()];
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {a.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Apex Sharing Recalculation ' + a.Status);
    mail.setPlainTextBody
    ('The batch Apex job processed ' + a.TotalJobItems +
    ' batches with '+ a.NumberOfErrors + ' failures.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }//*/
    
  }
  
  //all valid PMCoverage 
  public  Boolean SVMXPDEV_ValidPMCoverage()
  {
    pmCoverage =new List<SVMXC__PM_Coverage__c>();
    validPMCoverageMap=new Map<string ,List<SVMXC__PM_Coverage__c>>();
    if(validPMPlan != null && validPMPlan.size()>0)
    {
      String PCId='';
      for( SVMXC__PM_Plan__c pm : validPMPlan)
      {  
        if(PCId.length() > 0)
          PCId += ',';
        PCId += '\'' + String.valueOf(pm.id)+ '\'';
      }
      if(PCId.length()>0)
      {
        String SOQL = ' Select s.SVMXC__Product_Name__c, s.SVMXC__Product_Name__r.Name, s.SVMXC__PM_Plan__c, s.Id From SVMXC__PM_Coverage__c s where s.SVMXC__PM_Plan__c in ('+PCId+')'; 
        pmCoverage = Database.query(SOQL);
        for(SVMXC__PM_Coverage__c pmC:pmCoverage)
        {
          if(!validPMCoverageMap.ContainsKey(pmC.SVMXC__PM_Plan__c))
            validPMCoverageMap.put(pmC.SVMXC__PM_Plan__c, new List<SVMXC__PM_Coverage__c>());
          validPMCoverageMap.get(pmC.SVMXC__PM_Plan__c).add(pmC);
          setIBIds.add(pmC.SVMXC__Product_Name__c);
          mapIBIDNAME.put(pmC.SVMXC__Product_Name__c,pmC.SVMXC__Product_Name__r.Name);
          
        }
        
      }
    }
    if(validPMCoverageMap != null && validPMCoverageMap.size()>0)
      return true;
    else 
      return false;
  }
  
     
  public SVMXC__Service_Order__c getServiceOrder(list<SVMXC__ServiceMax_Config_Data__c> lstFieldMap, sObject sObj )
  {
    SVMXC__Service_Order__c oWO = new SVMXC__Service_Order__c();
    object s;
    for(SVMXC__ServiceMax_Config_Data__c o :lstFieldMap)
    {
      
      
      
      s= sObj.get((string)o.get('SVMXC__Source_Field_Name__c'));
      if(s != null )
        oWO.put((string)o.get('SVMXC__Target_Field_Name__c'), s);
    }
    
    return oWO;
  }
  public Case getCase(list<SVMXC__ServiceMax_Config_Data__c> lstFieldMap, sObject sObj )
  {
    Case oCase = new Case();
    object s;
    for(SVMXC__ServiceMax_Config_Data__c o :lstFieldMap)
    {
      s= sObj.get((string)o.get('SVMXC__Source_Field_Name__c'));
      if(s != null )
      oCase.put((string)o.get('SVMXC__Target_Field_Name__c'), s);
    }
    return oCase;
  }
  public string getAllFields(map<string, set<string>> mapFields)
  {
    string strFields = '';
    for(set<string> setStr :mapFields.values())
    {
      for(string str :setStr)
      {
        if(strFields.length() > 0)
          strFields += ',';
        strFields += str;
      }
    }
    return strFields;
  }
  public string getStringFromList(list<string> lstStr)
  {
    string strFinal ='';
    for(string str: lstStr)
    {  
      if(strFinal.length() > 0)
        strFinal += ',';
      strFinal += '\'' + str + '\'';
    }
    return strFinal;
  }
  public string getStringFromSet(set<string> setStr)
  {
    string strFinal ='';
    for(string str: setStr)
    {  
      if(strFinal.length() > 0)
        strFinal += ',';
      strFinal += '\'' + str + '\'';
    }
    return strFinal;
  }
  
  public string getFieldsStringFromSet(Set<string> setStr)
  {
    string strFinal ='';
    for(string str: setStr)
    {  
      if(strFinal.length() > 0)
        strFinal += ', ';
      strFinal += str;
    }
    return strFinal;
  }
  public RecordType getRecordType()
    {
         RecordType rType;
         String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__Service_Order_Line__c\' and Name=\'Products Serviced\'';        
         try
         {
            rType = Database.query(SOQL); 
         } 
         catch (Exception e){}
         return rType;
    }
  public static List<String> getFieldList( Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)
    {
        List<String> fieldList = new List<String>();        
        //build dynamic list of fieldnames
        for (String fieldKey : fieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            String fieldName = f.getName();            
            if (selectAllFields) 
                fieldList.add(fieldName);
            else 
            {
                if (f.getName()=='Id' || f.isNameField() || f.isCustom())
                    fieldList.add(fieldName);
            }
        }        
        return fieldList;
   }
   public static String getFieldNamesFromList(List<String> fieldList) 
   {
        String fieldNames = '';
        for (String field : fieldList) 
        {
            if (fieldNames.length()>0) 
                fieldNames += ',';
            fieldNames += field;
        }        
        return fieldNames;
    }
    public String getTAG001() {return system.label.PREV003_TAG001;} //Work Order Number:
    public String getTAG002() {return system.label.PREV003_TAG002;} //Account:
    public String getTAG003() {return system.label.PREV003_TAG003;} //Order Type:
    public String getTAG004() {return system.label.PREV003_TAG004;} //Component
    public String getTAG005() {return system.label.PREV003_TAG005;} //Owner Name
    public String getTAG006() {return system.label.PREV003_TAG006;} //Dispatch Process
    public String getTAG007() {return system.label.PREV003_TAG007;} //Successful PM Completion
    public String getTAG008() {return system.label.PREV003_TAG008;} //ERROR: PM Plan
    public String getTAG009() {return system.label.PREV003_TAG009;} //Completed
    public String getTAG010() {return system.label.PREV003_TAG010;} //Normal
    public String getTAG011() {return system.label.PREV003_TAG011;} //Service Contract/Preventive Maintenance plan 
    public String getTAG012() {return system.label.PREV003_TAG012;} //GMT
    public String getTAG013() {return system.label.PREV003_TAG013;} //successfully completed at
    public String getTAG014() {return system.label.PREV003_TAG014;} //failed to complete at 
     public String getTAG015() {return system.label.PREV003_TAG015;}//Case:
    
    
    
}