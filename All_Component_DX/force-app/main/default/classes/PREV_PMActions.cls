public with Sharing class PREV_PMActions
{
    public static Boolean isPMExecutionDone = false;
    Map<String, String> AllSubModuleSettings;
    public PREV_PMActions() 
    {   
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        List<String> settingIdList = new List<String>();
        settingIdList.add('SET001');
        settingIdList.add('SET002');
        settingIdList.add('SET003');
        AllSubModuleSettings = settings.SVMX_getSettingList('PREV004',settingIdList);
    }
    public PREV_PMActions(Map<String, String> tempAllSubModuleSettings) 
    {   
        AllSubModuleSettings = tempAllSubModuleSettings;
    }
    
    // Lots of scope for optimization
    public void WorkOrderActions(SVMXC__Service_Order__c[] objOld, SVMXC__Service_Order__c[] objNew, Boolean isUpdate, Boolean isInsert)
    {
        //List<SVMXC__Service_Order__c> ServoceOrderToProcess = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> ServoceOrderToCreatTask= new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Contract_Products__c> lstCoverdProd = new List<SVMXC__Service_Contract_Products__c>();
        List<SVMXC__Service_Order_Line__c> lstWOLine = new List<SVMXC__Service_Order_Line__c>();
        Set<ID> TaskTemplateID=new Set<ID>();
        Set<ID> SCONID = new Set<ID>();
        Set<ID> setWOID = new Set<ID>();
        Set<ID> setWOIDForPMsDelivered=new Set<ID>();
        Set<ID> setInstalledProdId = new Set<ID>();
        Map<Id, Integer> mapIBCount = new Map<Id, Integer>();
        //Map<string , List<String>> MapSContSOrderId=new Map<string , List<String>>(); Unused variable

        String createTasks = 'FALSE';
        String PriorityValue = '';   
        
        if (AllSubModuleSettings.containsKey('SET001')) createTasks = AllSubModuleSettings.get('SET001'); 
        if (AllSubModuleSettings.containsKey('SET002')) PriorityValue = AllSubModuleSettings.get('SET002');         
        
        //If work order trigger is update
        if(isUpdate)
        {
            for(Integer i=0;i<objOld.size();i++)
            {
                if(objOld[i].SVMXC__Order_Status__c !='Closed')
                {
                    //If work order status is closed and if the work order is of PM work order
                    if(objNew[i].SVMXC__Order_Status__c == 'Closed' && objNew[i].SVMXC__Is_PM_Work_Order__c == true)
                    {
                        //If PM plan has Service contract
                        if(objNew[i].SVMXC__PM_SC__c != null && objNew[i].SVMXC__PM_SC__c.length() > 0)
                        {
                            SCONID.add(objNew[i].SVMXC__PM_SC__c);
                            setWOIDForPMsDelivered.add(objNew[i].id);
                            if(objNew[i].SVMXC__Component__c !=null)
                            {
                                setInstalledProdId.add(objNew[i].SVMXC__Component__c);
                            }
                        }
                    }

                }

                if(objNew[i].SVMXC__PM_Plan__c != null &&
                    ((string)objNew[i].SVMXC__PM_Plan__c).length() > 0 &&
                    objNew[i].SVMXC__Group_Member__c != null &&
                    ((string)objNew[i].SVMXC__Group_Member__c).length() > 0 &&
                    objNew[i].SVMXC__PM_Tasks_Created__c != null &&
                    !objNew[i].SVMXC__PM_Tasks_Created__c){
                        setWOID.add(objNew[i].Id);
                        //ServoceOrderToProcess.add(objNew[i]);
                }
            }  
        }
        
        if(isInsert)
        {
            for(Integer i=0;i<objNew.size();i++)
            {
                if(objNew[i].SVMXC__Order_Status__c == 'Closed' && objNew[i].SVMXC__Is_PM_Work_Order__c == true)
                {
                    if(objNew[i].SVMXC__PM_SC__c != null && objNew[i].SVMXC__PM_SC__c.length() > 0)
                    {
                        SCONID.add(objNew[i].SVMXC__PM_SC__c);
                        setWOIDForPMsDelivered.add(objNew[i].id);
                        if(objNew[i].SVMXC__Component__c !=null)
                        {
                            setInstalledProdId.add(objNew[i].SVMXC__Component__c);
                        }
                    }
                }
                
                if(objNew[i].SVMXC__PM_Plan__c != null &&
                    ((string)objNew[i].SVMXC__PM_Plan__c).length() > 0 &&
                    objNew[i].SVMXC__Group_Member__c != null &&
                    ((string)objNew[i].SVMXC__Group_Member__c).length() > 0 &&
                    objNew[i].SVMXC__PM_Tasks_Created__c != null &&
                    !objNew[i].SVMXC__PM_Tasks_Created__c){
                        setWOID.add(objNew[i].Id);
                        //ServoceOrderToProcess.add(objNew[i]);
                }
            }
        }
    
        if(SCONID.size() > 0)
        {
            //get all the Service Contract Products and updating
            if(SCONID != null && SCONID.size() > 0)
            {
                String S_ID='';
                for( ID ids : SCONID)
                {   
                    if(S_ID.length() > 0)
                    S_ID += ', ';
                    S_ID += '\'' + String.valueOf(ids)+ '\'';
                }
                if(S_ID.length()>0)
                {
                    String SOQL = 'Select s.id, s.SVMXC__Number_Of_PMs_Delivered__c,s.SVMXC__Installed_Product__c From SVMXC__Service_Contract_Products__c s where s.SVMXC__Service_Contract__c in ('+S_ID+' ) '; 
                    System.debug(SOQL);
                    lstCoverdProd = Database.query(SOQL);
                    system.debug(lstCoverdProd);
                }
                if(setWOIDForPMsDelivered!=null && setWOIDForPMsDelivered.size()>0)
                {
                    String WO_ID='';
                    for( ID ids : setWOIDForPMsDelivered)
                    {   
                        if(WO_ID.length() > 0)
                            WO_ID += ', ';
                        WO_ID += '\'' + String.valueOf(ids)+ '\'';
                    }
                    if(WO_ID.length()>0)
                    {
                        System.debug('workorders ids'+WO_ID);
                        String SOQL = ' Select s.SVMXC__Service_Order__c, s.SVMXC__Serial_Number__c, s.Id From SVMXC__Service_Order_Line__c s where s.SVMXC__Service_Order__c in ('+WO_ID+' ) '; 
                        System.debug(SOQL);
                        lstWOLine = Database.query(SOQL);
                        System.debug('workorder lines' + lstWOLine);
                    }
                }
            }
            
            for(SVMXC__Service_Order_Line__c WOLine : lstWOLine)
            {
                if(WOLine.SVMXC__Serial_Number__c != NULL)
                    updateInstalledProdCount(mapIBCount, WOLine.SVMXC__Serial_Number__c);
            }
            
            for(ID InstalledProdId : setInstalledProdId)
                updateInstalledProdCount(mapIBCount, InstalledProdId);
            
            //Calculate Number of PM Delivered field and update list of Service Contract Covered Product.
            if(lstCoverdProd != NULL && lstCoverdProd.size() > 0)
            {
                for(SVMXC__Service_Contract_Products__c SCP : lstCoverdProd)
                {
                    if(SCP.SVMXC__Installed_Product__c != NULL && mapIBCount.containsKey(SCP.SVMXC__Installed_Product__c) && mapIBCount.get(SCP.SVMXC__Installed_Product__c) != NULL)
                    {
                        if(SCP.SVMXC__Number_Of_PMs_Delivered__c == NULL)
                            SCP.SVMXC__Number_Of_PMs_Delivered__c = mapIBCount.get(SCP.SVMXC__Installed_Product__c);
                        else
                            SCP.SVMXC__Number_Of_PMs_Delivered__c += mapIBCount.get(SCP.SVMXC__Installed_Product__c);
                    }
                }
                //update lstCoverdProd;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCoverdProd, COMM_SecurityUtils.Access.Updateable)){
                    update lstCoverdProd; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
        }   
        

        if(createTasks.toUpperCase()=='TRUE' && !setWOID.isEmpty())
        {
            //Task creation 
            List<Task> tasklist=new List<Task>();
            List<SVMXC__Task_Template__c> listTaskTemplate=new List<SVMXC__Task_Template__c> ();
            Map<ID ,list<SVMXC__Service_Order__c>> ttidwrecordMap=new  Map<ID ,list<SVMXC__Service_Order__c>>();  
            set<ID> taskTempset=new set<ID>();
            
            //Get the work orders for which the tasks has to be created       
            list<SVMXC__Service_Order__c> lstWO = [SELECT id, SVMXC__PM_Plan__c,
                                SVMXC__Scheduled_Date__c, SVMXC__Group_Member__c,
                                SVMXC__PM_Tasks_Created__c,
                                SVMXC__PM_Plan__r.SVMXC__Task_Template__c
                                FROM SVMXC__Service_Order__c
                                WHERE ID in :setWOID];
        
            if(lstWO != null && lstWO.size()>0)
            {
                for(SVMXC__Service_Order__c loopList :lstWO)
                {
                    System.debug(LoggingLevel.DEBUG , 'Task Created ' + loopList.SVMXC__PM_Tasks_Created__c);
                    if(loopList.SVMXC__PM_Plan__c != null &&
                        loopList.SVMXC__Group_Member__c != null &&
                        loopList.SVMXC__PM_Plan__r.SVMXC__Task_Template__c != null &&
                        loopList.SVMXC__PM_Tasks_Created__c == false)
                    {
                        taskTempset.add(loopList.SVMXC__PM_Plan__r.SVMXC__Task_Template__c);
                        if(!ttidwrecordMap.ContainsKey(loopList.SVMXC__PM_Plan__r.SVMXC__Task_Template__c))
                            ttidwrecordMap.put(loopList.SVMXC__PM_Plan__r.SVMXC__Task_Template__c,new list<SVMXC__Service_Order__c>());
                        ttidwrecordMap.get(loopList.SVMXC__PM_Plan__r.SVMXC__Task_Template__c).add(loopList);
                    }
                }
            }
            if(taskTempset.size()>0)
            {
                String S_ID='';
                if(taskTempset.size()>0)
                {
                    for( ID ids : taskTempset)
                    {   
                        if(S_ID.length() > 0)
                            S_ID += ',';
                        S_ID += '\'' + String.valueOf(ids)+ '\'';
                    }
                }
                if(S_ID.length()>0)
                {
                    String where_clause ='';
                    String SOQL = 'Select s.SVMXC__Template_Type__c, s.SVMXC__Task_Template__c, s.SVMXC__Template_Name__c, s.SVMXC__Task_Title__c, s.SVMXC__Priority__c, s.SVMXC__Description__c, s.Name, s.Id From SVMXC__Task_Template__c s ';
                    where_clause += '   where   SVMXC__Task_Template__c in ('+S_ID+')';
                    where_clause += '   AND  RecordType.Name = \'Tasks\' ';
                    where_clause += '   AND  s.SVMXC__Task_Title__c != null ';
                    SOQL +=where_clause;
        
                    listTaskTemplate =Database.query(SOQL); 
                }       
            }
            if(listTaskTemplate.size()>0)
            {
                for(SVMXC__Task_Template__c ttloop:listTaskTemplate)
                {
                    if(ttidwrecordMap.ContainsKey(ttloop.SVMXC__Task_Template__c))
                    {
                        for(SVMXC__Service_Order__c sorder :ttidwrecordMap.get(ttloop.SVMXC__Task_Template__c))
                        {
                            if(ttloop.SVMXC__Priority__c!=null)
                                tasklist.add(new Task(WhatId =sorder.id,Priority = ttloop.SVMXC__Priority__c,status ='Not Started',IsReminderSet = False,Description = ttloop.SVMXC__Description__c,ActivityDate = sorder.SVMXC__Scheduled_Date__c,Subject=ttloop.SVMXC__Task_Title__c ));
                            else
                                tasklist.add(new Task(WhatId =sorder.id,Priority = PriorityValue,status ='Not Started',IsReminderSet = False,Description = ttloop.SVMXC__Description__c,ActivityDate = sorder.SVMXC__Scheduled_Date__c ,Subject=ttloop.SVMXC__Task_Title__c));
                        }
                    }
                }
            }
            if(tasklist.size()>0){
                //insert tasklist;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(tasklist, COMM_SecurityUtils.Access.Createable)){
                    insert tasklist; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        
            List<SVMXC__Service_Order__c> seorderListtoupdate=new List<SVMXC__Service_Order__c>();
            for(List<SVMXC__Service_Order__c> lstsorder:ttidwrecordMap.values())
            {
                for(SVMXC__Service_Order__c sorder:lstsorder)
                {
                    sorder.SVMXC__PM_Tasks_Created__c = true;
                    seorderListtoupdate.add(sorder);
                }     
            }
            if(seorderListtoupdate.size()>0){
                //update seorderListtoupdate;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(seorderListtoupdate, COMM_SecurityUtils.Access.Updateable)){
                    update seorderListtoupdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
        }
            
        
        isPMExecutionDone =  true;
    }
    
    public Map<Id, Integer> updateInstalledProdCount(Map<Id, Integer> mapIBCount, Id InstalledProdId)
    {
        if(!mapIBCount.containsKey(InstalledProdId))
            mapIBCount.put(InstalledProdId, 1);
        else
            mapIBCount.put(InstalledProdId, Integer.valueOf(mapIBCount.get(InstalledProdId) + 1));
        return mapIBCount;
    }
}