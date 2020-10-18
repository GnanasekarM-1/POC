/*--------------------------------------------File Definition ----------------------*/
//CONF_SetupScheduledSFM is the controller class for VF page CONF_SetupScheduledSFM
//Created as part of Feb 14 Sprint for ScheduledSFM feature development

public with sharing class CONF_SetupScheduledSFM
{
    //Added the code as part of 045138
    public class ObjectListWrapper{
        final Integer COLLECTION_SIZE_LIMIT = 1000;
        public List<SelectOption> collectionList = new List<SelectOption>();

        public void add(SelectOption so){
            collectionList.add(so);
        }       

        public Integer getCollectionSize(){
            return collectionList.size();
        }
        
        public List<SelectOption> getcollectionList(){
            return collectionList;
        }

        public SelectOption get(Integer i){
            if(i >-1 && i< getCollectionSize()){
                return collectionList.get(i);
            }else{
                return null;
            }    
        }

        public List<SelectOption> getSubCollectionList(Integer startValue,Integer endValue){
            List<SelectOption> subCollectionList = new List<SelectOption>();
            
            if(startValue >-1 && startValue < collectionList.size() && endValue > -1 && endValue < collectionList.size() && startValue <= endValue){
                
                for(Integer i= startValue; i <= endValue; i++){
                    
                    subCollectionList.add(get(i));
                }
            }
            return subCollectionList;
        }

        public List<SelectOption> getnthCollectionSubList(Integer i){
            
            List<SelectOption> nthCollectionList = new List<SelectOption>();

            Integer subLPicklistCount= (Integer)(collectionList.size()/COLLECTION_SIZE_LIMIT);
            
            if(Math.mod(collectionList.size(),COLLECTION_SIZE_LIMIT)>0) {
                subLPicklistCount++;
            }
            
            if(i >=0 && i <= subLPicklistCount){
                
                Integer startValue = i * COLLECTION_SIZE_LIMIT;
                Integer endValue = i * COLLECTION_SIZE_LIMIT + (COLLECTION_SIZE_LIMIT-1);
               
                if(endValue >= collectionList.size()){ 
                    endValue= collectionList.size() - 1;
                }
                nthCollectionList = getSubCollectionList(startValue,endValue);
            }

            return nthCollectionList;
        }
        
        public List<SelectOption> get1stList(){
            return getnthCollectionSubList(0);
        }
        public List<SelectOption> get2ndList(){
            return getnthCollectionSubList(1);
        }
    }

    public ObjectListWrapper listOfObjects{
        get{
            if(listOfObjects==null){
                  listOfObjects=new ObjectListWrapper();
                  for(Integer i=0;i<LstObjects.size();i++){
                        listOfObjects.add(LstObjects[i]);
                  }
            }
            return listOfObjects;
        }
        set;
    }
    public Boolean getIsSecondListHasItem(){
        Integer sizeOfList = listOfObjects.get1stList().size();
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }
    //End 045138
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/
    
    //--------------------------------------Global Variables and Getter-Setter Methods -----------------------------
    
    public SVMXC__ServiceMax_Processes__c objSFMScheduledProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getSFMScheduledProcess(){return this.objSFMScheduledProcess;}
    public void setSFMScheduledProcess(SVMXC__ServiceMax_Processes__c proces){this.objSFMScheduledProcess = proces;}
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules() { return this.lstSchedules;}
    public void setlstSchedules(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSchedules = lst;}
    
    public List<SVMXC__ServiceMax_Processes__c> lstSFMProcessSelected = new List<SVMXC__ServiceMax_Processes__c>();
    public String getlstSFMProcessSelected(){return JSON.serialize(lstSFMProcessSelected);}
    
    public List<SVMXC__ServiceMax_Processes__c> lstSFMProcessAvilable = new List<SVMXC__ServiceMax_Processes__c>();
    public String getlstSFMProcessAvilable(){return JSON.serialize(lstSFMProcessAvilable);}
    
    private List<SVMXC__ServiceMax_Processes__c> lstSFMPrcss = new List<SVMXC__ServiceMax_Processes__c>();
    private List<SVMXC__ServiceMax_Config_Data__c> lstSFMProcessSelectedToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    private List<SVMXC__ServiceMax_Config_Data__c> lstSchedules_toDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public integer intSeqVal;
    public integer getintSeqVal(){return this.intSeqVal;}
    public void setintSeqVal(integer index){this.intSeqVal = index;}
    
    //Get List of Objects in Org
    public List<SelectOption> LstObjects = new  List<SelectOption>();
    public List<SelectOption> getLstObjects(){return LstObjects;}
    
   /* public List<SelectOption> LstClasses = new  List<SelectOption>();
    public List<SelectOption> getLstClasses(){return LstClasses;}*/
    
    public String getTAG026(){return System.Label.COMM002_TAG005;}  //'--None--'
    public Integer lstSchedules_HighSeqNum 
    {
        get{return lstSchedules.size();}
    }
    private string strRecordId;
    private string strMode;
    public String strSelectedRow {get; set;}
    private boolean isValidate{get;set;}
    public string strSelectedTab{get;set;}
    public List<SelectOption> lstTimeZones{get;set;}
    private RecordType schedule_Rtype;
    private RecordType SFMScheduledProcess_Rtype;
    private RecordType scheduleDetail_Rtype;
    public String strSelectedIds{get;set;}
    public String strRemoverIds{get;set;}
    private Set<String> setSelectedIds = new Set<String>();
    private User userTimeZone;
    public String strServicesSelectedRow {get; set;}
    public String selectedServiceObject {get; set;}
    
    public Integer lstScheduleServices_HighSeqNum 
    {
        get{return listScheduleServices.size();}
    }
    
    // ----------------------Wrapper Class -----------------------------------------------------------
    public class wrapperConfigData {
        public SVMXC__ServiceMax_Config_Data__c   scheduleService     {get; set;}
        public List<SelectOption>                   listSFMExpression   {get; set;}
        public String                               selectedExpression   {get; set;}
        public String getTAG026()                   {return System.Label.COMM002_TAG005;}
        public wrapperConfigData(SVMXC__ServiceMax_Config_Data__c schedule){
            this.scheduleService    = schedule;
            this.listSFMExpression  = new  List<SelectOption>();
            if(schedule.Expression_Rule__c != null){

                this.listSFMExpression.add(new SelectOption(schedule.SVMXC__Expression_Rule__c, schedule.SVMXC__Expression_Rule__r.SVMXC__Name__c)); 
            }
            else{
                this.listSFMExpression.add(new SelectOption('SVMX.NONE', getTAG026()));
            }
        }
   }
   
   //Use the Wrapper Class List to display records 
   public List<wrapperConfigData> listScheduleServices     {get; set;}
    
//---------------------------------------- Constructor/On-Load --------------------------------------------------
    
    public CONF_SetupScheduledSFM(){
        try{
            strMode = System.currentPageReference().getParameters().get('SVMX_Mode');
            strRecordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
            listScheduleServices = new List<wrapperConfigData>(); 
            userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];
            isValidate = true;
            objSFMScheduledProcess.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
            
            lstTimeZones = new List<SelectOption>();
            Schema.DescribeFieldResult timeZoneinfo = user.TimeZoneSidKey.getDescribe();
            List<Schema.PicklistEntry> lstallTimezones = timeZoneinfo.getPicklistValues();
            for(Schema.PicklistEntry timeZoneinst: lstallTimezones)
                lstTimeZones.add(new selectOption(timeZoneinst.getValue(),timeZoneinst.getLabel()));
                
            List<RecordType> lstRecordType = [select Name,id from RecordType where (Name='Schedule' OR Name='Schedule Detail' OR Name='Schedule Header')AND (SobjectType='SVMXC__ServiceMax_Config_Data__c' OR SobjectType='SVMXC__ServiceMax_Processes__c')];
            for(RecordType rt : lstRecordType){
                if(rt.Name.equals('Schedule'))
                    schedule_Rtype = rt;
                else if(rt.Name.equals('Schedule Detail'))
                    scheduleDetail_Rtype = rt;
                else if(rt.Name.equals('Schedule Header'))
                    SFMScheduledProcess_Rtype = rt;
            }
            
            //linked process
            List<SVMXC__ServiceMax_Processes__c> lstLinkedProcess = [SELECT Id, SVMXC__Process1__c, SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Linked Process'];
            Set<Id> setIdOfLinked = new Set<Id>();
            for(SVMXC__ServiceMax_Processes__c objproc : lstLinkedProcess){
                setIdOfLinked.add(objproc.SVMXC__Process1__c);
                setIdOfLinked.add(objproc.SVMXC__Process3__c);
            }
            System.debug(LoggingLevel.WARN, 'lstLinkedProcess in Constructor :' + lstLinkedProcess);
            /*
            commenting for testing multisource process in scheduled sfm

            //MultiSource Process
            List<SVMXC__ServiceMax_Processes__c> lstMultiSourceProcess = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process2__c != null AND SVMXC__Enable_Sub_Process__c = true AND SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Dispatch_Process_Status__c = 'Complete'];
            System.debug(LoggingLevel.WARN, 'lstMultiSourceProcess in Constructor :' + lstMultiSourceProcess);
            */

            //Process Node Object of Type TARGET having SubModule not Null
            List<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = new List<SVMXC__ServiceMax_Processes__c>();
            lstProcessNodeObject = [SELECT Id, SVMXC__Process__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Process Node Objects' AND SVMXC__Type__c = 'TARGET' AND SVMXC__Submodule__c != null];
            Set<Id> setIdOfProcessNode = new Set<Id>();
            for(SVMXC__ServiceMax_Processes__c obj : lstProcessNodeObject)
                setIdOfProcessNode.add(obj.SVMXC__Process__c);
            
            //block start for getting ALL SFM Process except linked process And Multisource process
            //commenting for testing multisource process in scheduled sfm
            //lstSFMPrcss = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Dispatch_Process_Status__c = 'Complete' AND (SVMXC__Purpose__c = 'SOURCE TO TARGET ALL' OR SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD' OR SVMXC__Purpose__c = 'STANDALONE EDIT') AND Id NOT IN : setIdOfLinked AND Id NOT IN : lstMultiSourceProcess AND Id IN : setIdOfProcessNode ORDER BY SVMXC__Name__c ASC ];
            lstSFMPrcss = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Dispatch_Process_Status__c = 'Complete' AND (SVMXC__Purpose__c = 'SOURCE TO TARGET ALL' OR SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD' OR SVMXC__Purpose__c = 'STANDALONE EDIT') AND Id NOT IN : setIdOfLinked AND Id IN : setIdOfProcessNode ORDER BY SVMXC__Name__c ASC ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug(LoggingLevel.WARN, 'lstSFMPrcss in Constructor :' + lstSFMPrcss);
            
            // Before loading the main page, get the List of Object available for the org
            Map<String,Boolean> permitdStdObjMap = new Map<String,Boolean>();
            SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
            Boolean isEnterprise = utils.SVMX_isEnterpriseLicense();
            if(!isEnterprise) permitdStdObjMap = utils.SVMX_getPermittedStandardObjectList();
            LstObjects.add(new SelectOption('SVMX.NONE',getTAG026()));
            Map<String,String> SFDCSVMXInternalObjectsMap = new Map<String,String>();
            SFDCSVMXInternalObjectsMap = utils.getSFDCSVMXInternalObjects();
            for(String s : SFDCSVMXInternalObjectsMap.keyset())
            {
                LstObjects.add(new SelectOption(s,SFDCSVMXInternalObjectsMap.get(s)));
            }  
            
            CONF_ManageActions ManageAction = new CONF_ManageActions();
            LstObjects = ManageAction.sortingSelectOption(LstObjects);
            
           /* LstClasses.add(new SelectOption('SVMX.NONE',getTAG026()));
            for(ApexClass apxClass:[SELECT Name FROM ApexClass WHERE NOT Name Like '%_UT%' ORDER BY Name ASC]){
                LstClasses.add(new SelectOption(apxClass.Name,apxClass.Name));
            } */
            
            if(!(strMode.equals('New')) && strRecordId != null && strRecordId != '')
                methodForEditMode(strRecordId);
            else{
                objSFMScheduledProcess = new SVMXC__ServiceMax_Processes__c();                
                lstSchedules_AddRow();
                objSFMScheduledProcess.SVMXC__Active__c = true;
                objSFMScheduledProcess.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
                isValidate = true;
            }
            if(strMode.equals('Clone'))
                methodForCloneMode();
            createProcessList();
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.COMM001_TAG084));
        }
    }
    
/*--------------------------------------------Public methods-------------------------------------*/

    //-----------------------------Method to move SFM process to Available list-------------------------
    public Pagereference moveToAvailable(){
        Set<String> tempSet = new Set<String>();
        if(strRemoverIds != null && strRemoverIds != ''){
            tempSet.AddAll(strRemoverIds.split(','));
            System.debug(LoggingLevel.WARN, 'tempSet in moveToAvailable method :' + tempSet);
            if(tempSet.contains(null))
                tempSet.remove(null);
            if(tempSet.contains(''))
                tempSet.remove('');
            setSelectedIds.removeAll(tempSet);
            createProcessList();
        }
        return null;
    }
    
    //-----------------------------Method to move SFM process to Selected list-------------------------
    public Pagereference moveToSelected(){
        Set<String> tempSet = new Set<String>();
        if(strSelectedIds != null && strSelectedIds != ''){
            tempSet.AddAll(strSelectedIds.split(','));
            System.debug(LoggingLevel.WARN, 'tempSet in moveToSelected method :' + tempSet);
            if(tempSet.contains(null))
                tempSet.remove(null);
            if(tempSet.contains(''))
                tempSet.remove('');
            setSelectedIds.AddAll(tempSet);
            createProcessList();
        }
        return null;
    }
    
     //--------------------------------- Method for on change of Run Type --------------------------------------------------
    public void changeRunType(){        
        if(lstSchedules != null && lstSchedules.size()>0){
            for(SVMXC__ServiceMax_Config_Data__c tempconfigdata : lstSchedules){
                if(tempconfigdata.SVMXC__Sequence__c==(intSeqVal)){
                    tempconfigdata.SVMXC__Day_to_Run__c = null;
                    tempconfigdata.SVMXC__Schedule_Days__c = null;
                }
            }
        }
    }
    
    //--------------------------------- Method for Quick Save of the Process --------------------------------------------------
    public void quickSave(){
        isValidate = true;
        validation();
        if(isValidate == true)
            save();
    }
    
    //--------------------------------- Method for Save and Close of the Process --------------------------------------------------
    public pagereference saveClose(){
        isValidate = true;
        validation();
        if(isValidate == true){
            save();
            String loc = '/apex/CONF_ManageScheduledSFM';
            PageReference objPageReference = new PageReference(loc);
            return objPageReference;
        }
        else
            return null;
    }
    
    //---------------------------- Method to cancel the changes and going back to the previous page -------------------------
    public pagereference cancel(){
        String loc = '/apex/CONF_ManageScheduledSFM';
        PageReference objPageReference = new PageReference(loc);
        return objPageReference;
    }
    
    //------------------------------------- Method to add new row for the schedules ----------------------------------
    public pagereference lstSchedules_AddRow(){
       lstSchedules.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Schedule_Rtype.Id,SVMXC__Run_Type__c='Day of Week', SVMXC__Sequence__c = lstSchedules.size() + 1 ));
       System.debug(LoggingLevel.WARN, 'lstSchedules in lstSchedules_AddRow method :' + lstSchedules);
       return null;
    }
    
    
    //------------------------------------- Method to add new row for the schedules ----------------------------------
    public pagereference lstScheduleService_AddRow(){
       SVMXC__ServiceMax_Config_Data__c newServicesRec = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = scheduleDetail_Rtype.Id, SVMXC__Schedule_Type__c = 'Services', SVMXC__Sequence__c = listScheduleServices.size() + 1 );
       listScheduleServices.add(new wrapperConfigData(newServicesRec));
       System.debug(LoggingLevel.WARN, 'lstScheduleService_AddRow method :' + listScheduleServices);
       return null;
    }
    
    //------------------------------------- Method to delete row for the schedules ----------------------------------
    public pagereference lstSchedules_DelRow(){
        if(lstSchedules == null || (lstSchedules != null && !(lstSchedules.size() > 0)))
            return null;
        Integer tempDeletedIndex = Integer.valueOf(strSelectedRow) - 1;
        //commented because when you are removing all the rows from the schedules and clicking quicksave - showing error
        //if(lstSchedules[tempDeletedIndex] != null && lstSchedules[tempDeletedIndex].get('Id') != null)
           // lstSchedules_toDelete.add(lstSchedules[tempDeletedIndex]);
        lstSchedules.remove(tempDeletedIndex);
        for(integer i=0; i< lstSchedules.size(); i++)
            lstSchedules[i].SVMXC__Sequence__c = i + 1;
        System.debug(LoggingLevel.WARN, 'lstSchedules in lstSchedules_DelRow method :' + lstSchedules);
        return null;
    }
    
    //------------------------------------- Method to delete row for the schedule services ----------------------------------
    public pagereference lstScheduleServices_DelRow(){
        if(listScheduleServices == null || (listScheduleServices != null && !(listScheduleServices.size() > 0)))
            return null;
        Integer servicesDeletedIndex = Integer.valueOf(strServicesSelectedRow) - 1;
        system.debug(servicesDeletedIndex);
        listScheduleServices.remove(servicesDeletedIndex);
        for(integer i=0; i< listScheduleServices.size(); i++)
            listScheduleServices[i].scheduleService.SVMXC__Sequence__c = i + 1;
        System.debug(LoggingLevel.WARN, 'lstScheduleService in lstSchedules_DelRow method :' + listScheduleServices);
        return null;
    }
    
     // -------------------------------------------Method to render SFM Expressions for Services -----------------------------
    public void listObjectSFMExpression(){
            
        Integer recordToRender = Integer.valueOf(selectedServiceObject) - 1;
        wrapperConfigData configDataObj = listScheduleServices.get(recordToRender);
        configDataObj.listSFMExpression.clear();
        configDataObj.listSFMExpression.add(new SelectOption('SVMX.NONE',getTAG026()));
        getlistofExpressions(configDataObj);
    } 

    public void getlistofExpressions(wrapperConfigData wrapDataObj){
        String objApiName = wrapDataObj.scheduleService.Object_Name__c;
        wrapDataObj.listSFMExpression.clear();
        wrapDataObj.listSFMExpression.add(new SelectOption('SVMX.NONE',getTAG026()));
        if(objApiName != null && objApiName != 'null'){
            List<SVMXC__ServiceMax_Processes__c> listSFMExpressions = [SELECT ID, SVMXC__Name__c //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                                                            FROM SVMXC__ServiceMax_Processes__c 
                                                                            WHERE RecordType.Name = 'SVMX Rule' 
                                                                            AND SVMXC__Source_Object_Name__c = : objApiName]; 
            
            if(listSFMExpressions != null && listSFMExpressions.size() > 0){
                for(SVMXC__ServiceMax_Processes__c sfmExpression: listSFMExpressions){
                    wrapDataObj.listSFMExpression.add(new SelectOption(sfmExpression.Id, sfmExpression.SVMXC__Name__c));
                }
            }
        }        
    }

    //------------------------------------- Methods To Switch Between Tabs -----------------------------------------   
    public void GeneralInfo(){
        strSelectedTab = 'TAB1';
    }
    public void Schedules(){
        strSelectedTab = 'TAB2';
    }

