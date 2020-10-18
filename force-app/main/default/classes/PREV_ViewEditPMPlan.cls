public with Sharing class PREV_ViewEditPMPlan 
{
       //Wrapper Class...
        public class PMWrapper
        {
                
                public SVMXC__PM_Coverage__c PMCoverage {get;set;}
                public SVMXC__Installed_Product__c oIP {get;set;}
                public string ProductName{get;set;}
                public string IPName{get;set;}
                public string IPID{get;set;}
                public string ID{get;set;}
                public String ProductFamily {get;set;}
                public String ProductLine {get;set;} 
                public boolean bselect;
                public boolean getselect(){return this.bselect;}
                public void  setselect(boolean b){this.bselect = b;}
                
               public PMWrapper(SVMXC__PM_Coverage__c PMC, SVMXC__Service_Contract_Products__c SCP)
               {
                    PMCoverage = PMC;
                    PMCoverage.SVMXC__Product_Name__c = SCP.SVMXC__Installed_Product__c;
                    ProductName = SCP.SVMXC__Installed_Product__r.SVMXC__Product__r.Name;
                    IPName = SCP.SVMXC__Installed_Product__r.Name;
                    IPID = SCP.SVMXC__Installed_Product__c;
               }
               public PMWrapper(SVMXC__PM_Coverage__c PMC)
               {
                    PMCoverage = PMC;
                    ProductName = PMCoverage.SVMXC__Product_Name__r.SVMXC__Product__r.Name;
                    IPName = PMC.SVMXC__Product_Name__r.Name;
                    IPID = PMC.SVMXC__Product_Name__c;
               }
        }
        
     // Global Variables Declaration.....
     public string SCID = System.currentPageReference().getParameters().get('scid');
     public string PEID = System.currentPageReference().getParameters().get('peid');
     public string PCID = System.currentPageReference().getParameters().get('pcid');
    
     SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 

     SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
     public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('PREV002');

     SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
     public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PREV002');
     public Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
          
     public boolean displayPopup = false; 
     public String SearchKeyword ='';
     public boolean FilterByPF = false;
     public boolean FilterByPL = false;
     public Boolean HdrMsg = true;   
     public Boolean PopupMsg = false;
     public Boolean CheckAll = false;
     public Boolean IsEnterpriseLicense = false;//Added by amar on 18th Aug 10 Due to OEM Exercises
     public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();//Added by amar on 18th Aug 10 Due to OEM Exercises
     public List<SVMXC__Service_Contract_Products__c> CoveredProduct = new List<SVMXC__Service_Contract_Products__c> ();
     public List<SVMXC__Service_Contract_Products__c> CoveredProductTable = new List<SVMXC__Service_Contract_Products__c> ();
     public SVMXC__PM_Plan__c PMObject = new SVMXC__PM_Plan__c();
     public List<SVMXC__PM_Plan__c> PMPlanLst = new List<SVMXC__PM_Plan__c>();
     public List<SVMXC__PM_Coverage__c> PMCoverageData = new List<SVMXC__PM_Coverage__c>();
     public List<SVMXC__PM_Coverage__c> DelPMCoverageData = new List<SVMXC__PM_Coverage__c>();
     public List<SVMXC__PM_Coverage__c> SavePMCoverageData = new List<SVMXC__PM_Coverage__c>();
     public List<SVMXC__Installed_Product__c> IBLst = new List<SVMXC__Installed_Product__c>();
     public List<SVMXC__Installed_Product__c> IB1Lst = new List<SVMXC__Installed_Product__c>();
     public List<SVMXC__Installed_Product__c> IB2Lst = new List<SVMXC__Installed_Product__c>();
     public SVMXC__Service_Contract__c SCObject = new SVMXC__Service_Contract__c();
     public List<SVMXC__ServiceMax_Processes__c> WOobjmap = new List<SVMXC__ServiceMax_Processes__c>();
     public List<SVMXC__ServiceMax_Processes__c> Caseobjmap = new List<SVMXC__ServiceMax_Processes__c>();
     public List<SVMXC__ServiceMax_Processes__c> DispatchProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
     public List<QueueSobject> CaseQue = new List<QueueSobject>();
     public List<QueueSobject> WOQue = new List<QueueSobject>();
     public List<SVMXC__Task_Template__c> TaskTmpltLst = new List<SVMXC__Task_Template__c>();
     public string selectedTab;
     public String CoveredProductId = '';
     public String IBId = '';
     public String IB2Id ='';
     public String IBFieldNames;
     public List<String> Fieldname = new List<String>();    
     public Map<String,String> MapofPickListDefValue = new Map<String,String>();  
     public List<String> CoveredProductIdLst = new List<String>();       
     //Getter & Setter....
     public SVMXC__PM_Plan__c getPMObject(){return PMObject;}
     public void setPMObject(SVMXC__PM_Plan__c PM) {PMObject = PM;}
     public SVMXC__Service_Contract__c getSCObject() {return SCObject;}
     public void setSCObject(SVMXC__Service_Contract__c SC) {SCObject = SC;}
     public Boolean getdisplayPopup(){return displayPopup;}
     public void setdisplayPopup(Boolean b){displayPopup = b;}
     public Boolean getFilterByPF(){return FilterByPF;}
     public void setFilterByPF(Boolean b){FilterByPF = b;}
     public Boolean getFilterByPL(){return FilterByPL;}
     public void setFilterByPL(Boolean b){FilterByPL = b;}
     public String getSearchKeyword(){return SearchKeyword;}
     public void setSearchKeyword(String s){SearchKeyword = s.trim();}
     public string getselectedTab() {return this.selectedTab;}
     public void setselectedTab(string str) {this.selectedTab = str;}
     public Boolean getCheckAll() {return CheckAll;  }
     public void setCheckAll(Boolean chkAll){CheckAll = chkAll;}       
     //Creating the Wraper class Instance.......
     public SVMXC__PM_Coverage__c PMC = new SVMXC__PM_Coverage__c();
     public SVMXC__Installed_Product__c IP = new SVMXC__Installed_Product__c();
     public boolean s = false;
     public List<PMWrapper> PMWrapperObjlst = new List<PMWrapper>();
     public List<PMWrapper> getPMWrapperObjlst(){return PMWrapperObjlst;}
     public void setPMWrapperObjlst(List<PMWrapper> PW){PMWrapperObjlst = PW;}
    
     //Creating the instance for Popup ........ 
     public SVMXC__Installed_Product__c SPC = new SVMXC__Installed_Product__c();
     //public PMWrapper PopupWrapperObj = new PMWrapper(SPC);
     public List<PMWrapper> PopupWrapperObjLst = new List<PMWrapper>();
     public List<PMWrapper> getPopupWrapperObjLst() {return PopupWrapperObjLst;}
     public void setPopupWrapperObjLst(List<PMWrapper> popup) {PopupWrapperObjLst = popup;}
        
        //Constructor
        
        public PREV_ViewEditPMPlan()
        {              
            try
            {
                //Neeraj(20-02-2012): Get the email address from settings.
                if(svmxSettingList.containsKey('SET003') && svmxSettingList.get('SET003') != null && svmxSettingList.get('SET003').length() > 0)
                    PMObject.SVMXC__Success_Email_ID__c = svmxSettingList.get('SET003');

                if(svmxSettingList.containsKey('SET004') && svmxSettingList.get('SET004') != null && svmxSettingList.get('SET004').length() > 0)
                    PMObject.SVMXC__Error_Email_ID__c = svmxSettingList.get('SET004');
                
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                //Added by amar on 18th Aug 10 Due to OEM Exercises
                IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
                if(IsEnterpriseLicense == false)
                {
                     PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
                }
                system.debug('PermitedStndObjMap'+PermitedStndObjMap);        
                //Get the IB Fields Names .........
                Schema.DescribeSObjectResult dsoResultIB = SVMXC__Installed_Product__c.sObjectType.getDescribe();
                Map<String, SObjectField> IBfieldMap = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
                    
                IBFieldNames = utils.SVMX_getFieldNamesFromList(utils.SVMX_getFieldList(IBfieldMap,true));
                
                
                //Get the List of Task Templeat 
                TaskTmpltLst = Database.query('Select Id, s.SVMXC__Template_Name__c  From SVMXC__Task_Template__c s where RecordType.Name = \'Templates\' and SVMXC__Template_Type__c =\'Preventive Maintenance\'and SVMXC__Template_Name__c != null');
                //Get the object Mapping for Work Order & Case
                WOobjmap =[select SVMXC__MapID__c,SVMXC__Source_Object_Name__c,SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c in ('SVMXC__Installed_Product__C','SVMXC__Service_Contract__C') and SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c' and SVMXC__Active__c = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                Caseobjmap = [select SVMXC__MapID__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c in('SVMXC__Service_Contract__C','SVMXC__Service_Order__c') and SVMXC__Target_Object_Name__c = 'Case' and SVMXC__Active__c = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                //Get the Queue for Work Order & Case
                WOQue   = Database.query('Select  QueueId, Queue.Name From QueueSobject where SobjectType = \'SVMXC__Service_Order__C\'');
                CaseQue = Database.query('Select QueueId, Queue.Name From QueueSobject where SobjectType = \'Case\'');
                    
                //Get the Dispatch Processes....
                DispatchProcessLst = Database.Query('Select id,SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = \'Dispatch Process\'');
                
                if(SVMX_IsValidID(SCID))
                {
                    PMCoverageData.clear();
                    PMWrapperObjlst.clear();
                    Fieldname.add('SVMXC__Schedule_Type__c');
                    Fieldname.add('SVMXC__Status__c');
                    Fieldname.add('SVMXC__Time_and_Counters__c');
                    Fieldname.add('SVMXC__End_Date__c');
                    Fieldname.add('SVMXC__Number_of_Work_orders__c');
                    Fieldname.add('SVMXC__Number_of_Cases__c');
                    Fieldname.add('SVMXC__Frequency_Unit__c');
                    MapofPickListDefValue = utils.SVMX_getDefaultPicklistValue('SVMXC__PM_Plan__c',FieldName);
                  
                    //First Query the service Contract..... 
                    
                    SCObject = database.query('Select s.SVMXC__Start_Date__c,s.SVMXC__End_Date__c, s.SVMXC__Service_Level__c, s.Name From SVMXC__Service_Contract__c s where Id = \''+SCID+'\'');
                    PMObject.SVMXC__Start_Date__c = SCObject.SVMXC__Start_Date__c;
                    PMObject.SVMXC__End_Date__c = SCObject.SVMXC__End_Date__c;
                    PMObject.SVMXC__SLA_Terms__c = SCObject.SVMXC__Service_Level__c;
                    PMObject.SVMXC__Status__c =  MapofPickListDefValue.get('SVMXC__Status__c');
                    PMObject.SVMXC__Schedule_Type__c = MapofPickListDefValue.get('SVMXC__Schedule_Type__c');
                    PMObject.SVMXC__Time_and_Counters__c = MapofPickListDefValue.get('SVMXC__Time_and_Counters__c');
                    PMObject.SVMXC__Number_of_Work_orders__c = MapofPickListDefValue.get('SVMXC__Number_of_Work_orders__c');
                    PMObject.SVMXC__Number_of_Cases__c = MapofPickListDefValue.get('SVMXC__Number_of_Cases__c');
                    PMObject.SVMXC__Frequency_Unit__c = MapofPickListDefValue.get('SVMXC__Frequency_Unit__c');
                    
                    // Get the PM plan Related to the service Contract....
                    PMPlanLst = database.query('Select s.Name From SVMXC__PM_Plan__c s where SVMXC__Service_Contract__c = \''+SCID+'\'');

                    //Second Query the Service Controct Product (PM Coverage Tab Logic)...
                    CoveredProduct = Database.query('Select s.SVMXC__Installed_Product__r.SVMXC__Product__r.name, SVMXC__Installed_Product__r.Name, s.SVMXC__Installed_Product__c, s.Id  From SVMXC__Service_Contract_Products__c s where SVMXC__Service_Contract__c = \''+SCID+'\'');
                    system.debug('amar'+CoveredProduct.size());
                    if(CoveredProduct.size() == 1000)
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG059()));
                    if(CoveredProduct.size() != null)
                    {
                        for(SVMXC__Service_Contract_Products__c CP : CoveredProduct)
                        {
                            //get the covered product Id to search
                            if(CoveredProductId.length() > 0)
                                CoveredProductId += ',';
                            CoveredProductIdLst.add(String.escapeSingleQuotes(String.valueOf(CP.id))); 
                            if(CP.SVMXC__Installed_Product__c != null)
                            {
                                PMWrapperObjlst.add(new PMWrapper(new SVMXC__PM_Coverage__c(),CP));  
                            }
                        }       
                     }
                     system.debug('PMWrapperObjlst'+PMWrapperObjlst+PMWrapperObjlst.size());   
                 }
                 //Edit Mode
                 if(SVMX_IsValidID(PEID) && SVMX_IsValidID(SCID))
                 {
                    PMCoverageData.clear();
                    PMWrapperObjlst.clear();
                    //First Query the PM Plan Object...
                    PMObject = database.query('Select s.SVMXC__Work_Order_Date__c, s.SVMXC__Work_Order_Assign_To__c, s.SVMXC__Work_Order_Assign_To_User__c, s.SVMXC__Work_Order_Assign_To_Queue__c, s.SVMXC__Time_and_Counters__c, s.SVMXC__Task_Template__c, s.SVMXC__Success_Email_ID__c,s.SVMXC__Status__c, s.SVMXC__Start_Date__c, s.SVMXC__Schedule_Type__c, s.SVMXC__Service_Contract__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Processed__c, s.SVMXC__Number_of_Work_orders__c, s.SVMXC__Number_of_Cases__c, s.SVMXC__Next_PM_Date__c, s.SVMXC__Last_PM_Date__c, s.SVMXC__Frequency__c, s.SVMXC__Frequency_Unit__c, s.SVMXC__Field_map_for_wo__c, s.SVMXC__Field_map_for_Case__c, s.SVMXC__Error_Email_ID__c,s.SVMXC__End_Date__c, s.SVMXC__Description__c, s.SVMXC__Create_Work_Order__c, s.SVMXC__Create_Case__c, s.SVMXC__Case_Assign_To__c, s.SVMXC__Case_Assign_To_User__c, s.SVMXC__Case_Assign_To_Queue__c, s.SVMXC__Activity_On_Success__c, s.SVMXC__Activity_On_Error__c, s.Name, s.Id From SVMXC__PM_Plan__c s where id = \''+PEID+'\'');
                    if(PMObject.SVMXC__Next_PM_Date__c != null && PMObject.SVMXC__Create_Work_Order__c != null)
                    {
                        double d = PMObject.SVMXC__Create_Work_Order__c;
                        Integer i = d.intvalue();
                            PMObject.SVMXC__Work_Order_Date__c = PMObject.SVMXC__Next_PM_Date__c.adddays(i);
                    }
                    //Second Query the PM Coverage Object 
                    PMCoverageData = database.query('Select SVMXC__Product_Name__r.SVMXC__Product__r.Name,SVMXC__Product_Name__r.Name, s.SVMXC__Product_Name__c, s.SVMXC__PM_Plan__c, s.SVMXC__PM_Limit__c, s.Name From SVMXC__PM_Coverage__c s where SVMXC__PM_Plan__c = \''+PEID+'\'');
                    
                    if(PMCoverageData.size() == 1000)
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG060())); 
                    if(PMCoverageData.size() != null)
                    {
                        for(SVMXC__PM_Coverage__c PMC : PMCoverageData)
                        {
                            /*if(IBId.length() > 0)
                                IBId += ',';
                            IBId  += '\'' + String.valueOf(PMC.SVMXC__Product_Name__c)+ '\'';*/
                            PMWrapperObjlst.add(new PMWrapper(PMC));
                        }
                    }           
                    
                    /*IBLst.clear();
                    if(IBId.length() > 0)
                        IBLst = database.Query('Select SVMXC__Product__r.name, '+ IBFieldNames +' From SVMXC__Installed_Product__c s where id in (' + IBId + ')');
                    
                    if(PMCoverageData.size() != null && IBLst.size() != null)
                    {
                        for(Integer i = 0; i< PMCoverageData.size();i++)
                        {    
                            for(Integer j = 0;j < IBLst.size(); j++)
                            {
                                if(PMCoverageData[i].SVMXC__Product_Name__c == IBLst[j].id)
                                {
                                    PMWrapperObjlst.add(new PMWrapper (PMCoverageData[i], IBLst[j] ));
                                                    
                                }       
                            }       
                         }               
                     }*/
                     
                }
                if(SVMX_IsValidID(PCID)&& SVMX_IsValidID(SCID))
                {
                    PMCoverageData.clear();
                    PMWrapperObjlst.clear();
                    //First Create PM Plan Object 
                    SVMXC__PM_Plan__c PMObject2 = database.query('Select s.SVMXC__Work_Order_Date__c, s.SVMXC__Work_Order_Assign_To__c, s.SVMXC__Work_Order_Assign_To_User__c, s.SVMXC__Work_Order_Assign_To_Queue__c, s.SVMXC__Time_and_Counters__c, s.SVMXC__Task_Template__c, s.SVMXC__Success_Email_ID__c,s.SVMXC__Status__c, s.SVMXC__Start_Date__c, s.SVMXC__Schedule_Type__c, s.SVMXC__Service_Contract__c, s.SVMXC__SLA_Terms__c, s.SVMXC__Processed__c, s.SVMXC__Number_of_Work_orders__c, s.SVMXC__Number_of_Cases__c, s.SVMXC__Next_PM_Date__c, s.SVMXC__Last_PM_Date__c, s.SVMXC__Frequency__c, s.SVMXC__Frequency_Unit__c, s.SVMXC__Field_map_for_wo__c, s.SVMXC__Field_map_for_Case__c, s.SVMXC__Error_Email_ID__c,s.SVMXC__End_Date__c, s.SVMXC__Description__c, s.SVMXC__Create_Work_Order__c, s.SVMXC__Create_Case__c, s.SVMXC__Case_Assign_To__c, s.SVMXC__Case_Assign_To_User__c, s.SVMXC__Case_Assign_To_Queue__c, s.SVMXC__Activity_On_Success__c, s.SVMXC__Activity_On_Error__c, s.Name, s.Id From SVMXC__PM_Plan__c s where id = \''+PCID+'\'');
                    PMObject = PMObject2.clone(false,true);
                    PMObject.name = '';
                    PMObject.SVMXC__Processed__c = false;
                    if(PMObject.SVMXC__Next_PM_Date__c != null && PMObject.SVMXC__Create_Work_Order__c != null)
                    {      
                        double d = PMObject.SVMXC__Create_Work_Order__c;
                        Integer i = d.intvalue();
                        PMObject.SVMXC__Work_Order_Date__c = PMObject.SVMXC__Next_PM_Date__c.adddays(i);
                    }
                    
                    List<SVMXC__PM_Coverage__c> PMCoverageData2 = database.query('Select SVMXC__Product_Name__r.SVMXC__Product__r.Name,SVMXC__Product_Name__r.Name, s.SVMXC__Product_Name__c, s.SVMXC__PM_Plan__c, s.SVMXC__PM_Limit__c, s.Name From SVMXC__PM_Coverage__c s where SVMXC__PM_Plan__c = \''+PCID+'\'');
                    if(PMCoverageData2.size() == 1000)
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG060()));
                    /*if(PMCoverageData2.size() != null)
                    {
                        for( SVMXC__PM_Coverage__c PMC : PMCoverageData2)
                        {
                            if(IB2Id.length() > 0)
                                IB2Id += ',';
                            IB2Id  += '\'' + String.valueOf(PMC.SVMXC__Product_Name__c)+ '\'';
                         }       
                     }
                     IBLst.clear();
                     
                     if(IB2Id.length() > 0)
                        IBLst = database.Query('Select SVMXC__Product__r.name, '+ IBFieldNames +' From SVMXC__Installed_Product__c s where id in (' + IB2Id + ')');*/
                     
                     if(PMCoverageData2.size()!= null)
                     {
                        for(Integer i = 0;i< PMCoverageData2.size();i++)
                        {
                            PMCoverageData.add(PMCoverageData2[i].clone(false,true));       
                        }
                        
                     }
                     if(PMCoverageData.size() > 0)
                     {
                        for(SVMXC__PM_Coverage__c PMC : PMCoverageData)
                        {
                            PMWrapperObjlst.add(new PMWrapper(PMC));
                        }
                     }
                     /*if(PMCoverageData.size() != null && IBLst.size() != null)
                     {
                        for(Integer i = 0; i< PMCoverageData.size();i++)
                        {
                            for(Integer j = 0;j < IBLst.size(); j++)
                            {
                                if(PMCoverageData[i].SVMXC__Product_Name__c == IBLst[j].id)
                                {
                                    PMWrapperObjlst.add(new PMWrapper (PMCoverageData[i], IBLst[j] ));
                                }       
                            }       
                         }               
                      }*/
                      
                   }
            }
            catch(Exception ex)
            {
                HdrMsg =true;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
            }            
       }
       public boolean SVMX_IsValidID(String id)
       {
        if (id <> null && id <> '' && id.length() > 0)
            return true;
        else
            return false;
        }
        public Boolean LicenseType = false;
        public Boolean getLicenseType()
        {
            if(IsEnterpriseLicense == false)
            {
                if(PermitedStndObjMap.containskey('Case') && PermitedStndObjMap.get('Case') == true)
                {
                    LicenseType = true;
                }
            }
            else
            {
                LicenseType = true;
            }
            system.debug('LicenseType'+LicenseType);
            return LicenseType;
            
        }
        
        //Select Options..
        public List<SelectOption> WOQueue = new List<SelectOption>();
        public List<SelectOption> getWOQueue()
        {
                WOQueue.clear();
                WOQueue.add(new selectOption('', getTAG046()));
                for(Integer i = 0; i<WOQue.size(); i++)
                {
                        WOQueue.add(new selectOption(WOQue[i].QueueId,WOQue[i].Queue.Name));
                }
                
                return WOQueue;
        }
        public List<SelectOption> CaseQueue = new List<SelectOption>();
        public List<SelectOption> getCaseQueue()
        {
                CaseQueue.clear();
                CaseQueue.add(new selectOption('', getTAG046()));
                for(Integer i = 0; i<CaseQue.size(); i++)
                {
                        CaseQueue.add(new selectOption(CaseQue[i].QueueId,CaseQue[i].Queue.Name));
                }
                
                return CaseQueue;
        }
        public List<SelectOption> DispatchProcess = new List<SelectOption>();
        public List<SelectOption> getDispatchProcess()
        {
                DispatchProcess.clear();
                DispatchProcess.add(new selectOption('',getTAG046()));
                for(SVMXC__ServiceMax_Processes__c DP : DispatchProcessLst)
                {
                        DispatchProcess.add(new selectOption(DP.id,DP.SVMXC__Name__c));
                }
                return DispatchProcess;
        }
        public List<SelectOption> fldmapforWO = new List<SelectOption>();
        public List<SelectOption> getfldmapforWO()
        {
                fldmapforWO.clear();
                if(PMObject.SVMXC__Number_of_Work_orders__c == null || PMObject.SVMXC__Number_of_Work_orders__c == '')
                {
                     fldmapforWO.clear();
                     fldmapforWO.add(new selectOption('', getTAG046()));
                }
                if(PMObject.SVMXC__Number_of_Work_orders__c == 'One Per Plan')
                {
                        fldmapforWO.clear();
                        fldmapforWO.add(new selectOption('', getTAG046()));
                        for(integer i = 0;i<WOobjmap.size();i++)
                        {
                                if(WOobjmap[i].SVMXC__Source_Object_Name__c != 'SVMXC__Installed_Product__C')
                                        fldmapforWO.add(new selectOption(WOobjmap[i].SVMXC__MapID__c,WOobjmap[i].SVMXC__Name__c));
                        }
                }
                if(PMObject.SVMXC__Number_of_Work_orders__c == 'One Per Product')
                {
                        fldmapforWO.clear();
                        fldmapforWO.add(new selectOption('', getTAG046()));
                        for(integer i = 0;i<WOobjmap.size();i++)
                        {
                                fldmapforWO.add(new selectOption(WOobjmap[i].SVMXC__MapID__c,WOobjmap[i].SVMXC__Name__c));
                        }
                }       
                return fldmapforWO;
        }
        public List<SelectOption> fldmapforCase = new List<SelectOption>();
        public List<SelectOption> getfldmapforCase()
        {
                fldmapforCase.clear();  
                if(PMObject.SVMXC__Number_of_Cases__c == null || PMObject.SVMXC__Number_of_Cases__c == '')
                {
                    fldmapforCase.clear();  
                    fldmapforCase.add(new selectOption('', getTAG046()));
                }
                if(PMObject.SVMXC__Number_of_Cases__c == 'One Per Plan')  
                {             
                    fldmapforCase.clear();  
                    fldmapforCase.add(new selectOption('', getTAG046()));
                    for(integer i = 0;i<Caseobjmap.size();i++)
                    {
                        if(Caseobjmap[i].SVMXC__Source_Object_Name__c == 'SVMXC__Service_Contract__c')
                            fldmapforCase.add(new selectOption(Caseobjmap[i].SVMXC__MapID__c,Caseobjmap[i].SVMXC__Name__c));    
                    }
                    return fldmapforCase;
                }
                if(PMObject.SVMXC__Number_of_Cases__c == 'One Per Work Order')  
                {
                    fldmapforCase.clear();  
                    fldmapforCase.add(new selectOption('', getTAG046()));
                    for(integer i = 0;i<Caseobjmap.size();i++)
                    {
                        if(Caseobjmap[i].SVMXC__Source_Object_Name__c == 'SVMXC__Service_Order__c')
                            fldmapforCase.add(new selectOption(Caseobjmap[i].SVMXC__MapID__c,Caseobjmap[i].SVMXC__Name__c));
                    }
                    return fldmapforCase;
                }   
                return fldmapforCase;
        }       
        public List<SelectOption> TaskTmplt = new List<SelectOption>();   
        public List<SelectOption> getTaskTmplt()
        {
                TaskTmplt.clear();  
                TaskTmplt.add(new selectOption('', getTAG046()));
                for(integer i = 0;i<TaskTmpltLst.size();i++)
                {
                        
                        TaskTmplt.add(new selectOption(TaskTmpltLst[i].id,TaskTmpltLst[i].SVMXC__Template_Name__c));
                }
                return TaskTmplt;
        }      
        //Getting the Tags......
    public String getHLPURL() {return system.label.PREV002_HLPURL;} 
    public String getTAG001() {return system.label.PREV002_TAG001;} //Processing...
    public String getTAG002() {return system.label.PREV002_TAG002;} //PM Plan For Service Contract
    public String getTAG003() {return system.label.PREV002_TAG003;} //Help
    public String getTAG004() {return system.label.PREV002_TAG004;} //PM Plan
    public String getTAG005() {return system.label.PREV002_TAG005;} //Work Order Settings
    public String getTAG006() {return system.label.PREV002_TAG006;} //Alerts And Logging
    public String getTAG007() {return system.label.PREV002_TAG007;} //Product Coverage
    public String getTAG008() {return system.label.PREV002_TAG008;} //PM Plan Name
    public String getTAG009() {return system.label.PREV002_TAG009;}//Description
    public String getTAG010() {return system.label.PREV002_TAG010;}//Status
    public String getTAG011() {return system.label.PREV002_TAG011;}//Start Date
    public String getTAG012() {return system.label.PREV002_TAG012;}//End Date
    public String getTAG013() {return system.label.PREV002_TAG013;}//Schedule Type
    public String getTAG014() {return system.label.PREV002_TAG014;}//Last PM Date
    public String getTAG015() {return system.label.PREV002_TAG015;}//Frequency
    public String getTAG016() {return system.label.PREV002_TAG016;}//Next PM Date
    public String getTAG017() {return system.label.PREV002_TAG017;}//Time & Counters
    public String getTAG018() {return system.label.PREV002_TAG018;}//SLA Terms
    public String getTAG019() {return system.label.PREV002_TAG019;}//Cancel
    public String getTAG020() {return system.label.PREV002_TAG020;}//Work Order Settings >>
    public String getTAG021() {return system.label.PREV002_TAG021;}//Frequency Unit
    public String getTAG022() {return system.label.PREV002_TAG022;}//Create Work Order
    public String getTAG023() {return system.label.PREV002_TAG023;}//days before scheduled date
    public String getTAG024() {return system.label.PREV002_TAG024;}//Field Mapping for Creating Work Order
    public String getTAG025() {return system.label.PREV002_TAG025;}//No of Work Orders
    public String getTAG026() {return system.label.PREV002_TAG026;}//Send to Dispatch Process
    public String getTAG027() {return system.label.PREV002_TAG027;}//Field Mapping for Creating Case
    public String getTAG028() {return system.label.PREV002_TAG028;}//Create Case
    public String getTAG029() {return system.label.PREV002_TAG029;}//Task Template
    public String getTAG030() {return system.label.PREV002_TAG030;}//Number of Cases
    public String getTAG031() {return system.label.PREV002_TAG031;}//Create Parts Requests
    public String getTAG032() {return system.label.PREV002_TAG032;}//<< PM Plan
    public String getTAG033() {return system.label.PREV002_TAG033;}//Alerts And Logging >>
    public String getTAG034() {return system.label.PREV002_TAG034;}//Email ID to receive success notifications
    public String getTAG035() {return system.label.PREV002_TAG035;}//Email ID to receive error notifications
    public String getTAG036() {return system.label.PREV002_TAG036;}//Create an activity in PM Plan upon successful execution
    public String getTAG037() {return system.label.PREV002_TAG037;}//Create an activity in PM Plan if errors occur in execution
    public String getTAG038() {return system.label.PREV002_TAG038;}//<< Work Order Settings
    public String getTAG039() {return system.label.PREV002_TAG039;}//Product Coverage >>
    public String getTAG040() {return system.label.PREV002_TAG040;}//Work Order Assign To
    public String getTAG041() {return system.label.PREV002_TAG041;}//Work Order Assign To User
    public String getTAG042() {return system.label.PREV002_TAG042;}//Work Order Assign To Queue
    public String getTAG043() {return system.label.PREV002_TAG043;}///Case Assign To
    public String getTAG044() {return system.label.PREV002_TAG044;}//Case Assign To User
    public String getTAG045() {return system.label.PREV002_TAG045;}//Case Assign To Queue
    public String getTAG046() {return system.label.PREV002_TAG046;}//--None--
    public String getTAG047() {return system.label.PREV002_TAG047;}//Recalculate
    public String getTAG048() {return system.label.PREV002_TAG048;}//Select
    public String getTAG049() {return system.label.PREV002_TAG049;}//Product Name
    public String getTAG050() {return system.label.PREV002_TAG050;}//Installed Product
    public String getTAG051() {return system.label.PREV002_TAG051;}//<< Alerts And Logging
    public String getTAG052() {return system.label.PREV002_TAG052;}//Find Covered Products
    public String getTAG053() {return system.label.PREV002_TAG053;}//Delete
    public String getTAG054() {return system.label.PREV002_TAG054;}//Save And Close
    public String getTAG055() {return system.label.PREV002_TAG055;}//PM Frequency
    public String getTAG056() {return system.label.PREV002_TAG056;}//PM Limit
    public String getTAG057() {return system.label.PREV002_TAG057;}//Next PM Cycle
    public String getTAG058() {return system.label.PREV002_TAG058;}//Next PM date is beyond the End Date of the PM Plan.
    public String getTAG059() {return system.label.PREV002_TAG059;}//More than 1000 products are covered by this service contract. Only 1000 records are allowed in a PM plan.
    public String getTAG060() {return system.label.PREV002_TAG060;}//Too many records found. Only 1000 records are allowed in a PM Plan.
    public String getTAG061() {return system.label.PREV002_TAG061;}//Add Selected
    public String getTAG062() {return system.label.PREV002_TAG062;}//Enter keyword to search products covered in this service contract
    public String getTAG063() {return system.label.PREV002_TAG063;}//Go!
    public String getTAG064() {return system.label.PREV002_TAG064;}//Filter By Product Family
    public String getTAG065() {return system.label.PREV002_TAG065;}//Filter By Product Line
    public String getTAG066() {return system.label.PREV002_TAG066;}//Keyword must be at least 2 characters long
    public String getTAG067() {return system.label.PREV002_TAG067;}//Product Family
    public String getTAG068() {return system.label.PREV002_TAG068;}//Product Line
    public String getTAG069() {return system.label.PREV002_TAG069;}//Select the product to add
    public String getTAG070() {return system.label.PREV002_TAG070;}//No Record Found
    public String getTAG071() {return system.label.PREV002_TAG071;}//Please enter a valid PM Plan name
    public String getTAG072() {return system.label.PREV002_TAG072;}//Duplicate PM Plan Name
    public String getTAG073() {return system.label.PREV002_TAG073;}//Please enter a valid Start Date
    public String getTAG074() {return system.label.PREV002_TAG074;}//Please enter a valid End Date
    public String getTAG075() {return system.label.PREV002_TAG075;}//Start Date must be less than End date
    public String getTAG076() {return system.label.PREV002_TAG076;}///End date must be a future date
    public String getTAG077() {return system.label.PREV002_TAG077;}//Next PM date must be a future date
    public String getTAG078() {return system.label.PREV002_TAG078;}//Number of days before Work Order should be created should not more then 3 digit
    public String getTAG079() {return system.label.PREV002_TAG079;}//Please enter a valid frequency
    public String getTAG080() {return system.label.PREV002_TAG080;}//select a valid rule for Time & Counters
    public String getTAG081() {return system.label.PREV002_TAG081;}///You must have to select Frequency Unit
    public String getTAG082() {return system.label.PREV002_TAG082;}//Please enter a valid number of days to create work order
    public String getTAG083() {return system.label.PREV002_TAG083;}//Please choose a valid map
    public String getTAG084() {return system.label.PREV002_TAG084;}//Please choose a valid Assign To
    public String getTAG085() {return system.label.PREV002_TAG085;}//Please select a valid dispatch process
    public String getTAG086() {return system.label.PREV002_TAG086;}//You must either enter an email ID to receive success notifications or choose to create an activity automatically
    public String getTAG087() {return system.label.PREV002_TAG087;}//No Record to Display
    public String getTAG088() {return system.label.PREV002_TAG088;}//You must include at least one product in each PM plan
    public String getTAG089() {return system.label.PREV002_TAG089;}//Please enter a valid PM Frequency
    public String getTAG090() {return system.label.PREV002_TAG090;}//Email ID to receive error notifications should not be blank
    public String getTAG091() {return system.label.PREV002_TAG091;}//Record(s) saved
    public String getTAG092() {return system.label.PREV002_TAG092;}//Record(s) Deleted
    public String getTAG093() {return system.label.PREV002_TAG093;}//No Such Record is present in covered Product or record is already Exsist in the Product Coverage Tab
    public String getTAG094() {return system.label.PREV002_TAG094;}//Please select a valid Number of Case
    public String getTAG095() {return system.label.PREV002_TAG095;}//Please select a valid Number of WorkOrder
    public String getTAG096() {return system.label.PREV002_TAG096;}//Please Select atleast one Checkbox to perform action
    public String getTAG097() {return system.label.PREV002_TAG097;}//Please select a valid Queue
    public String getTAG098() {return system.label.PREV002_TAG098;}//Number of days before Work Order should be created should not be Zero
    public String getTAG099() {return system.label.PREV002_TAG099;}//Please select a valid User
    public String getTAG100() {return system.label.PREV002_TAG100;}//Name should not be greater then 80 character
    public String getTAG101() {return system.label.PREV002_TAG101;}//Next PM Date should not be less than Start Date
    
    
    
    
    
   
   //Validation Check.....
        
   public Boolean SVMX_ISValidPM()
   {
         try
         {
             Boolean ISValid = true;
             String str;
             if(PMObject.Name == null || PMObject.Name == '')
             {
                    ISValid = false;
                    PMObject.Name.addError(getTAG071());
                    return ISValid;
             }
             if(PMObject.Name.length() > 80)
             {
                 ISValid = false;
                 PMObject.Name.addError(getTAG100());
             } 
             //Validation for PM Plan Tab...
             if((SVMX_IsValidID(PCID)&& SVMX_IsValidID(SCID)) || (SVMX_IsValidID(SCID) && !SVMX_IsValidID(PEID)))
             {
                if(PMObject.Name != null)
                {
                    for(SVMXC__PM_Plan__c pm : PMPlanLst)
                    {
                        String s = pm.Name.trim();
                        String s1 = PMObject.Name.trim();
                        if(s.toUpperCase() == s1.toUpperCase())
                        {
                            ISValid = false;
                            PMObject.Name.addError(getTAG072());
                        }
                    }          
                }
             }  
             
             if(PMObject.SVMXC__Start_Date__c == null)  
             {
                    ISValid = false;
                    PMObject.SVMXC__Start_Date__c.addError(getTAG073());
             }
             if(PMObject.SVMXC__End_Date__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__End_Date__c.addError(getTAG074());
             }
             if(PMObject.SVMXC__Start_Date__c > PMObject.SVMXC__End_Date__c)
             {
                    ISValid = false;
                    PMObject.SVMXC__Start_Date__c.addError(getTAG075());
             }
             if(PMObject.SVMXC__Next_PM_Date__c < PMObject.SVMXC__Start_Date__c)
             {
                ISValid = false;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG101()));
             }
             if(!SVMX_IsValidID(PEID))  
             {       
                if(PMObject.SVMXC__End_Date__c < system.today())
                {
                    ISValid = false;
                    PMObject.SVMXC__End_Date__c.addError(getTAG076());
                }
                if(PMObject.SVMXC__Next_PM_Date__c < system.today())
                {
                    ISValid = false;
                    PMObject.SVMXC__Next_PM_Date__c.addError(getTAG077());
                }
                if(PMObject.SVMXC__Next_PM_Date__c > PMObject.SVMXC__End_Date__c)
                {
                    ISValid = false;
                    PMObject.SVMXC__Next_PM_Date__c.addError(getTAG058());
                }
             }  
             if(PMObject.SVMXC__Schedule_Type__c == 'Time Based' || PMObject.SVMXC__Schedule_Type__c == 'Time & Counters')
             {
                    if(PMObject.SVMXC__Frequency_Unit__c == null)
                    {
                            ISValid = false;
                            PMObject.SVMXC__Frequency_Unit__c.addError(getTAG081());
                    }
                     if(PMObject.SVMXC__Frequency__c == null )
                    {
                            ISValid = false;
                            PMObject.SVMXC__Frequency__c.addError(getTAG079());
                            
                    } 
             } 
             if(PMObject.SVMXC__Schedule_Type__c == 'Time & Counters' && PMObject.SVMXC__Time_and_Counters__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Time_and_Counters__c.addError(getTAG080());
             }
             
             //Validation for WOSetting Tab...
             if(PMObject.SVMXC__Create_Work_Order__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Create_Work_Order__c.addError(getTAG082());
             }
             if(PMObject.SVMXC__Create_Work_Order__c == 0)
             {
                    ISValid = false;
                    PMObject.SVMXC__Create_Work_Order__c.addError(getTAG098());
             }
             if(PMObject.SVMXC__Create_Work_Order__c != null)
                str = PMObject.SVMXC__Create_Work_Order__c.format();
             
             if(str != null && str.length() > 3)
             {
                    ISValid = false;
                    PMObject.SVMXC__Create_Work_Order__c.addError(getTAG078());
             }
             if(PMObject.SVMXC__Number_of_Work_orders__c == null)
             {
                ISValid = false;
                PMObject.SVMXC__Number_of_Work_orders__c.addError(getTAG095());
             }
             if(PMObject.SVMXC__Field_map_for_wo__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Field_map_for_wo__c.addError(getTAG083());
             }
             if(PMObject.SVMXC__Work_Order_Assign_To__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Work_Order_Assign_To__c.addError(getTAG084());
             }
             
             /*if(PMObject.SVMXC__Work_Order_Assign_To__c == 'Dispatch Process' && PMObject.SVMXC__Dispatch_Process__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Dispatch_Process__c.addError(getTAG085());
             }*///(commented by amar on 18/03/10 at 5:00 PM)
             if(PMObject.SVMXC__Work_Order_Assign_To__c == 'User' && PMObject.SVMXC__Work_Order_Assign_To_User__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Work_Order_Assign_To_User__c.addError(getTAG099());
             }
             if(PMObject.SVMXC__Work_Order_Assign_To__c == 'Queue' && PMObject.SVMXC__Work_Order_Assign_To_Queue__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Work_Order_Assign_To_Queue__c.addError(getTAG097());
             }
              if(PMObject.SVMXC__Create_Case__c == true && PMObject.SVMXC__Field_map_for_Case__c == null)
             {
                    ISValid = false;
                    PMObject.SVMXC__Field_map_for_Case__c.addError(getTAG083());
             }
             if(PMObject.SVMXC__Create_Case__c == true && PMObject.SVMXC__Case_Assign_To__c == null)
             {
                ISValid = false;
                PMObject.SVMXC__Case_Assign_To__c.addError(getTAG084());
             }
             if(PMObject.SVMXC__Case_Assign_To__c == 'User' && PMObject.SVMXC__Case_Assign_To_User__c == null)
             {
                ISValid = false;
                PMObject.SVMXC__Case_Assign_To_User__c.addError(getTAG099());
             }
             if(PMObject.SVMXC__Case_Assign_To__c == 'Queue' && PMObject.SVMXC__Case_Assign_To_Queue__c == null)
             {
                ISValid = false;
                PMObject.SVMXC__Case_Assign_To_Queue__c.addError(getTAG097());
             }
             if(PMObject.SVMXC__Create_Case__c == true && PMObject.SVMXC__Number_of_Cases__c == null)
             {
                ISValid = false;
                PMObject.SVMXC__Number_of_Cases__c.addError(getTAG094());
             }
            //Validation for Alerts & Logging.......
            if(PMObject.Success_Email_ID__c == null && PMObject.SVMXC__Activity_On_Success__c == false)
            {
                ISValid = false;
                PMObject.Success_Email_ID__c.addError(getTAG086());
                PMObject.SVMXC__Activity_On_Success__c.addError(getTAG086());
            } 
            if(PMObject.SVMXC__Error_Email_ID__c == null)
            {
                ISValid = false;
                PMObject.SVMXC__Error_Email_ID__c.AddError(getTAG090());
            }
       
            //Validation for Product Coverage Tab...........
            if(PMWrapperObjlst.size() == 0)
            {
                ISValid = false;        
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG088()));
            }
            /*for(Integer i = 0; i<PMWrapperObjlst.size(); i++)
            {
                if(PMWrapperObjlst[i].PMCoverage.SVMXC__PM_Frequency__c == null || PMWrapperObjlst[i].PMCoverage.SVMXC__PM_Frequency__c == 0)
                {
                    ISValid = false;
                    PMWrapperObjlst[i].PMCoverage.SVMXC__PM_Frequency__c.addError(getTAG089());
                }
            } */ 
            return ISValid;
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }            
        return null;
   }
   
   
    //PageReference Method..
    
   // Button Methods.........
  
    public pageReference SVMX_PMSave()
    {
        
        try
        {
            SavePMCoverageData.clear();
            PMObject.SVMXC__Work_Order_Date__c = null;
            if(PMObject.SVMXC__Next_PM_Date__c == null)
            {
                SVMX_Recalculate();
                if(SVMX_Recalculate == true)
                    return null;
            }
            if(SVMX_ISValidPM() == true)
            {
                PMObject.SVMXC__Service_Contract__c = SCID;
                if(PMObject.SVMXC__Next_PM_Date__c != null && PMObject.SVMXC__Create_Work_Order__c != null)
                {
                    double d = PMObject.SVMXC__Create_Work_Order__c;
                    Integer i = d.intvalue();
                    PMObject.SVMXC__Work_Order_Date__c = PMObject.SVMXC__Next_PM_Date__c - i;
                }
                if(PMObject.SVMXC__Create_Work_Order__c == 0)
                {
                    PMObject.SVMXC__Work_Order_Date__c = PMObject.SVMXC__Next_PM_Date__c;
                }
                if(PMObject.SVMXC__Work_Order_Assign_To__c == 'Primary Technician')
                {
                    PMObject.SVMXC__Work_Order_Assign_To_User__c = null;
                    PMObject.SVMXC__Work_Order_Assign_To_Queue__c = null;
                }
                if(PMObject.SVMXC__Work_Order_Assign_To__c == 'User')
                {
                    PMObject.SVMXC__Work_Order_Assign_To_Queue__c = null;
                   //PMObject.SVMXC__Dispatch_Process__c = null; (commented by amar on 18/03/10 at 5:00 PM)
                }
                if(PMObject.SVMXC__Work_Order_Assign_To__c == 'Queue')
                {
                    PMObject.SVMXC__Work_Order_Assign_To_User__c = null;
                    //PMObject.SVMXC__Dispatch_Process__c = null; (commented by amar on 18/03/10 at 5:00 PM)
                }
                if(PMObject.SVMXC__Case_Assign_To__c == 'User')
                {
                    PMObject.SVMXC__Case_Assign_To_Queue__c = null;
                }
                if(PMObject.SVMXC__Case_Assign_To__c == 'Queue')
                {
                    PMObject.SVMXC__Case_Assign_To_User__c = null;
                }
                //upsert PMObject;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( PMObject, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert PMObject; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    HdrMsg =true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                
                system.debug('PMWrapperObjlst'+PMWrapperObjlst+PMWrapperObjlst.size());
                if(PMObject.id != null)
                {
                    
                    for(PMWrapper p :PMWrapperObjlst)
                    {
                       if(p.PMCoverage.Id == null)
                       {
                            p.PMCoverage.SVMXC__PM_Plan__c = PMObject.id;
                            SavePMCoverageData.add(p.PMCoverage);
                       }    
                    }
                }
                system.debug('SavePMCoverageData'+SavePMCoverageData+SavePMCoverageData.size());
                //upsert SavePMCoverageData;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SavePMCoverageData, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert SavePMCoverageData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    HdrMsg =true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                for(String s : gd.keyset()) 
                {
                    if(s == 'SVMX_PM_Jobs__c')
                    {
                          String SOQL = 'Select id from SVMX_PM_Jobs__c';
                          List<sobject> Count = Database.Query(SOQL);
                          if(Count.size() == 0)
                          {
                             Schema.DescribeSObjectResult m = gd.get(s).getDescribe();
                             Schema.SObjectType ad = m.getSobjectType();
                             sObject  s1 = ad.newsobject();
                             s1.put('PM_Job_Date__c',system.now()); 
                             s1.put('Run_PM_Job__c',true);
                             insert s1; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                           } 
                     }
                }           
                string url = '';
                if(svmxSettingList.containsKey('SET002'))
                    url = svmxSettingList.get('SET002');
                PageReference pageref = new PageReference(url);
                pageref.setRedirect(true);
                pageref.getparameters().put('scid',SCID);
                return pageref;
            }
            else
            {
                    HdrMsg = true;  
            }
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }         
        return null;
    }
    public pageReference SVMX_Cancel()
    {
        try
        {
            string url = '';
            if(svmxSettingList.containsKey('SET002'))
                 url = svmxSettingList.get('SET002');
            PageReference pageref = new PageReference(url);
            pageref.setRedirect(true);
            pageref.getparameters().put('scid',SCID);
            return pageref;
        }
        catch(Exception ex)
        {
            HdrMsg =true;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage())); 
        }     
        return null;   
    }
    public pageReference SVMX_FindCoveredProduct()
    {
        SearchKeyword ='';
        FilterByPF = false;
        FilterByPL = false;   
        PopupWrapperObjLst.clear();
        displayPopup = true;
        return null;
    }
    List<integer> SelectedLine = new List<integer>();
    public pageReference SVMX_DelData()
    {
        Integer i;
        selectedLine.clear();
        DelPMCoverageData.clear();
        set<ID> DelPMCID = new Set<ID>();
        for(i = 0;i<PMWrapperObjlst.size();i++)
        {
                if(PMWrapperObjlst[i].bselect == true & PMWrapperObjlst[i].PMCoverage.id != null)
                {
                        DelPMCoverageData.add(PMWrapperObjlst[i].PMCoverage);
                        SelectedLine.add(i);
                        PMWrapperObjlst[i].bselect = false;
                        CheckAll = false;
                }
                if(PMWrapperObjlst[i].bselect == true & PMWrapperObjlst[i].PMCoverage.id == null)
                {
                        SelectedLine.add(i);
                        PMWrapperObjlst[i].bselect = false;
                }
        }
        if(SelectedLine.size()<1)
        {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG096()));
            return null;
        }
        for(Integer j = SelectedLine.size()-1; j>=0; j--)
        {
                PMWrapperObjlst.remove(selectedLine.get(j));
        }
        if(DelPMCoverageData.size() > 0)
        {       
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__PM_Coverage__c' ) ) {                
                HdrMsg = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142) );
                return null;
            }
            delete DelPMCoverageData; //SDL-SVMX-DELETE-FLS-ENFORCED
        }   
        HdrMsg = true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG092()));
        
        return null;
    }
    
    //Poopup page PageReference method....
    public List<SVMXC__Service_Contract_Products__c> SearchProductLst = new List<SVMXC__Service_Contract_Products__c>();
    public PageReference SVMX_Go()
    {
        SearchKeyword.trim();
        SearchProductLst.clear();
        PopupWrapperObjLst.clear();
        
        if(SearchKeyword == null || SearchKeyword.length() < 2)
        {
                PopupMsg = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG066()));    
        }
        try
        {
        if(SearchKeyword.length() >= 2 && CoveredProductIdLst.size() > 0)
        {
            String searchKeywordRefined = String.escapeSingleQuotes(SearchKeyword);
            if(FilterByPF == true )
            {
                SearchProductLst = Database.query('Select s.SVMXC__Installed_Product__r.SVMXC__Product__r.name, SVMXC__Installed_Product__r.Name, s.SVMXC__Installed_Product__c, s.Id  From SVMXC__Service_Contract_Products__c s where id IN: CoveredProductIdLst and (SVMXC__Installed_Product__r.Name LIKE \'%'+searchKeywordRefined+'%\'OR SVMXC__Installed_Product__r.SVMXC__Product__r.Name LIKE \'%'+searchKeywordRefined+'%\' OR SVMXC__Installed_Product__r.SVMXC__Product__r.Family LIKE \'%'+searchKeywordRefined+'%\')');
                
            }
            if(FilterByPL == true)
            {
                SearchProductLst = Database.query('Select s.SVMXC__Installed_Product__r.SVMXC__Product__r.name, SVMXC__Installed_Product__r.Name, s.SVMXC__Installed_Product__c, s.Id  From SVMXC__Service_Contract_Products__c s where id IN: CoveredProductIdLst and (SVMXC__Installed_Product__r.Name LIKE \'%'+searchKeywordRefined+'%\'OR SVMXC__Installed_Product__r.SVMXC__Product__r.Name LIKE \'%'+searchKeywordRefined+'%\' OR SVMXC__Installed_Product__r.SVMXC__Product__r.SVMXC__Product_Line__c LIKE \'%'+searchKeywordRefined+'%\')');
                 
            }
            if(FilterByPF == true && FilterByPL == true)
            {
                 SearchProductLst = Database.query('Select s.SVMXC__Installed_Product__r.SVMXC__Product__r.name, SVMXC__Installed_Product__r.Name, s.SVMXC__Installed_Product__c, s.Id  From SVMXC__Service_Contract_Products__c s where id IN: CoveredProductIdLst and (SVMXC__Installed_Product__r.Name LIKE \'%'+searchKeywordRefined+'%\'OR SVMXC__Installed_Product__r.SVMXC__Product__r.Name LIKE \'%'+searchKeywordRefined+'%\' OR SVMXC__Installed_Product__r.SVMXC__Product__r.SVMXC__Product_Line__c LIKE \'%'+searchKeywordRefined+'%\' OR SVMXC__Installed_Product__r.SVMXC__Product__r.Family LIKE \'%'+searchKeywordRefined+'%\')');
                 
            }
            if(FilterByPF == false && FilterByPL == false)
            {
                SearchProductLst = Database.query('Select s.SVMXC__Installed_Product__r.SVMXC__Product__r.name, SVMXC__Installed_Product__r.Name, s.SVMXC__Installed_Product__c, s.Id  From SVMXC__Service_Contract_Products__c s where id IN: CoveredProductIdLst and (SVMXC__Installed_Product__r.Name LIKE \'%'+searchKeywordRefined+'%\'OR SVMXC__Installed_Product__r.SVMXC__Product__r.Name LIKE \'%'+searchKeywordRefined+'%\')');    
                   
            }
            system.debug('SearchProductLst'+SearchProductLst+SearchProductLst.size());  
            for(Integer i = 0; i<SearchProductLst.size(); i++)
            {
                boolean IsNotExist= true;
                for(Integer j = 0; j< PMWrapperObjlst.size(); j++)
                {
                    if(PMWrapperObjlst[j].IPID == SearchProductLst[i].SVMXC__Installed_Product__c )
                    IsNotExist = false;
                }
                if(IsNotExist)
                    PopupWrapperObjLst.add(new PMWrapper(new SVMXC__PM_Coverage__c(),SearchProductLst[i]));
            }
            system.debug('PopupWrapperObjLst'+PopupWrapperObjLst+PopupWrapperObjLst.size());       
        }
        if(PopupWrapperObjLst.size() == 0 && SearchKeyword.length() >= 2)
        {
            PopupMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG093()));
        }
    }
        catch(Exception e)  
        {
        
        }             
        return null;
    }
    public pageReference SVMX_AddSelected()
    {
        List<integer> SelectedLines = new list<integer>();
        for(integer i = 0; i<PopupWrapperObjLst.size(); i++)
        {
            if(PopupWrapperObjLst[i].bselect == true)
            {
                SelectedLines.add(i);
                PMWrapperObjlst.add(PopupWrapperObjLst[i]);
                displayPopup = false;
                PopupWrapperObjLst[i].bselect = false;
                CheckAll = false;
            }
        }    
        if(SelectedLines.size() < 1)
        {
             PopupMsg = true;
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG069()));        
        }
           
        return null;
    }
    public pageReference SVMX_CancelPopup()
    {
        displayPopup = false;
        return null;
    }
    
   //Recalculate Method.........
    public Boolean SVMX_Recalculate = false;       
    public pagereference SVMX_Recalculate()
    {
        system.debug('amar1');
        SVMX_Recalculate = false;
        if(PMObject.SVMXC__Frequency_Unit__c == null )
        {
            HdrMsg = true;
            PMObject.SVMXC__Frequency_Unit__c.addError(getTAG079());
        }
        if(PMObject.SVMXC__Frequency__c == null)
        {
            HdrMsg = true;
            PMObject.SVMXC__Frequency__c.addError(getTAG079());
        }
        if(PMObject.SVMXC__Schedule_Type__c != 'Counter Based' && PMObject.SVMXC__Schedule_Type__c != null && PMObject.SVMXC__Frequency__c != null)
        {
            if(PMObject.SVMXC__Last_PM_Date__c == null)
            {
                date newdate;
                if(PMObject.SVMXC__Frequency_Unit__c == 'Days')
                {
                    double d = PMObject.SVMXC__Frequency__c;
                    Integer i = d.intvalue();
                    newdate = PMObject.SVMXC__Start_Date__c.adddays(i);
                    if(newdate < system.today())
                    {
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'TRUE')
                        {
                            newdate = system.today().adddays(i);
                        }
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'FALSE')
                        {
                            newdate = PMObject.SVMXC__Next_PM_Date__c;
                        }   
                    }
                    if(newdate > PMObject.SVMXC__End_Date__c)
                    {
                        HdrMsg = true;
                        SVMX_Recalculate = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058()));
                    }
                    else
                    {         
                        PMObject.SVMXC__Next_PM_Date__c = newdate;
                    }   
                 }
                 if(PMObject.SVMXC__Frequency_Unit__c == 'Months')
                 {
                    double d = PMObject.SVMXC__Frequency__c;
                    Integer i = d.intvalue();
                    newdate = PMObject.SVMXC__Start_Date__c.addMonths(i);
                     if(newdate < system.today())
                    {
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'TRUE')
                        {
                            newdate = system.today().addMonths(i);
                        }
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'FALSE')
                        {
                            newdate = PMObject.SVMXC__Next_PM_Date__c;
                        }   
                    }
                    if(newdate > PMObject.SVMXC__End_Date__c)
                    {
                        HdrMsg = true;
                        SVMX_Recalculate = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058()));
                    }
                    else
                    {         
                        PMObject.SVMXC__Next_PM_Date__c = newdate;
                    }   
                 }
                 if(PMObject.SVMXC__Frequency_Unit__c == 'Years')
                 {
                    double d = PMObject.SVMXC__Frequency__c;
                    Integer i = d.intvalue();
                    newdate = PMObject.SVMXC__Start_Date__c.addYears(i);
                    if(newdate < system.today())
                    {
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'TRUE')
                        {
                            newdate = system.today().addYears(i);
                        }
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'FALSE')
                        {
                            newdate = PMObject.SVMXC__Next_PM_Date__c;
                        }   
                    }
                    if(newdate > PMObject.SVMXC__End_Date__c)
                    {
                        HdrMsg = true;
                        SVMX_Recalculate = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058()));
                    }
                    else
                    {         
                        PMObject.SVMXC__Next_PM_Date__c = newdate;
                    }   
                }
             }
             if(PMObject.SVMXC__Last_PM_Date__c != null)
             {
                if(PMObject.SVMXC__Frequency_Unit__c == 'Days')
                {
                    double d = PMObject.SVMXC__Frequency__c;
                    Integer i = d.intvalue();
                    date newdate = PMObject.SVMXC__Last_PM_Date__c.adddays(i);
                    if(newdate < system.Today())
                    {
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'TRUE')
                        {
                            newdate = system.today().adddays(i);
                        }
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'FALSE')
                        {
                            newdate = PMObject.SVMXC__Next_PM_Date__c;
                        }   
                    }
                    if(newdate > PMObject.SVMXC__End_Date__c)
                    {
                        SVMX_Recalculate = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058()));
                    }        
                    else
                    {      
                        PMObject.SVMXC__Next_PM_Date__c = newdate;
                    }   
                }
                if(PMObject.SVMXC__Frequency_Unit__c == 'Months')
                {
                    double d = PMObject.SVMXC__Frequency__c;
                    Integer i = d.intvalue();
                    date newdate = PMObject.SVMXC__Last_PM_Date__c.addMonths(i);
                    if(newdate < system.today())
                    {
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'TRUE')
                        {
                            newdate = system.today().addMonths(i);
                        }
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'FALSE')
                        {
                            newdate = PMObject.SVMXC__Next_PM_Date__c;
                        }
                    }
                    if(newdate > PMObject.SVMXC__End_Date__c)
                    {
                        SVMX_Recalculate = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058()));
                    }   
                    else
                    {    
                        PMObject.SVMXC__Next_PM_Date__c = newdate;
                    }   
                }
                if(PMObject.SVMXC__Frequency_Unit__c == 'Years')
                {
                    double d = PMObject.SVMXC__Frequency__c;
                    Integer i = d.intvalue();
                    date newdate = PMObject.SVMXC__Last_PM_Date__c.addYears(i);
                    if(newdate < system.today())
                    {
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'TRUE')
                        {
                            newdate = system.today().addYears(i);
                        }
                        if(svmxSettingList.containsKey('SET001') &&  svmxSettingList.get('SET001').toUppercase() == 'FALSE')
                        {
                            newdate = PMObject.SVMXC__Next_PM_Date__c;
                        }                                  
                    }
                    if(newdate > PMObject.SVMXC__End_Date__c)
                    {
                        SVMX_Recalculate = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058()));
                    }   
                    else
                    {                    
                        PMObject.SVMXC__Next_PM_Date__c = newdate;
                    }   
                }
            }
        }
        
        return null;    
    }
   
    //Action Function Methods.....
    public pageReference SVMX_EnbleCaseDetail()
    {
        return null;
    }
    public pageReference SVMX_OnSelectWO()
    {
        return null;
    }
    public pageReference SVMX_OnSelectCase()
    {
        return null;
    }
    public pageReference SVMX_OnChangeSheduleType()
    {
        return null;
    }
    public pagereference SVMX_Chngfldmap()
    {
        return null;
    }
    /*public pagereference SVMX_DateChngFun()
    {
        return null;
    }*/
    
    //Button Methds for Changing Tabs........
    public pageReference SVMX_PM_WOSetting()
    {
        selectedTab = getTAG005();
        return null;
    }
    public pageReference SVMX_PM_Plan()
    {
        selectedTab = getTAG004();
        return null;
    }
    public pageReference SVMX_PM_Alert()
    {
        selectedTab = getTAG006();
        return null;
    }
     public pageReference SVMX_PM_ProductCoverage()
    {
        selectedTab = getTAG007();
        return null;
    }
    
    //PageMessage Method
    
    public Boolean getPopupMsg(){return PopupMsg;} 
    
   
    public Boolean getHdrMsg(){return HdrMsg;}
    
    //Record diaplay Method...
    
    public Boolean DisplayRecord = false;
    public Boolean getDisplayRecord()
    {
      if(PMWrapperObjlst == null || PMWrapperObjlst.size() == 0)
        DisplayRecord = true;
      else 
        DisplayRecord = false;
      return DisplayRecord;
    }
    public Boolean DisableFindCP = false;
    public Boolean getDisableFindCP()
    {
      if(CoveredProduct.size() == 0)
        DisableFindCP = true;
      return DisableFindCP;
    }
    public Boolean getdisplayfindpro()
    {
        Boolean displayfindpro = false;
        if(PopupWrapperObjLst.size() == 0)
            displayfindpro = true;
        else displayfindpro = false;    
        return displayfindpro;  
    }
    /*private Map<String,String> SVMX_getDefaultPicklistValue(String ObjName, List<String> FieldName)
    {
        string DefVal;
        Map<String,String> MapofDefaulPickList = new Map<String,String>();
        List<Schema.SObjectType> listObjName = allObjs.values();
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        if(listObjName != null && listObjName.size() > 0)
        {
           // get the field map of selected Object
            for(Schema.SObjectType s:listObjName)
            {
                
                Schema.Describesobjectresult DSO = s.getDescribe();
                if(DSO != null && DSO.getname() == ObjName )
                {
                    objfieldMap = DSO.fields.getMap(); 
                    for(Integer i = 0; i < FieldName.size(); i++)
                    {     
                        for(Schema.SObjectField fld:objfieldMap.values())
                        {
                           Schema.DescribeFieldResult FSO = fld.getDescribe();
                          
                           if(FSO != null &&  FSO.getname() == FieldName[i])
                           {
                            
                                if(FSO.getType() == Schema.DisplayType.PickList)
                                {
                                    List<Schema.PicklistEntry> P = FSO.getPicklistValues(); // returing picklist values
                                    for(integer v=0;v<p.size();v++)
                                    {
                                        if(p[v].isDefaultValue()) // check for default value
                                        {
                                            DefVal = p[v].getValue();
                                            MapofDefaulPickList.put(FieldName[i],DefVal);
                                        }  
                                    }
                                 } 
                                 break;  
                             }
                         }  
                      }  
                       break;
                   }
                 
                }
            }
                
        return MapofDefaulPickList;
    }*/
   
}