/*--------------------------------------------Private methods----------------------------------------------*/

    //--------------------------------- Method for Mode = Edit ---------------------------------
    private void methodForEditMode(String strRcrdId){
        try{
            objSFMScheduledProcess = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Capture_Log__c, SVMXC__IsStandard__c, SVMXC__Active__c,SVMXC__Dispatch_Timezone__c, SVMXC__Assign_To_Dispatcher__c  from SVMXC__ServiceMax_Processes__c where id =: strRcrdId and RecordTypeId =: SFMScheduledProcess_Rtype.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug(LoggingLevel.WARN, 'objSFMScheduledProcess in methodForEditMode method :' + objSFMScheduledProcess);
            
            if(objSFMScheduledProcess != null){
                lstSchedules = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c ,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: schedule_Rtype.Id and SVMXC__Dispatch_Process__c =: objSFMScheduledProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSchedules == null || lstSchedules.size() == 0)
                    lstSchedules_AddRow();
                else{
                    for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstSchedules)
                        lstSchedules_toDelete.add(objCfgDta);
                }
                System.debug(LoggingLevel.WARN, 'lstSchedules_toDelete in methodForEditMode method :' + lstSchedules_toDelete);
                
                lstSFMProcessSelectedToDelete = [select id,SVMXC__Field_Name__c, SVMXC__Batch_Size__c, SVMXC__Expression_Rule__r.SVMXC__Name__c, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c ,SVMXC__Object_Name__c , SVMXC__Class_Name__c ,SVMXC__Schedule_Type__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c != null AND SVMXC__Dispatch_Process__c =: objSFMScheduledProcess.Id AND RecordTypeId =: scheduleDetail_Rtype.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                System.debug(LoggingLevel.WARN, 'lstSFMProcessSelectedToDelete in methodForEditMode method :' + lstSFMProcessSelectedToDelete);
                
                for(SVMXC__ServiceMax_Config_Data__c objCfgDta : lstSFMProcessSelectedToDelete){
                    if(objCfgDta.SVMXC__Schedule_Type__c == 'Services'){
                        wrapperConfigData createConfigDataWrapperObj = new wrapperConfigData(objCfgDta);
                        //system.debug(createConfigDataWrapperObj);
                        listScheduleServices.add(createConfigDataWrapperObj);
                        //Defect 018832 Fix                        
                        getlistofExpressions(createConfigDataWrapperObj);
                        createConfigDataWrapperObj.selectedExpression =  objCfgDta.SVMXC__Expression_Rule__c;                     
                    }
                    else{
                        setSelectedIds.add(objCfgDta.SVMXC__Expression_Rule__c);
                    }
                }
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG077,''));
        }
    }
    
    //--------------------------------- Method for Mode = Clone ---------------------------------
    private void methodForCloneMode(){
        SVMXC__ServiceMax_Processes__c tempProcess = new SVMXC__ServiceMax_Processes__c();
        tempProcess = objSFMScheduledProcess;
        objSFMScheduledProcess = new SVMXC__ServiceMax_Processes__c();
        objSFMScheduledProcess.SVMXC__Name__c = tempProcess.SVMXC__Name__c;
        objSFMScheduledProcess.SVMXC__ProcessID__c = tempProcess.SVMXC__ProcessID__c;
        objSFMScheduledProcess.SVMXC__Description__c = tempProcess.SVMXC__Description__c;
        objSFMScheduledProcess.SVMXC__Capture_Log__c = tempProcess.SVMXC__Capture_Log__c;
        objSFMScheduledProcess.SVMXC__Assign_To_Dispatcher__c = tempProcess.SVMXC__Assign_To_Dispatcher__c;
        objSFMScheduledProcess.RecordTypeId = SFMScheduledProcess_Rtype.Id;
        objSFMScheduledProcess.SVMXC__IsStandard__c = false;
        objSFMScheduledProcess.SVMXC__Active__c = tempProcess.SVMXC__Active__c;
        objSFMScheduledProcess.SVMXC__Dispatch_Timezone__c = tempProcess.SVMXC__Dispatch_Timezone__c;
        
        List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        tempLst.addAll(lstSchedules);
        lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c CD : tempLst){
            SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
            confData.SVMXC__Sequence__c = CD.SVMXC__Sequence__c;
            confData.SVMXC__Run_At__c = CD.SVMXC__Run_At__c;
            confData.SVMXC__Schedule_Days__c = CD.SVMXC__Schedule_Days__c;
            confData.SVMXC__Run_Type__c = CD.SVMXC__Run_Type__c;
            confData.SVMXC__Day_to_Run__c = CD.SVMXC__Day_to_Run__c;
            confData.RecordTypeId = schedule_Rtype.Id;
            lstSchedules.add(confData);
        }
        System.debug(LoggingLevel.WARN, 'lstSchedules in methodForCloneMode method :' + lstSchedules);
        lstSFMProcessSelectedToDelete.clear();
        lstSchedules_toDelete.clear();
    }
    
    //---------------------------------Method for creating SFM process Available and Selected List---------------------------------
    private void createProcessList(){
        lstSFMProcessAvilable.clear();
        lstSFMProcessSelected.clear();
        for(SVMXC__ServiceMax_Processes__c objProcess : lstSFMPrcss){
            if(setSelectedIds.contains(objProcess.Id))
                lstSFMProcessSelected.add(objProcess);
            else
                lstSFMProcessAvilable.add(objProcess);
        }
    }
    
    //------------------------------------ Method to Save the Process and Config Data ---------------------------------
    private void save(){
        Savepoint objSavePoint;
        try{
            objSavePoint = Database.setSavepoint();
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSaveScheduleRecord = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSaveScheduleDetail = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSaveScheduleServicesDetail = new List<SVMXC__ServiceMax_Config_Data__c>();
            objSFMScheduledProcess.RecordTypeId = SFMScheduledProcess_Rtype.Id;
            //upsert objSFMScheduledProcess; 
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(objSFMScheduledProcess, COMM_SecurityUtils.Access.Upsertable)){
                upsert objSFMScheduledProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                Database.rollback(objSavePoint);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142,''));
            }
            
            if(lstSchedules != null && lstSchedules.size()>0){
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules){
                    SVMXC__ServiceMax_Config_Data__c configdataTemp = new SVMXC__ServiceMax_Config_Data__c();
                    if(configdata.SVMXC__Run_Type__c== System.label.COMM002_TAG005 ||configdata.SVMXC__Run_Type__c== ''){
                        configdataTemp.SVMXC__Run_Type__c=null;
                        configdataTemp.SVMXC__Schedule_Days__c=null;
                        configdataTemp.SVMXC__Day_to_Run__c=null;
                    }
                    if(configdata.SVMXC__Run_Type__c.equals('Day of Week')){
                        if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=System.label.COMM002_TAG005 && configdata.SVMXC__Schedule_Days__c != null && configdata.SVMXC__Schedule_Days__c != '' && configdata.SVMXC__Schedule_Days__c != System.label.COMM002_TAG005 && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c != System.label.COMM002_TAG005){
                            configdataTemp.SVMXC__Day_to_Run__c=null;
                            configdataTemp.SVMXC__Run_At__c= configdata.SVMXC__Run_At__c;
                            configdataTemp.SVMXC__Sequence__c= configdata.SVMXC__Sequence__c;
                            configdataTemp.SVMXC__Run_Type__c= configdata.SVMXC__Run_Type__c;
                            configdataTemp.SVMXC__Schedule_Days__c= configdata.SVMXC__Schedule_Days__c;
                            configdataTemp.RecordTypeId = Schedule_Rtype.Id;
                            configdataTemp.SVMXC__Dispatch_Process__c = objSFMScheduledProcess.Id;
                            lstConfigdataToSaveScheduleRecord.add(configdataTemp);
                        }
                    }
                    if(configdata.SVMXC__Run_Type__c.equals('Date of Month')){
                        if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=System.label.COMM002_TAG005 && configdata.SVMXC__Day_to_Run__c != null && configdata.SVMXC__Day_to_Run__c != '' && configdata.SVMXC__Day_to_Run__c != System.label.COMM002_TAG005  && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c != System.label.COMM002_TAG005){
                            configdataTemp.SVMXC__Schedule_Days__c=null;
                            configdataTemp.SVMXC__Run_At__c= configdata.SVMXC__Run_At__c;
                            configdataTemp.SVMXC__Sequence__c= configdata.SVMXC__Sequence__c;
                            configdataTemp.SVMXC__Run_Type__c= configdata.SVMXC__Run_Type__c;
                            configdataTemp.SVMXC__Day_to_Run__c= configdata.SVMXC__Day_to_Run__c;
                            configdataTemp.RecordTypeId = Schedule_Rtype.Id;
                            configdataTemp.SVMXC__Dispatch_Process__c = objSFMScheduledProcess.Id;
                            lstConfigdataToSaveScheduleRecord.add(configdataTemp);
                        }
                    }
                }
            }
            System.debug(LoggingLevel.WARN, 'lstConfigdataToSaveScheduleRecord in save method :' + lstConfigdataToSaveScheduleRecord);
            
            if(listScheduleServices != null && listScheduleServices.size()>0){
                for(wrapperConfigData wrapperRec : listScheduleServices){
                    SVMXC__ServiceMax_Config_Data__c servicesConfigdata = wrapperRec.scheduleService.clone(false, true);
                    servicesConfigdata.Expression_Rule__c = Id.valueOf(wrapperRec.selectedExpression);
                    servicesConfigdata.SVMXC__Dispatch_Process__c = objSFMScheduledProcess.Id;
                    servicesConfigdata.SVMXC__Schedule_Type__c = 'Services';
                    lstConfigdataToSaveScheduleServicesDetail.add(servicesConfigdata);
                }
            }
            
            System.debug(LoggingLevel.WARN, 'lstConfigdataToSaveScheduleServicesDetail in save method :' + lstConfigdataToSaveScheduleServicesDetail);
            
            for(String strId : setSelectedIds){
                SVMXC__ServiceMax_Config_Data__c objConfigDate = new SVMXC__ServiceMax_Config_Data__c();
                objConfigDate.SVMXC__Dispatch_Process__c = objSFMScheduledProcess.Id;
                objConfigDate.SVMXC__Expression_Rule__c = strId;
                objConfigDate.RecordTypeId = scheduleDetail_Rtype.Id;
                lstConfigdataToSaveScheduleDetail.add(objConfigDate);
            }
            System.debug(LoggingLevel.WARN, 'lstConfigdataToSaveScheduleDetail in save method :' + lstConfigdataToSaveScheduleDetail);
            
            List<SVMXC__ServiceMax_Config_Data__c> lstToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstToDelete.addAll(lstSchedules_toDelete);
            lstToDelete.addAll(lstSFMProcessSelectedToDelete);
            System.debug(LoggingLevel.WARN, 'lstToDelete in save method :' + lstToDelete);
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                
                delete lstToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return;
            }
            
            lstSchedules_toDelete.clear();
            lstSFMProcessSelectedToDelete.clear();
            
            List<SVMXC__ServiceMax_Config_Data__c> lstToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstToSave.addAll(lstConfigdataToSaveScheduleDetail);
            lstToSave.addAll(lstConfigdataToSaveScheduleRecord);
            lstToSave.addAll(lstConfigdataToSaveScheduleServicesDetail);
            System.debug(LoggingLevel.WARN, 'lstToSave in save method :' + lstToSave);
            
            if(lstToSave != null && lstToSave.size() > 0){
                 /*
                    SECSCAN-822 : Security Fix
                */
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(lstToSave, COMM_SecurityUtils.Access.Createable)){
                    Database.rollback(objSavePoint);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142,''));
                }
                insert lstToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
               
            
            lstSchedules_toDelete.addAll(lstConfigdataToSaveScheduleRecord);
            lstSFMProcessSelectedToDelete.addAll(lstConfigdataToSaveScheduleDetail);
            lstSFMProcessSelectedToDelete.addAll(lstConfigdataToSaveScheduleServicesDetail);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.label.COMM001_TAG058,''));
        }catch(Exception ex){
            Database.rollback(objSavePoint);
            System.debug('on save catch : '+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG077,''));
        }
    }
    
    //------------------------------------- Method for the validations on the Page ----------------------------------
    private void validation()
    {
        try{
            if(objSFMScheduledProcess.SVMXC__Name__c == null || objSFMScheduledProcess.SVMXC__Name__c == ''){
                isValidate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.CONF039_TAG013,''));
                return;
            }
            else if(objSFMScheduledProcess.SVMXC__ProcessID__c == null || objSFMScheduledProcess.SVMXC__ProcessID__c == ''){
                isValidate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.CONF039_TAG014,''));
                return;
            }
            else if(objSFMScheduledProcess.SVMXC__ProcessID__c.length() < 8){
                isValidate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG085,''));
                return;
            }
            else if(objSFMScheduledProcess.SVMXC__Assign_To_Dispatcher__c == null){
                isValidate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.CONF039_TAG007,''));
                return;
            }
            List<SVMXC__ServiceMax_Processes__c> lstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
            String strUniqueProcessId = objSFMScheduledProcess.SVMXC__ProcessID__c;
            String strSFMScheduledProcess_RtypeID = SFMScheduledProcess_Rtype.Id;
            String strScheduleHeaderId;
            if(objSFMScheduledProcess.get('Id') == null)
                lstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strUniqueProcessId and RecordTypeId =: strSFMScheduledProcess_RtypeID');         
            else{
                strScheduleHeaderId = objSFMScheduledProcess.Id;
                lstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strUniqueProcessId and RecordTypeId =: strSFMScheduledProcess_RtypeID AND Id !=: strScheduleHeaderId');
            }
            System.debug(LoggingLevel.WARN, 'lstToCheckId in validation method :' + lstToCheckId);
            if(lstToCheckId != null && lstToCheckId.size() > 0){
                isValidate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG085,''));
                return;
            }
            //------------------------------- Validation for the Schedules------------------------------------------
            if(lstSchedules != null && lstSchedules.size()>0){  
                System.debug(LoggingLevel.WARN, 'lstSchedules in validation method :' + lstSchedules);
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules){
                    if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c != System.label.COMM002_TAG005){
                        if(configdata.SVMXC__Run_Type__c == System.label.COMM002_TAG005 || configdata.SVMXC__Run_Type__c == null || configdata.SVMXC__Run_Type__c == '' ){
                            isValidate=false;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.CONF039_TAG008));
                            return;
                        }
                        if(configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=System.label.COMM002_TAG005){
                            if(configdata.SVMXC__Run_Type__c.equals('Day of Week')){
                                if(configdata.SVMXC__Schedule_Days__c == null || configdata.SVMXC__Schedule_Days__c == '' || configdata.SVMXC__Schedule_Days__c == System.label.COMM002_TAG005){
                                    isValidate=false;
                                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.CONF039_TAG008));
                                    return;
                                }
                            }
                            if(configdata.SVMXC__Run_Type__c.equals('Date of Month')){
                                if(configdata.SVMXC__Day_to_Run__c == null || configdata.SVMXC__Day_to_Run__c == '' || configdata.SVMXC__Day_to_Run__c == System.label.COMM002_TAG005){
                                    isValidate=false;
                                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.CONF039_TAG008));
                                    return;
                                }
                            }
                        }
                    }
                }
            }
            
            
            if(setSelectedIds == null || setSelectedIds.size() == 0){
                if(listScheduleServices == null || listScheduleServices.size() == 0){
                    isValidate=false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.CONF039_TAG012));
                    return;
                }
            } 
            
            
            if(listScheduleServices != null && listScheduleServices.size() > 0){
                for(wrapperConfigData serviceToValidate : listScheduleServices){
                    if(serviceToValidate.scheduleService.Batch_Size__c != null && serviceToValidate.scheduleService.Batch_Size__c < 1){
                        isValidate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,getTAG06()));
                        return;
                         
                    }
                    else if(serviceToValidate.scheduleService.Object_Name__c == '' || serviceToValidate.scheduleService.Object_Name__c == 'SVMX.NONE'){
                        isValidate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG01()));
                        return;    
                    }
                    else if(serviceToValidate.selectedExpression == '' || serviceToValidate.selectedExpression == 'SVMX.NONE'){
                        isValidate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG02()));
                        return;    
                    }
                    else if(serviceToValidate.scheduleService.Class_Name__c == '' || serviceToValidate.scheduleService.Class_Name__c == null ){
                        isValidate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,getTAG03()));
                        return;    
                    }
                    else if(serviceToValidate.scheduleService.Class_Name__c != '' || serviceToValidate.scheduleService.Class_Name__c != null ){
                        Integer classCount = 0;
                        
                        // First Check if the current edited/created scheduled SFM service is using same class name
                        for(wrapperConfigData serviceToValidateClassName : listScheduleServices){
                            if(serviceToValidateClassName.scheduleService.Class_Name__c.equalsIgnoreCase(serviceToValidate.scheduleService.Class_Name__c)){
                                classCount++; 
                            }
                        } 
                        
                        if(classCount > 1){
                            isValidate=false;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, serviceToValidate.scheduleService.Class_Name__c + ' '+ getTAG05()));
                            return;
                        } 
                    }
                }
            }
            Set<String> setAllRunAtRec = new Set<String>();
            for(SVMXC__ServiceMax_Config_Data__c ScheduleRec :lstSchedules){
                if(ScheduleRec.SVMXC__Run_Type__c.equals('Day of Week')){   
                    list<string> strFinal = new list<string>();
                    if(ScheduleRec.SVMXC__Schedule_Days__c != null)
                        strFinal = ScheduleRec.SVMXC__Schedule_Days__c.split(';',7);
                    for(string str: strFinal){
                        if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + str)){
                            isValidate=false;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.COMM001_TAG088 + ' ' + ScheduleRec.SVMXC__Run_At__c));
                            return;
                        } 
                        else
                            setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + str);
                    }
                }
                else{
                    if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + ScheduleRec.SVMXC__Day_to_Run__c)){
                        isValidate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, System.label.COMM001_TAG088 + ' ' + ScheduleRec.SVMXC__Run_At__c));
                        return;
                    }
                    else
                        setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + ScheduleRec.SVMXC__Day_to_Run__c);
                }
            }
        }catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
    
    public string getTAG01(){return System.label.CONF039_TAG042;} // Please enter Object Name
    public string getTAG02(){return System.label.CONF039_TAG043;} // Please enter qualification criteria
    public string getTAG03(){return System.label.CONF039_TAG044;} // Please enter Service/ Class name
    public string getTAG04(){return System.label.CONF039_TAG045;} // Please select valid service class
    public string getTAG05(){return System.label.CONF039_TAG051;} // Please select valid service class
    public string getTAG06(){return System.label.CONF039_TAG057;} // Please select valid service class
    //public string getTAG06(){return 'class is configured in Scheduled SFM Process ';} // Please select valid service class
}