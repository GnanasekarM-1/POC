public with sharing class CONF_SetupServiceFlowWizard 
{
    public String selectedSequence;
    public String SVMXAction;
    public String Mode = '';
    public String ObjectName;
    public String SVMXRecId;
    public String ObjLabel;
    
    public Boolean isSFWCriteriaNew = false;
    public Boolean renderTab1ExprBlock {get; set;}
    public Boolean renderTab2ExprBlock {get; set;}
    public Boolean renderPanelWizrdStep {get; set;}
    public Boolean DisableActnNew = false;
    public Boolean DisableActnDelete = false;
    public Boolean DisableActnSequence = false;
    public Boolean DisableEditCriteriaLnk = false;
    
    public Map<String,String> AvailProfMap = new Map<String,String>();
    public Map<String, String> AllGrpProfilesMap = new Map<String, String>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    public List<SvmxActionWrapper> SvmxActionWrapperLst = new List<SvmxActionWrapper>();
    
    public List<SelectOption> SFWActn_ActionFieldTypeOptns = new List<SelectOption>();
    public List<SelectOption> modeOfExecutionOptns = new List<SelectOption>();
    List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    
    // OBJECTS
    //3Apr2017:Defect39727:Sourabh:View State issue:marked as transient
    transient public ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();//manish
    public SvmxActionWrapper editActionWrapperObject;
    //public COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);//manish
    //BAC-4763
    public String isHTMLorFlash {get; set;}
    // OBJECTS
    
    //GETTER SETTER
    public String getSVMXRecId(){ return SVMXRecId;}
    public String getselectedSequence(){return selectedSequence;}
    public void setselectedSequence(String val){this.selectedSequence = val;}
    public String getObjectName(){ return ObjectName;}
    public String getMode(){ return Mode;}
    public Boolean getDisableEditCriteriaLnk(){ return DisableEditCriteriaLnk;}
    public boolean getDisableActnNew(){ return DisableActnNew;}
    public boolean getDisableActnDelete(){ return DisableActnDelete;}
    public boolean getDisableActnSequence(){ return DisableActnSequence;}
    public List<SelectOption> getSFWActn_ActionFieldTypeOptns() { return SFWActn_ActionFieldTypeOptns;}
    public List<SelectOption> getmodeOfExecutionOptns(){ return modeOfExecutionOptns;}
    public SvmxActionWrapper geteditActionWrapperObject(){return editActionWrapperObject;}
    public void seteditActionWrapperObject(SvmxActionWrapper obj){editActionWrapperObject = obj;}
    public List<SvmxActionWrapper> getSvmxActionWrapperLst(){ return SvmxActionWrapperLst;}
    public void setSvmxActionWrapperLst(List<SvmxActionWrapper> val){ SvmxActionWrapperLst = val;}
    public List<SelectOption> getObjectsWithSFW(){ return sourceObjectsOptns;}
    //GETTER SETTER

    //Record Type
    RecordType RtypeSVMX_SFW_Action;
    RecordType Rtype_SFWHeader;
    RecordType Rtype_SVMXSFWPermission;
    Recordtype Rtype_SFWLayout; //This is added as part of BAC-3259
    //Record Type
    

    //Variable to hold the Setting value for Checklist, initially it will be set as false.
    public boolean checklistSettingEnabled = false; 

    // Wrapper Class For Expression
    public class ExpressionWrapper
    {
        public Boolean RenderAddButton = false;
        public Boolean RenderDelButton = false;
        public SVMXC__ServiceMax_Processes__c ExpHeader = new SVMXC__ServiceMax_Processes__c();
        public List<SVMXC__ServiceMax_Config_Data__c> ExpDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        public SVMXC.SFM_WrapperDef.SFM_Response expressionSaveResponse = new SVMXC.SFM_WrapperDef.SFM_Response();
        /* Getter Setters - Starts here */
        public SVMXC__ServiceMax_Processes__c getExpHeader(){ return ExpHeader;}
        public void setExpHeader(SVMXC__ServiceMax_Processes__c ExpHdr){ this.ExpHeader = ExpHdr;}
        public List<SVMXC__ServiceMax_Config_Data__c> getExpDetailLst(){ return ExpDetailLst;}
        public void setExpDetailLst(List<SVMXC__ServiceMax_Config_Data__c> ExpDtlLst){ this.ExpDetailLst = ExpDtlLst;}
        public Boolean getRenderAddButton(){ return RenderAddButton;}
        public void setRenderAddButton(Boolean val){ this.RenderAddButton = val;}
        public Boolean getRenderDelButton(){ return RenderDelButton;}
        public void setRenderDelButton(Boolean val1){ this.RenderDelButton = val1;}
        /* Getter Setters - Ends here */
        // Constructor
        public ExpressionWrapper(SVMXC__ServiceMax_Processes__c HeaderExpression, List<SVMXC__ServiceMax_Config_Data__c> DetailExpressionLst, Boolean DisplayAddButton, Boolean DisplayDelButton)
        {
            this.ExpHeader = HeaderExpression;
            this.ExpDetailLst = DetailExpressionLst;
            this.RenderAddButton = DisplayAddButton;
            this.RenderDelButton = DisplayDelButton;
        }
    }
    //Wrapper Class For SFW Steps
    public class SvmxActionWrapper
    {
        //Start : BAC-4763
        public String selectedActionTypeURL;
        public String getSelectedActionTypeURL(){ return selectedActionTypeURL;}
        public void setSelectedActionTypeURL(String actnTypeURL){ selectedActionType = actnTypeURL;}
        //End :BAC-4763
        
        public boolean disableModeOfExec {get; set;}
        public boolean disableHandover {get; set;}
        public boolean isWebService{get; set;}
        public boolean isActnTypSFMOutputDoc{get; set;}
        public boolean isActnTypChecklist{get;set;}
        public boolean isSFWActionCriteraNew = false;
        public boolean displayEditButton{get; set;}
        public String stepName          {get; set;}
        public String stepID            {get; set;}
        public String SelectedActionType;
        public String SelectedCriteriaToEnable;
        public String strTranslatedActionType {set; get;}//added for resolving defect 010398
        public SVMXC__ServiceMax_Processes__c SvmxActionRec = new SVMXC__ServiceMax_Processes__c();
        public List<SelectOption> slctLstStepType = new List<SelectOption>();
        public ExpressionWrapper expHeaderDetailRec;
        //Getter Setter
        public SVMXC__ServiceMax_Processes__c getSvmxActionRec(){ return SvmxActionRec;}
        public void setSvmxActionRec(SVMXC__ServiceMax_Processes__c c){ SvmxActionRec = c;}
        public List<SelectOption> getslctLstStepType(){  return slctLstStepType;}
        public String getSelectedActionType(){ return SelectedActionType;}
        public void setSelectedActionType(String actnType){ SelectedActionType = actnType;}
        public String getSelectedCriteriaToEnable(){ return SelectedCriteriaToEnable;}
        public void setSelectedCriteriaToEnable(String cri){ SelectedCriteriaToEnable = cri;}
        public ExpressionWrapper getexpHeaderDetailRec(){ return expHeaderDetailRec;}
        public void setexpHeaderDetailRec(ExpressionWrapper expHdrDtl){ expHeaderDetailRec = expHdrDtl;}
        //constructor
        public SvmxActionWrapper(SVMXC__ServiceMax_Processes__c ActionRec, String SelActType, String SelCriToEnble, ExpressionWrapper expHdrDtlRec, String strTranslatedActionType,String actnTypeURL)
        {
            this.strTranslatedActionType = strTranslatedActionType;
            if(ActionRec.SVMXC__Mode_Of_Execution__c == null || ActionRec.SVMXC__Mode_Of_Execution__c.length() == 0)
                ActionRec.SVMXC__Mode_Of_Execution__c = 'Interactive'; 
            SvmxActionRec = ActionRec;
            if(SelActType !=null && SelActType.length()>0)
                SelectedActionType = SelActType;
            else
                SelectedActionType = 'ServiceMax_None';
            
            if(ActionRec.SVMXC__Action_Type__c != null && ActionRec.SVMXC__Action_Type__c == 'OUTPUT_DOCUMENT')
                isActnTypSFMOutputDoc = false;
            else    
                isActnTypSFMOutputDoc = true;

            if(ActionRec.SVMXC__Action_Type__c != null && ActionRec.SVMXC__Action_Type__c == 'CHECKLIST')
                isActnTypChecklist = false;
            else    
                isActnTypChecklist = true;
            

            isWebService = true;
            SelectedCriteriaToEnable = SelCriToEnble;
            if(expHdrDtlRec != null)
                expHeaderDetailRec = expHdrDtlRec;
            if(expHdrDtlRec != NULL && expHdrDtlRec.ExpHeader != NULL && expHdrDtlRec.ExpHeader.SVMXC__ProcessID__c != NULL)
            {
                displayEditButton = true;
            }
            //Start:BAC-4763
            if(actnTypeURL!=null)
            {
                selectedActionTypeURL = actnTypeURL.replaceAll(' ','_');
            }
            else
            {
                selectedActionTypeURL = '';
            }
            //END : BAC-4763
        }
    }

    
    //Map declaration to store Inventory actions, sfm actions and other actions obtained by calling respective methods in SFW_utils
     //Jaysukh below variable marked as transient for view state defect 040618 
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_InvActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SFM_BackgroundExecActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_OtherActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmOutputDocActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_Receipt_DeliveryActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_Pick_ShippingActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_InitiateReturnsActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_FulfillmentProcessActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
    
     transient Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ChecklistActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
    
    Map<String,SVMXC__ServiceMax_Processes__c> Map_AllActionRecs = new Map<String,SVMXC__ServiceMax_Processes__c>(); //transient
    Map<String,String> Map_SFWPermissions = new Map<String,String>();

    //Create a List of permission records
    List<ServiceMax_Config_Data__c> LstSFWPermsnRecs_SelectedSFW = new List<ServiceMax_Config_Data__c>();
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();//new additions
    public CONF_SetupServiceFlowWizard()
    {    
        //Start BAC-4763
        isHTMLorFlash = 'Flash';
        List<String> lstSubModules = new List<String>{'GLOB001','SFM001'};
        SVMXC.COMM_Utils_ManageSettings commUtilSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String,Map<String, String>> svmxSettingMap = new  Map<string,Map<String, String>>();
        Map<String, String> svmxSettingGLOB001 = new  Map<String, String>();
        Map<String, String> svmxSettingSFM001 = new  Map<String, String>();
        svmxSettingMap = commUtilSettings.SVMX_getSettingList(lstSubModules);
        if(svmxSettingMap != null && !svmxSettingMap.isEmpty())
        {
             for(String subModuleId : lstSubModules)
             {
              if('GLOB001'.equals(subModuleId) && svmxSettingGLOB001.isEmpty())
               {
                 svmxSettingGLOB001 = svmxSettingMap.get(subModuleId);
               }
               if('SFM001'.equals(subModuleId) && svmxSettingSFM001.isEmpty())
               {
                 svmxSettingSFM001 = svmxSettingMap.get(subModuleId);
               }
             }
        }
        if(!svmxSettingSFM001.isEmpty())
        {
          if(svmxSettingSFM001.containsKey('SET006'))
           {
            isHTMLorFlash = svmxSettingSFM001.get('SET006');
           }
           
        }
        if(!svmxSettingGLOB001.isEmpty())
        {
            if(svmxSettingGLOB001.containsKey('GBL014') && Boolean.valueOf(svmxSettingGLOB001.get('GBL014')) == true)
                Enable_Ship_Ret_InitiateRet = true;
            if(svmxSettingGLOB001.containsKey('GBL029') && Boolean.valueOf(svmxSettingGLOB001.get('GBL029')) == true)    
                checklistSettingEnabled = true;
        }
        //End : BAC-4763
        //commented BAC-4763
       
        /*
        SVMXC.COMM_Utils_ManageSettings commUtilSettings = new SVMXC.COMM_Utils_ManageSettings();//manish
        Map<String, String> svmxSettingList = new  Map<String, String>();//manish
        svmxSettingList = commUtilSettings.SVMX_getSettingList('GLOB001');
        */
        DisableActnNew = false;
        DisableActnDelete = false;
        DisableActnSequence = false;
        renderPanelWizrdStep = false;
        
        SVMXRecId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        SVMXAction = System.currentPageReference().getParameters().get('SVMX_Action');
        ObjectName = System.currentPageReference().getParameters().get('SVMX_ObjectName');
        //new additions
       
       /* if(svmxSettingList != null){ 
            if(svmxSettingList.containsKey('GBL014') && Boolean.valueOf(svmxSettingList.get('GBL014')) == true)
                Enable_Ship_Ret_InitiateRet = true;
            if(svmxSettingList.containsKey('GBL029') && Boolean.valueOf(svmxSettingList.get('GBL029')) == true)    
                checklistSettingEnabled = true;
        }*/
       

        //Added for consuming less SOQL for fetching record type record as part of BAC-3259
        List<Recordtype> lstRecordType = [SELECT Id, Name, SobjectType FROM Recordtype WHERE (SobjectType=:'SVMXC__ServiceMax_Processes__c' OR SobjectType=:'SVMXC__ServiceMax_Config_Data__c')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(Recordtype objRType : lstRecordType){
            if(objRType.Name.equalsIgnoreCase('SVMX Rule') && objRType.SobjectType.equalsIgnoreCase('SVMXC__ServiceMax_Processes__c')){
                ExpressionHeader_Rtype = objRType;
            }
            else if(objRType.Name.equalsIgnoreCase('Expressions') && objRType.SobjectType.equalsIgnoreCase('SVMXC__ServiceMax_Config_Data__c')){
                ExpressionsDetail_Rtype = objRType;
            }
            else if(objRType.Name.equalsIgnoreCase('Wizard') && objRType.SobjectType.equalsIgnoreCase('SVMXC__ServiceMax_Processes__c')){
                Rtype_SFWHeader = objRType;
            }
            else if(objRType.Name.equalsIgnoreCase('Wizard Step') && objRType.SobjectType.equalsIgnoreCase('SVMXC__ServiceMax_Processes__c')){
                RtypeSVMX_SFW_Action = objRType;
            }
            else if(objRType.Name.equalsIgnoreCase('Wizard Access') && objRType.SobjectType.equalsIgnoreCase('SVMXC__ServiceMax_Config_Data__c')){
                Rtype_SVMXSFWPermission = objRType;
            }
            else if(objRType.Name.equalsIgnoreCase('Wizard Layout') && objRType.SobjectType.equalsIgnoreCase('SVMXC__ServiceMax_Config_Data__c')){
                Rtype_SFWLayout = objRType;
            }
        }
        //This is commented to consume less SOQL as part of BAC-3259
        //ExpressionHeader_Rtype = [select Id from RecordType where Name=:'SVMX Rule' and SobjectType=:'SVMXC__ServiceMax_Processes__c' Limit 1];
        //ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions' and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        /* populate operand picklist values */
        OperatorSelectLst = new List<SelectOption>();
        OperatorSelectLst.add(new SelectOption('SVMX.NONE','--'+getTag041()+'--'));
        OperatorSelectLst.add(new SelectOption('eq',getTAG060()));  //'Equals'));
        OperatorSelectLst.add(new SelectOption('ne',getTAG061())); //'Not Equal'));
        OperatorSelectLst.add(new SelectOption('gt',getTAG062())); //'Greater Than'));
        OperatorSelectLst.add(new SelectOption('ge',getTAG063())); //'Greater or Equal To'));
        OperatorSelectLst.add(new SelectOption('lt',getTAG064())); //'Less Than'));
        OperatorSelectLst.add(new SelectOption('le',getTAG065())); //'Less or Equal To'));
        OperatorSelectLst.add(new SelectOption('starts',getTAG066())); //'Starts With'));
        OperatorSelectLst.add(new SelectOption('contains',getTAG067())); //'Contains'));
        OperatorSelectLst.add(new SelectOption('notcontain',getTAG068())); //'Does Not Contain'));
        OperatorSelectLst.add(new SelectOption('in',getTAG069())); //'Includes'));
        OperatorSelectLst.add(new SelectOption('notin',getTAG070())); //'Excludes'));
        OperatorSelectLst.add(new SelectOption('isnull',getTAG071())); //'Is Null'));
        OperatorSelectLst.add(new SelectOption('isnotnull',getTAG072())); //'Is Not Null'));
        /* populate operand picklist values */
        sourceObjectsOptns = new List<SelectOption>();
        sourceObjectsOptns.add(new Selectoption('None',getTAG041()));
        COMM_Utils commUtils = new COMM_Utils();
        Map<String,String> Map_ObjName_Label = new Map<String,String>();
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();//manish
        //allObjs = Schema.getGlobalDescribe();
        for(String key: allObjs.keySet())
        {
            Schema.SObjectType objT = allObjs.get(key) ;
            String CurrentObjName = objT.getDescribe().getName();
            if(!((CurrentObjName.toUpperCase()).endswith('SHARE')) && !((CurrentObjName.toUpperCase()).endswith('FEED')) && !((CurrentObjName.toUpperCase()).endswith('HISTORY')) && objT.getDescribe().isAccessible())
                Map_ObjName_Label.put(CurrentObjName,objT.getDescribe().getLabel());
        }
        Boolean IsEnterpriseLicense;
        try
        {
            //This is commented as part of BAC-3259 because this is not used anywhere
            //IsEnterpriseLicense = commUtils.SVMX_isEnterpriseLicense(); 
        }
        catch(exception ex)
        {
            
        }

        //Map declaration to store Inventory actions, sfm actions and other actions obtained by calling respective methods in SFW_utils
        //Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_InvActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        //Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        //Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_SfmOutputDocActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        //Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_OtherActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        
        //Methods are called below
        //ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();//manish
        Map_InvActions = SFWUtils.SVMX_GetInventoryActions('All');
        Map_SfmActions = SFWUtils.SVMX_GetSFMActions('All');
        Map_SfmOutputDocActions = SFWUtils.SVMX_GetSFMOutputDocActions('All');
        Map_OtherActions = SFWUtils.SVMX_GetOtherActions('All');
        Map_ChecklistActions = SFWUtils.SVMX_GetChecklistActions('All');

        //This is commented to consume less SOQL as part of BAC-3259
        //Map_Receipt_DeliveryActions = SFWUtils.SVMX_GetReceive_DeliveryActions('');
        //Map_Pick_ShippingActions = SFWUtils.SVMX_GetPicking_ShippingActions('');
        //Map_InitiateReturnsActions = SFWUtils.SVMX_GetInitiateReturnActions('');
        //Map_FulfillmentProcessActions = SFWUtils.SVMX_GetFulfillmentProcessActions('');

        //---Start----Added for consuming less SOQL for fetching record type record as part of BAC-3259
        Map_Receipt_DeliveryActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map_Pick_ShippingActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map_InitiateReturnsActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map_FulfillmentProcessActions = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        List<SVMXC__ServiceMax_Processes__c> lstAPLProcess = [SELECT Id, RecordType.Name, SVMXC__Name__c, SVMXC__Custom_Action_Type__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Receiving Process' OR RecordType.Name = 'Shipping Process' OR RecordType.Name = 'Initiate Return Process' OR RecordType.Name = 'Fulfillment Process')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Processes__c objProcess: lstAPLProcess){
            if(objProcess.RecordType.Name.equalsIgnoreCase('Receiving Process')){
                if(!Map_Receipt_DeliveryActions.containsKey('SVMXC__RMA_Shipment_Order__c'))
                    Map_Receipt_DeliveryActions.put('SVMXC__RMA_Shipment_Order__c', new List<SVMXC__ServiceMax_Processes__c>());
                Map_Receipt_DeliveryActions.get('SVMXC__RMA_Shipment_Order__c').add(objProcess);
            }
            else if(objProcess.RecordType.Name.equalsIgnoreCase('Shipping Process')){
                if(!Map_Pick_ShippingActions.containsKey('SVMXC__RMA_Shipment_Order__c'))
                    Map_Pick_ShippingActions.put('SVMXC__RMA_Shipment_Order__c', new List<SVMXC__ServiceMax_Processes__c>());
                Map_Pick_ShippingActions.get('SVMXC__RMA_Shipment_Order__c').add(objProcess);
            }  
            else if(objProcess.RecordType.Name.equalsIgnoreCase('Initiate Return Process')){
                if(!Map_InitiateReturnsActions.containsKey('Case'))
                    Map_InitiateReturnsActions.put('Case', new List<SVMXC__ServiceMax_Processes__c>());
                Map_InitiateReturnsActions.get('Case').add(objProcess);
            }
            else if(objProcess.RecordType.Name.equalsIgnoreCase('Fulfillment Process')){
                if(!Map_FulfillmentProcessActions.containsKey('SVMXC__RMA_Shipment_Order__c'))
                    Map_FulfillmentProcessActions.put('SVMXC__RMA_Shipment_Order__c', new List<SVMXC__ServiceMax_Processes__c>());
                Map_FulfillmentProcessActions.get('SVMXC__RMA_Shipment_Order__c').add(objProcess);
            }
        }
        //---End----Added for consuming less SOQL for fetching record type record as part of BAC-3259
        
        for(String ObjName: Map_ObjName_Label.keyset())
        {   
            system.debug(ObjName + '----ObjName');
            if( ObjName != null && (Map_InvActions.ContainsKey(ObjName) || Map_SfmActions.ContainsKey(ObjName) || Map_SfmOutputDocActions.ContainsKey(ObjName) || Map_OtherActions.ContainsKey(ObjName)))
                sourceObjectsOptns.add(new SelectOption(ObjName, Map_ObjName_Label.get(ObjName)));
        }
        //displayStdNCustomSFWs();
        sourceObjectsOptns = sortingSelectOption(sourceObjectsOptns);
        
        //new additions end here
        //This is commented to consume less SOQL as part of BAC-3259
        //Rtype_SFWHeader = [Select Id, Name from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        //RtypeSVMX_SFW_Action = [Select Id, Name from RecordType where Name = 'Wizard Step' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        //Rtype_SVMXSFWPermission = [Select Id, Name from RecordType where Name = 'Wizard Access' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        
        if (SVMXRecId != null && SVMXRecId != '')
        {
            List<SVMXC__ServiceMax_Processes__c> SFWRecLstFromId = new List<SVMXC__ServiceMax_Processes__c>();
            SFWRecLstFromId = Database.query('Select Id, SVMXC__Select__c, SVMXC__Dispatch_Process_Status__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Active__c, SVMXC__Description__c, LastModifiedById, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__IsGlobal__c, SVMXC__IsStandard__c,SVMXC__Mode_Of_Execution__c,SVMXC__Handover__c,SVMXC__Purpose__c, SVMXC__Object_key_prefix__c from SVMXC__ServiceMax_Processes__c where recordtype.Name = \'Wizard\' and Id = :SVMXRecId ');
            if( SFWRecLstFromId != null && SFWRecLstFromId.size() > 0)
                SFWRec = SFWRecLstFromId[0];
            If( SFWRec != null )
            {
                ObjectName = SFWRec.SVMXC__Source_Object_Name__c;
                if( ObjectName != null && ObjectName != '' )
                {
                    String APIName = ObjName_util.getOriginalAPIName(ObjectName, allObjs);
                    if( APIName != null && allObjs.get(APIName) != null ) 
                    {
                        //populate the field list for the selected object
                        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);//manish
                        Hdrfldlist.clear();
                        Hdrfldlist.add(new SelectOption('SVMX.NONE',getTag041()));
                        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
                        DispMethods.RetriveField(ObjectName, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
                    }
                }

                if( SFWRec.SVMXC__IsStandard__c && SVMXAction != 'Clone' )
                    Mode = 'View';
                if(SFWRec.SVMXC__Submodule__c != null)
                    selectedCriteria = SFWRec.SVMXC__Submodule__c;
                if(selectedCriteria == null || selectedCriteria == '')
                    DisableEditCriteriaLnk = true;
            }
            selectedSvmxSFW = SVMXRecId;
            if ( Mode != 'View' && SVMXAction == 'Clone')
                Mode = 'Clone';
            else if( Mode != 'View' )
                Mode = 'Edit';
        }
        else
            Mode = 'New';
        if( Mode == 'View' || Mode == 'Edit' )
            disableSourceObjField = true;
        else
            disableSourceObjField = false;

        if( Mode == 'View' )
            disableOnView = true;
        else
            disableOnView = false;
        if( Mode == 'New')
        {
            sfwRec.SVMXC__Active__c = true;
            DisableEditCriteriaLnk = true;
      //for filtering
      if(ObjectName != null && ObjectName.length() != 0 && Map_ObjName_Label.containsKey(ObjectName))
        sfwRec.Source_Object_Name__c = ObjectName;
        }
        //expression header is populated in below method
        rerenderExpressionsblock();


            Integer temp_HighestSeqNum = 0;
            if( ( Mode != 'New' ) && SVMXRecId != null && SVMXRecId != '' )//Mode == 'Edit' || Mode == 'Clone'
            {
                //BAC- 4763 :added purpose field in below query 
                SFWActionsLst = database.query('Select SVMXC__Select__c,SVMXC__Process__r.SVMXC__Purpose__c,SVMXC__Active__c, SVMXC__Sequence__c, SVMXC__Module__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c,  SVMXC__Submodule__c, SVMXC__IsStandard__c,SVMXC__Mode_Of_Execution__c,SVMXC__Expertise_Match_Enabled__c,SVMXC__Purpose__c,SVMXC__Handover__c,  SVMXC__Select_Template_At_Runtime__c,  SVMXC__Confirmation_Message__c From SVMXC__ServiceMax_Processes__c Where RecordType.Name = \'Wizard Step\' And SVMXC__Module__c = :SVMXRecId Order By SVMXC__Sequence__c ASC');
                SFWActionsSEQLst.addall(SFWActionsLst);
                renderActionPicklistvalues();
            }
            /* Populate the SFW action records - Starts here */

            for(SVMXC__ServiceMax_Processes__c ActionRec: SFWActionsLst)
            {   
                //ExpressionWrapper expwrpr = new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);
                ExpressionWrapper expwrpr = null;
                if(ActionRec.SVMXC__Submodule__c != null)
                    expwrpr = new ExpressionWrapper(MapNamedExpressionRecords.get(ActionRec.SVMXC__Submodule__c),MapExpressionHdrDetailsLst.get(ActionRec.SVMXC__Submodule__c), true, false);
                    temp_HighestSeqNum = temp_HighestSeqNum + 1;
                    ActionRec.SVMXC__Sequence__c = temp_HighestSeqNum;
                //--------added by Manish----added for resolving defect 010398
                String tempTranslatedActionType = '';
                tempTranslatedActionType = getTranslatedCustomLabel(ActionRec);
                //------added by Manish

                SvmxActionWrapper actnWrapper = new SvmxActionWrapper(ActionRec, ActionRec.SVMXC__Process__c, ActionRec.SVMXC__Submodule__c, expwrpr, tempTranslatedActionType,ActionRec.SVMXC__Process__r.SVMXC__Purpose__c);
                
                if(expwrpr == null)
                    actnWrapper.displayEditButton = false;
                else
                    actnWrapper.displayEditButton = true;
                List<SelectOption> tempLstOptns = new  List<SelectOption>();
                //actnWrapper.slctLstStepType.add(new SelectOption('ServiceMax_None',getTAG041()));
                /*populate Actions Picklist Values - starts here*/
                if(actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'SFM' && slctLstSFM != null && slctLstSFM.size() > 0)
                    tempLstOptns.addAll(slctLstSFM);
                    
                if(actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'OUTPUT_DOCUMENT' && slctLstOutPutDoc != null && slctLstOutPutDoc.size() > 0)
                    tempLstOptns.addAll(slctLstOutPutDoc);
                if(actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'INVENTORY' && slctLstINVENTORY != null && slctLstINVENTORY.size() > 0)
                    tempLstOptns.addAll(slctLstINVENTORY);
                if(actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'OTHERS' && slctLstOthers != null && slctLstOthers.size() > 0)
                    tempLstOptns.addAll(slctLstOthers);
                if((actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'RECEIPT' || actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'DELIVERY') && slctLstReceipt_Delivery != null && slctLstReceipt_Delivery.size() > 0)
                    tempLstOptns.addAll(slctLstReceipt_Delivery);
                if((actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'SHIP' || actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'PICK_MOVE') && slctLstShip_Pick != null && slctLstShip_Pick.size() > 0)
                    tempLstOptns.addAll(slctLstShip_Pick);
                if((actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'BACKGROUND_EXEC') && slctLstBackGroundExecution != null && slctLstBackGroundExecution.size() > 0)
                    tempLstOptns.addAll(slctLstBackGroundExecution);
                if(actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'INITIATE_RETURN' && slctLstInitiateReturn != null && slctLstInitiateReturn.size() > 0)
                    tempLstOptns.addAll(slctLstInitiateReturn);
                /***************Inserted on 7th Feb by Shashank*********************/   
                //Reason:-Wizard step was not retaining the value for Fulfillment Step type 
                if(actnWrapper.SvmxActionRec.SVMXC__Action_Type__c == 'FULFILLMENT' && slctLstFulfillment != null && slctLstFulfillment.size() > 0)
                    tempLstOptns.addAll(slctLstFulfillment); 
                /*******************************************************************/
                /*populate Actions Picklist Values - ends here*/
                //code for sorting pick list values
                actnWrapper.slctLstStepType = new List<SelectOption>();
                actnWrapper.slctLstStepType.add(new SelectOption('ServiceMax_None',getTAG041()));
                if(tempLstOptns != null &&  tempLstOptns.size() > 0)
                {
                    tempLstOptns = sortingSelectOption(tempLstOptns);
                    actnWrapper.slctLstStepType.addAll(tempLstOptns);
                }
                if(Map_AllActionRecs.get(actnWrapper.SelectedActionType) != null){
                    actnWrapper.stepID =  Map_AllActionRecs.get(actnWrapper.SelectedActionType).SVMXC__ProcessID__c;
                    actnWrapper.stepName = Map_AllActionRecs.get(actnWrapper.SelectedActionType).SVMXC__Name__c;
                }

                //Only if the Checklist setting is enabled, the checklist wizard type is added to the wrapper list
                if(ActionRec.SVMXC__Action_Type__c != 'CHECKLIST')
                    SvmxActionWrapperLst.add(actnWrapper);
                else if(checklistSettingEnabled)
                    SvmxActionWrapperLst.add(actnWrapper);
                        
            }
            // Jaysukh:added for view state defect 040618
            MapNamedExpressionRecords.clear();
            MapExpressionHdrDetailsLst.clear();
            /*********Modification Start - by Shashank****************/
            //Date:-19th Dec 2011
            //Description:-this for loop is added to check the conditions on loading of the page and accordingly making the picklist enable or disable
            for(SvmxActionWrapper ActionWrprRec : SvmxActionWrapperLst)
            {
                if(ActionWrprRec != null)
                {
                    //added this condition by shashank on 14th dec 2011
                    if((ActionWrprRec.SvmxActionRec != null && ActionWrprRec.SvmxActionRec.SVMXC__Action_Type__c == 'SFM' ) && (Map_AllActionRecs != null && Map_AllActionRecs.containskey(ActionWrprRec.SelectedActionType) && (Map_AllActionRecs.get(ActionWrprRec.SelectedActionType).SVMXC__Purpose__c == 'STANDALONE CREATE' || Map_AllActionRecs.get(ActionWrprRec.SelectedActionType).SVMXC__Purpose__c == 'SOURCE TO TARGET ALL' || Map_AllActionRecs.get(ActionWrprRec.SelectedActionType).SVMXC__Purpose__c == 'SOURCE TO TARGET CHILD' || Map_AllActionRecs.get(ActionWrprRec.SelectedActionType).SVMXC__Purpose__c == 'STANDALONE EDIT')))
                        ActionWrprRec.disableModeOfExec = false;
                    else
                        ActionWrprRec.disableModeOfExec = true;
                        
                    if(ActionWrprRec.SvmxActionRec != null && (ActionWrprRec.SvmxActionRec.SVMXC__Action_Type__c == 'INVENTORY' || ActionWrprRec.SvmxActionRec.SVMXC__Action_Type__c == 'OUTPUT_DOCUMENT' || ActionWrprRec.SvmxActionRec.SVMXC__Action_Type__c == 'CHECKLIST') )
                        ActionWrprRec.disableHandover = true;
                    else
                        ActionWrprRec.disableHandover = false;      
                }
                 if(Map_AllActionRecs.containsKey(ActionWrprRec.SelectedActionType) && Map_AllActionRecs.get(ActionWrprRec.SelectedActionType) != null)
                    {
                        if(Map_AllActionRecs.get(ActionWrprRec.SelectedActionType).SVMXC__Custom_Action_Type__c == 'Web-Service')
                            ActionWrprRec.isWebService = false;
                        else
                            ActionWrprRec.isWebService = true;
                    }
                    else
                    ActionWrprRec.isWebService = true;
            }
            /*********Modification End - by Shashank****************/
            
            //Populate Criteria to enable picklist in manage actions tab
            CriteriaToEnableOptns = ShowNHideOptns; //Criteria to enable picklist values are same as ShowNhide options in tab 1
            
            if( SFWActionsLst == null || SFWActionsLst.size() == 0 )
            {
                DisableActnDelete = true;
                DisableActnSequence = true;
            }

        availableSFWOptions.add(New SelectOption('ServiceMax_None',getTag041()));
        List<SVMXC__ServiceMax_Processes__c> AllSFWRecs = new List<SVMXC__ServiceMax_Processes__c>();
        if( SVMXRecId != null && SVMXRecId != '' )
            AllSFWRecs = Database.query('Select SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Process__c From ServiceMax_Processes__c Where recordtype.Name = \'Wizard\' AND ID != :SVMXRecId');
        else
            AllSFWRecs = Database.query('Select SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Process__c From ServiceMax_Processes__c Where recordtype.Name = \'Wizard\'');
        
        for(ServiceMax_Processes__c CurrentSFWRec: AllSFWRecs)
        {
            availableSFWOptions.add(new SelectOption(CurrentSFWRec.Id, CurrentSFWRec.SVMXC__Name__c));
        }

        //Query for all group profiles present in database
        List<ServiceMax_Config_Data__c> LstAvailableProfiles = new List<ServiceMax_Config_Data__c>();
        LstAvailableProfiles = Database.query('Select Id, SVMXC__PROFILE_NAME__C, SVMXC__Description__C From ServiceMax_Config_Data__c Where RecordType.Name = \'Configuration Profile\' And SVMXC__CONFIGURATION_TYPE__C = \'Group\'');

        //Loop through resultant group profile records
        for(ServiceMax_Config_Data__c Rec :LstAvailableProfiles)
        {
            AllGrpProfilesMap.put(Rec.Id,Rec.SVMXC__Profile_Name__c);
        }
        AvailProfMap.putall(AllGrpProfilesMap);

        //If the SFW is selected in the picklist of the manage permission tab, then, permission records are queried depending on the selected SFW in the picklist
        if( selectedSvmxSFW != 'ServiceMax_None' && ( Mode == 'Edit' || Mode == 'Clone' ) )
        {
            LstSFWPermsnRecs_SelectedSFW = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :selectedSvmxSFW');
        }
        else if( selectedSvmxSFW == 'ServiceMax_None' && ( Mode == 'Edit' || Mode == 'Clone' ) && SVMXRecId != null && SVMXRecId != '' )
        {
            LstSFWPermsnRecs_SelectedSFW = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :SVMXRecId');
        }
        //Loop through the permission records and populate the Selected ServiceMax Group Profiles picklist on the right
        for(SVMXC__ServiceMax_Config_Data__c PermissionRec: LstSFWPermsnRecs_SelectedSFW)
        {
            if(AllGrpProfilesMap.containsKey(PermissionRec.SVMXC__Access_Configuration_Profile__c))
            {
                if( PermissionRec.SVMXC__Access_Configuration_Profile__c != null && AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c) != null )
                {
                    SelectedProfilesOptns.add(new SelectOption(PermissionRec.SVMXC__Access_Configuration_Profile__c,AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c)));
                    SelectedProfMap.put(PermissionRec.SVMXC__Access_Configuration_Profile__c, AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c));
                    AvailProfMap.remove(PermissionRec.SVMXC__Access_Configuration_Profile__c);
                }
            }
        }
        for(String AvailProf : AvailProfMap.keyset())
        {
            AvailableProfilesOptns.add(new SelectOption(AvailProf, AvailProfMap.get(AvailProf)));
        }
        
        /* On launch section of Manage permissions tab - Ends here */

        SelectedProfilesOptns.clear();
        AvailProfMap.putall(AllGrpProfilesMap);
        
        //If the SFW is selected in the picklist of the manage permission tab, then, permission records are queried depending on the selected SFW in the picklist
        if( SVMXRecId != null && SVMXRecId != '' )//&& Mode == 'Edit' 
        {
            LstSFWPermsnRecs_SelectedSFW = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :SVMXRecId');
        }
        //Loop through the permission records and populate the Selected ServiceMax Group Profiles picklist on the right
        for(SVMXC__ServiceMax_Config_Data__c PermissionRec: LstSFWPermsnRecs_SelectedSFW)
        {
            if(PermissionRec.SVMXC__Access_Configuration_Profile__c != null && AvailProfMap.containsKey(PermissionRec.SVMXC__Access_Configuration_Profile__c) )
            {
                SelectedProfilesOptns.add(new SelectOption(PermissionRec.SVMXC__Access_Configuration_Profile__c , AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c)));
                AvailProfMap.remove(PermissionRec.SVMXC__Access_Configuration_Profile__c);
                SelectedProfMap.put(PermissionRec.SVMXC__Access_Configuration_Profile__c,AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c));
            }
        }
        AvailableProfilesOptns.clear();
        for(String AvailableProfId :AvailProfMap.keyset())
        {
            if(AvailProfMap.get(AvailableProfId) != null)
                AvailableProfilesOptns.add(new SelectOption(AvailableProfId, AvailProfMap.get(AvailableProfId)));
        }
        OnchangeOfcriteriaPicklist();
        /*if(Mode == 'Clone')
        {
            //DisableActnNew = true;
            //DisableActnDelete = true;
            //DisableActnSequence = true;
        }*/
    }
    public void DoQuickSaveIncloneMode()
    {
        if(Mode == 'Clone')
        {
            sfwRec.ProcessID__c += ' '+system.now();
            QuickSave();
        }
    }
    List<SelectOption> slctLstSFM = new List<SelectOption>();
    List<SelectOption> slctLstINVENTORY = new List<SelectOption>();
    List<SelectOption> slctLstOthers = new List<SelectOption>();
    List<SelectOption> slctLstBackGroundExecution = new List<SelectOption>();
    List<SelectOption> slctLstReceipt_Delivery = new List<SelectOption>();
    List<SelectOption> slctLstShip_Pick = new List<SelectOption>();
    List<SelectOption> slctLstInitiateReturn = new List<SelectOption>();
    List<SelectOption> slctLstFulfillment = new List<SelectOption>();
    List<SelectOption> slctLstOutPutDoc = new List<SelectOption>();

    public Boolean populatedPicklistValues = false;
    public Boolean Enable_Ship_Ret_InitiateRet = false;
    //public  SVMXC.COMM_Utils_ManageSettings commUtilSettings = new SVMXC.COMM_Utils_ManageSettings();//manish
    //public Map<String, String> svmxSettingList = new  Map<String, String>();//manish
    public pagereference renderActionPicklistvalues()
    {
        /*SFW action Rec's Action type picklist values are populated as below -Starts here*/
        //Methods are called below
        if(populatedPicklistValues) 
            return null;
        Map_AllActionRecs.clear();
        sfwActn_ActionFieldTypeOptns = new List<SelectOption>();
        if(ObjectName != null)
        {
            ServiceFlowWizard_Utils SFWUtils = new ServiceFlowWizard_Utils();//manish
            populatedPicklistValues = true;
            sfwActn_ActionFieldTypeOptns.add(new SelectOption('ServiceMax_None',getTAG041()));
            if(Map_InvActions != null)
                Map_InvActions.clear();
            Map_InvActions = SFWUtils.SVMX_GetInventoryActions(ObjectName);
            if(Map_SfmActions != null)
                Map_SfmActions.clear();
            Map_SfmActions = SFWUtils.SVMX_GetSFMActions(ObjectName);
            if(Map_SfmOutputDocActions != null)
                Map_SfmOutputDocActions.clear();
            Map_SfmOutputDocActions = SFWUtils.SVMX_GetSFMOutputDocActions(ObjectName);
            if(Map_OtherActions != null)
                Map_OtherActions.clear();
            Map_OtherActions = SFWUtils.SVMX_GetOtherActions(ObjectName);
            if(Map_SFM_BackgroundExecActions != null)
                Map_SFM_BackgroundExecActions.clear();
            Map_SFM_BackgroundExecActions = SFWUtils.SVMX_GetSFMBackgroundActions(ObjectName);
            if(ObjectName == 'SVMXC__RMA_Shipment_Order__c')
            {
                if(Map_Receipt_DeliveryActions != null)
                    Map_Receipt_DeliveryActions.clear();
                Map_Receipt_DeliveryActions = SFWUtils.SVMX_GetReceive_DeliveryActions(ObjectName);
                if(Map_Pick_ShippingActions != NULL)// Added by bala(20-10-2011)
                    Map_Pick_ShippingActions.clear();
                Map_Pick_ShippingActions = SFWUtils.SVMX_GetPicking_ShippingActions(ObjectName);
                if(Map_FulfillmentProcessActions != NULL)// Added by Shyam(Dec-1-2011)
                    Map_FulfillmentProcessActions.clear();
                Map_FulfillmentProcessActions = SFWUtils.SVMX_GetFulfillmentProcessActions(ObjectName);
                
            }
            else if(ObjectName == 'Case')
            {
                if(Map_InitiateReturnsActions != null)
                    Map_InitiateReturnsActions.clear();
                Map_InitiateReturnsActions = SFWUtils.SVMX_GetInitiateReturnActions(ObjectName);
            }
            /* Populate the appropriate seletc lists */
                    
            //SFM actions picklist entries
            if( Map_SfmActions != null && Map_SfmActions.containsKey(ObjectName) && Map_SfmActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('SFM', getTAG073()));
                for(SVMXC__ServiceMax_Processes__c SFMActionRec : Map_SfmActions.get(ObjectName))
                {   
                system.debug(SFMActionRec + '----SFMActionRec');
                    slctLstSFM.add(new SelectOption(SFMActionRec.Id, SFMActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(SFMActionRec.Id,SFMActionRec);
                }
            }
            //Inv actions picklist entries 
            if( Map_InvActions != null && Map_InvActions.containsKey(ObjectName) && Map_InvActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('INVENTORY', getTAG075()));
                for(SVMXC__ServiceMax_Processes__c InvActionRec : Map_InvActions.get(ObjectName))
                {
                    slctLstINVENTORY.add(new SelectOption(InvActionRec.Id,InvActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(InvActionRec.Id,InvActionRec);
                }
            }
            
            //Receipt picklist entries
            if(Enable_Ship_Ret_InitiateRet && ObjectName == 'SVMXC__RMA_Shipment_Order__c' && Map_Receipt_DeliveryActions != null && Map_Receipt_DeliveryActions.containsKey(ObjectName) && Map_Receipt_DeliveryActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('RECEIPT', getTAG077()));
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('DELIVERY', getTAG078()));
                for(SVMXC__ServiceMax_Processes__c OtherActionRec : Map_Receipt_DeliveryActions.get(ObjectName))
                {
                    slctLstReceipt_Delivery.add(new SelectOption(OtherActionRec.Id,OtherActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(OtherActionRec.Id,OtherActionRec);
                }
            }
            //Shipment picklist entries
            if(Enable_Ship_Ret_InitiateRet && ObjectName == 'SVMXC__RMA_Shipment_Order__c' && Map_Pick_ShippingActions != null &&  Map_Pick_ShippingActions.containsKey(ObjectName) && Map_Pick_ShippingActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('PICK_MOVE', getTAG080()));
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('SHIP', getTAG079()));
                for(SVMXC__ServiceMax_Processes__c OtherActionRec : Map_Pick_ShippingActions.get(ObjectName))
                {
                    slctLstShip_Pick.add(new SelectOption(OtherActionRec.Id,OtherActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(OtherActionRec.Id,OtherActionRec);
                }
            }
            //Fulfillment picklist entries
            if(Enable_Ship_Ret_InitiateRet && ObjectName == 'SVMXC__RMA_Shipment_Order__c' && Map_FulfillmentProcessActions != null &&  Map_FulfillmentProcessActions.containsKey(ObjectName) && Map_FulfillmentProcessActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('FULFILLMENT', getTAG083()));
                for(SVMXC__ServiceMax_Processes__c OtherActionRec : Map_FulfillmentProcessActions.get(ObjectName))
                {
                    slctLstFulfillment.add(new SelectOption(OtherActionRec.Id,OtherActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(OtherActionRec.Id,OtherActionRec);
                }
            }
            //Other actions picklist entries
            if( Map_OtherActions != null && Map_OtherActions.containsKey(ObjectName) && Map_OtherActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('OTHERS', getTAG076()));
                for(SVMXC__ServiceMax_Processes__c OtherActionRec : Map_OtherActions.get(ObjectName))
                {
                    slctLstOthers.add(new SelectOption(OtherActionRec.Id,OtherActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(OtherActionRec.Id,OtherActionRec);
                }
            }
            
            if( Map_SfmOutputDocActions != null && Map_SfmOutputDocActions.containsKey(ObjectName) && Map_SfmOutputDocActions.get(ObjectName) != null )
            {
                
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('OUTPUT_DOCUMENT', getTAG095()));
                for(SVMXC__ServiceMax_Processes__c sfmOutputDocActionRec : Map_SfmOutputDocActions.get(ObjectName))
                {
                    slctLstOutPutDoc.add(new SelectOption(sfmOutputDocActionRec.Id,sfmOutputDocActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(sfmOutputDocActionRec.Id,sfmOutputDocActionRec);
                }
            }

            if(Enable_Ship_Ret_InitiateRet && ObjectName == 'Case' && Map_InitiateReturnsActions != null && Map_InitiateReturnsActions.containsKey(ObjectName) && Map_InitiateReturnsActions.get(ObjectName) != null )
            {
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('INITIATE_RETURN', getTAG081()));
                for(SVMXC__ServiceMax_Processes__c OtherActionRec : Map_InitiateReturnsActions.get(ObjectName))
                {
                    slctLstInitiateReturn.add(new SelectOption(OtherActionRec.Id,OtherActionRec.SVMXC__Name__c ));
                    Map_AllActionRecs.put(OtherActionRec.Id,OtherActionRec);
                }
            } 
            

            //Getting Setting Value specific to Checklist based on which the picklist value will be populated
            if(checklistSettingEnabled && Map_ChecklistActions != null && Map_ChecklistActions.containsKey(ObjectName) && Map_ChecklistActions.get(ObjectName) != null)
                sfwActn_ActionFieldTypeOptns.add(new SelectOption('CHECKLIST',getTag100()));             
            
            /*SFW action Rec's Action type picklist values are populated as below - Ends here*/
        }
        return null;
    }
    public Boolean DisplayComponent = false;
    public Boolean getDisplayComponent()
    {
        return DisplayComponent;
    }
    public void OnChangeOfShowNHideCriteria()
    {
        DisplayComponent = false;
    }

    String PageBlockTitle = '';

    
    //Global describe for all objects is done here
    //public MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();//manish

    //Sfm utils instantiated and used to get the real object name
    SFM_Utils ObjName_util = new SFM_Utils();
    public String ObjectModeHeading;
    public String getObjectModeHeading(){ return ObjectModeHeading; }
    public String ObjectKeyPrefix = ''; //save in SFWdefinition.SVMXC__Object_key_prefix__c
    public String getPageBlockTitle()
    {
        if( Mode == 'Edit' )
                PageBlockTitle = getTAG051();
        else if( Mode == 'New' || Mode == 'Clone' )
                PageBlockTitle = getTAG050();
        return PageBlockTitle;
    }
    public String selectedTab = 'generalinfo';
    public String getselectedTab()
    {
        return selectedTab;
    }
    public void setselectedTab(String seltab)
    {
        this.selectedTab = seltab;
    }
    public String selectedCriteria;
    public String getSelectedcriteria()
    {
        return Selectedcriteria;
    }
    public void setSelectedcriteria(String val)
    {
        Selectedcriteria = val;
    }
    //Action Rec's selected criteria to be sent to component
    public String selectedCriteriaActn;
    public String getselectedCriteriaActn()
    {
        return selectedCriteriaActn;
    }
    public void setselectedCriteriaActn(String val)
    {
        selectedCriteriaActn = val;
    }

    //available svmx SFWs

    public String selectedSvmxSFW;
    public String getselectedSvmxSFW()
    {
        return selectedSvmxSFW;
    }
    public void setselectedSvmxSFW(String val)
    {
        selectedSvmxSFW = val;
    }

    //Available ServiceMax SFWs
    List<SelectOption> availableSFWOptions = new List<SelectOption>();
    public List<SelectOption> getAvailableSvmxSFWs()
    {
        return availableSFWOptions;
    }

    //Available ServiceMax group profiles
    public List<String> availableProfilesSelctd = new List<String>();
    public List<String> getavailableProfilesSelctd(){   return this.availableProfilesSelctd; }
    public void setavailableProfilesSelctd(List<String> availprofiles){ this.availableProfilesSelctd = availprofiles; }
    public List<SelectOption> AvailableProfilesOptns = new List<SelectOption>();
    public List<SelectOption> getAvailableSvmxGrpProfiles() 
    {
        return AvailableProfilesOptns;
    }

    //Selected ServiceMax group profiles
    public List<String> selectedProfilesSelctd = new List<String>();
    public List<String> getselectedProfilesSelctd(){   return this.selectedProfilesSelctd; }  
    public void setselectedProfilesSelctd(List<String> selctdprofiles){ this.selectedProfilesSelctd = selctdprofiles; }
    List<SelectOption> SelectedProfilesOptns = new List<SelectOption>();
    Map<String,String> SelectedProfMap = new Map<String,String>();

    public List<SelectOption> getSelectedSvmxGrpProfiles()
    {
        return SelectedProfilesOptns;
    }
    //Process record - general info tab data's record

    public SVMXC__ServiceMax_Processes__c SFWRec = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getSFWRec()
    {
        return SFWRec;
    }
    public void setSFWRec(SVMXC__ServiceMax_Processes__c rec)
    {
        this.SFWRec = rec;
    }

    List<SelectOption> ShowNHideOptns = new List<SelectOption>();
    public List<SelectOption> getShowHidecriteriaOptns()
    {
        return ShowNHideOptns;
    }
    public List<SVMXC__ServiceMax_Processes__c> LstnamedExpressionSorted = new List<SVMXC__ServiceMax_Processes__c>();
    public void refreshShowHidecriteriaOptns()
    {
        ShowNHideOptns.clear();
        List<SelectOption> Temp_showNHideCriteria = new List<SelectOption>();
        Temp_showNHideCriteria.add(new SelectOption('ServiceMax_None',getTAG041()));
        //selectedCriteria = 'ServiceMax_None';
        //setselectedCriteria('ServiceMax_None');
        if( ObjectName != 'None' &&  ObjectName != '' && ObjectName != null )
        {
            disableSourceObjField = true;

            for(SVMXC__ServiceMax_Processes__c Sfm_Exp: LstnamedExpressionSorted) //ResEXP.expressions
            {
                Temp_showNHideCriteria.add(new SelectOption(Sfm_Exp.Id, Sfm_Exp.SVMXC__ProcessID__c + '-' + Sfm_Exp.SVMXC__Name__c ));
            }
        }
        ShowNHideOptns.clear();
        ShowNHideOptns.addAll(Temp_showNHideCriteria);
        if(selectedCriteria != NULL && ( selectedCriteria.startswith('ServiceMax_None')))
        {
            //selectedCriteria = 'ServiceMax_None';
            //setselectedCriteria('ServiceMax_None');
            DisableEditCriteriaLnk = true;
        }
    }

    public List<SVMXC__ServiceMax_Processes__c> SFWActionsLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getSFWActionsLst()
    {
        return SFWActionsLst;
    }
    public SVMXC__ServiceMax_Processes__c[] SFWActionsSEQLst = new SVMXC__ServiceMax_Processes__c[]{};
    public SVMXC__ServiceMax_Processes__c[] getSFWActionsSEQLst()
    {
        return SFWActionsSEQLst;
    }
    public void setSFWActionsLst(List<SVMXC__ServiceMax_Processes__c> TActionsLst)
    {
        this.SFWActionsLst = TActionsLst;
    }
    
    public void onAddProfile()
    {
        if( availableProfilesSelctd.size() > 0 )
        {
            List<SelectOption> options_Avail = new List<SelectOption>();
            List<SelectOption> options_Sel = new List<SelectOption>();
            if(!(selectedSvmxSFW != null && selectedSvmxSFW.contains('ServiceMax_None')))
                SelectedProfMap.clear();
            
            for(String ProfToBeAdded :availableProfilesSelctd){
                SelectedProfMap.put(ProfToBeAdded,AvailProfMap.get(ProfToBeAdded));
                AvailProfMap.remove(ProfToBeAdded);
            }
            //Recreation of Selected profiles picklist 
            for(String SelectedProfileId :SelectedProfMap.keyset()){
                if( SelectedProfMap != null && SelectedProfMap.get(SelectedProfileId) != null )
                options_Sel.add(new SelectOption(SelectedProfileId, SelectedProfMap.get(SelectedProfileId)));
            }
            SelectedProfilesOptns = options_Sel;
            
            //Recreation of available Profiles picklist
            for(String AvailableProfileId :AvailProfMap.keyset()){
                options_Avail.add(new SelectOption(AvailableProfileId, AvailProfMap.get(AvailableProfileId)));
            }
            AvailableProfilesOptns = options_Avail;
            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR,getTag031(),''));
        }
    }

    public void onRemProfile()
    {
        if( selectedProfilesSelctd.size() > 0 )
        {
                List<SelectOption> options_Avail = new List<SelectOption>();
                List<SelectOption> options_Sel = new List<SelectOption>();
                for(String ProfToBeRemoved :selectedProfilesSelctd)
                {
                    AvailProfMap.put(ProfToBeRemoved,SelectedProfMap.get(ProfToBeRemoved));
                    SelectedProfMap.remove(ProfToBeRemoved);
                }
                //Recreation of available Profiles picklist
                for(String AvailableProfileId :AvailProfMap.keyset()){
                    if(AvailProfMap.get(AvailableProfileId) != null)
                    options_Avail.add(new SelectOption(AvailableProfileId, AvailProfMap.get(AvailableProfileId)));
                }
                AvailableProfilesOptns = options_Avail;
                
                //Recreation of Selected profiles picklist 
                for(String SelectedProfileId :SelectedProfMap.keyset()){
                if( SelectedProfMap.get(SelectedProfileId) != null )
                    options_Sel.add(new SelectOption(SelectedProfileId, SelectedProfMap.get(SelectedProfileId)));
                }
                SelectedProfilesOptns = options_Sel;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR,getTag032(),''));
        }
    }

//Tab Navigation methods
    public pageReference gotoGeneralInfoTab()
    {
        selectedTab = 'generalinfo';
        return null;
    }
    public pageReference gotoManageActionsTab()
    {
        selectedTab = 'manageactions';
        return null;
    }
    public pageReference gotoManagePermissionsTab()
    {
        selectedTab = 'managepermissions';
        return null;
    }
    //Tab 2 button methods
    Public Boolean NewActionRecCreationMode = false;
    public Boolean getNewActionRecCreationMode()
    {
        return NewActionRecCreationMode;
    }
    Public Boolean DisableActionRecSave = false;
    public Boolean getDisableActionRecSave()
    {
        return DisableActionRecSave;
    }
    public pagereference NewAction()
    {
        for(SvmxActionWrapper wrprRec: SvmxActionWrapperLst)
        {
            wrprRec.SvmxActionRec.SVMXC__Select__c = false;
        }       
        editActionWrapperObject = new SvmxActionWrapper(new SVMXC__ServiceMax_Processes__c( SVMXC__Sequence__c = SvmxActionWrapperLst.size()+1, RecordTypeId = RtypeSVMX_SFW_Action.Id  ),'ServiceMax_None','ServiceMax_None', null, '','');//added "RecordTypeId = RtypeSVMX_SFW_Action.Id" on 14th Feb 2012 by Shashank to solve the issue of picklist-ModeOfExecution on "New" click
        editActionWrapperObject.displayEditButton = false;
        //SvmxActionWrapperLst.add(newWizardwrprStep);//new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false)
        renderPanelWizrdStep = true;
        NewActionRecCreationMode = true;
        DisableActionRecSave = false;
        DisableActnNew = false;
        DisableActnDelete = false;
        renderTab2ExprBlock  = false;

        DisplayComponent = false;

        return null;
    }
    public void cancleCreateNewEditStep()
    {
        renderPanelWizrdStep = false;
        if(SvmxActionWrapperLst.size() > 0)
            DisableActnDelete = false;
        else
            DisableActnDelete = true;
    }
    
    public pagereference NewWizardStepSave()
    {
        SvmxActionWrapper tempActionWrapperObject = new SvmxActionWrapper(new SVMXC__ServiceMax_Processes__c( SVMXC__Sequence__c = 0, RecordTypeId = RtypeSVMX_SFW_Action.Id  ),'ServiceMax_None','ServiceMax_None', null, '','');
        boolean isEditWrapperObjValid = false;
        if(editActionWrapperObject != null && editActionWrapperObject.SvmxActionRec != null)
        {
            if(!NewActionRecCreationMode)
            {

                if( !(editActionWrapperObject.SvmxActionRec.SVMXC__Select_Template_At_Runtime__c))
                {
                    if( editActionWrapperObject.SelectedActionType == null ||(editActionWrapperObject.SelectedActionType != null &&  ((editActionWrapperObject.SelectedActionType.contains('ServiceMax_None') || editActionWrapperObject.SelectedActionType == 'ServiceMax_None' ))))
                    {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag036(),''));
                            isEditWrapperObjValid = true;
                    }
                }
                if( editActionWrapperObject.SvmxActionRec.SVMXC__Action_type__c == null ||(editActionWrapperObject.SvmxActionRec.SVMXC__Action_type__c != null &&  (((editActionWrapperObject.SvmxActionRec.SVMXC__Action_type__c).contains('ServiceMax_None') || (editActionWrapperObject.SvmxActionRec.SVMXC__Action_type__c == 'ServiceMax_None') ))))
                {
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,getTag036(),''));
                        isEditWrapperObjValid = true;
                }
                
                if( editActionWrapperObject.SvmxActionRec.SVMXC__Name__c == null || editActionWrapperObject.SvmxActionRec.SVMXC__Name__c == '' )
                {
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,getTag037(),''));
                    isEditWrapperObjValid = true;
                }
            }
                
            if(!isEditWrapperObjValid)
            {
                System.debug('NewActionRecCreationMode : '+NewActionRecCreationMode);
                if(NewActionRecCreationMode)
                    SvmxActionWrapperLst.add(editActionWrapperObject);
                else
                {
                    SFWActionsSEQLst.clear();// commented since it is present in cancelAction()
                    for(SvmxActionWrapper wrprRec: SvmxActionWrapperLst)
                    {
                        if(wrprRec.SvmxActionRec.id == editActionWrapperObject.SvmxActionRec.Id)
                        {
                            if(editActionWrapperObject != null && editActionWrapperObject.SvmxActionRec != null)
                            {
                            
                                // to preserve previous wrapper object
                                
                                if(wrprRec.displayEditButton != null)
                                    tempActionWrapperObject.displayEditButton = wrprRec.displayEditButton;
                                if(wrprRec.slctLstStepType != null)
                                    tempActionWrapperObject.slctLstStepType = wrprRec.slctLstStepType;
                                if(wrprRec.SelectedActionType != null)
                                    tempActionWrapperObject.SelectedActionType = wrprRec.SelectedActionType;
                                if(wrprRec.stepID != null)
                                    tempActionWrapperObject.stepID = wrprRec.stepID;
                                if(wrprRec.stepName != null)
                                    tempActionWrapperObject.stepName = wrprRec.stepName;
                                if(wrprRec.SelectedCriteriaToEnable != null)
                                    tempActionWrapperObject.SelectedCriteriaToEnable = wrprRec.SelectedCriteriaToEnable;
                                else
                                    tempActionWrapperObject.SelectedCriteriaToEnable = null;
                                if(wrprRec.expHeaderDetailRec != null)
                                    tempActionWrapperObject.expHeaderDetailRec = wrprRec.expHeaderDetailRec.clone();
                                else
                                    tempActionWrapperObject.expHeaderDetailRec = null;
                                if(wrprRec.disableModeOfExec != null)
                                    tempActionWrapperObject.disableModeOfExec = wrprRec.disableModeOfExec;
                                if(wrprRec.disableHandover != null)
                                    tempActionWrapperObject.disableHandover = wrprRec.disableHandover;
                                if(wrprRec.isWebService != null)
                                    tempActionWrapperObject.isWebService = wrprRec.isWebService;
                                if(wrprRec.isActnTypSFMOutputDoc != null)
                                    tempActionWrapperObject.isActnTypSFMOutputDoc = wrprRec.isActnTypSFMOutputDoc;
                                if(wrprRec.isActnTypChecklist != null)
                                    tempActionWrapperObject.isActnTypChecklist = wrprRec.isActnTypChecklist;                                    
                                tempActionWrapperObject.SvmxActionRec = wrprRec.SvmxActionRec.clone(true, true, false, true);
                                tempActionWrapperObject.strTranslatedActionType = getTranslatedCustomLabel(tempActionWrapperObject.SvmxActionRec);//added by manish---added for resolving defect 010398
                                
                                // to preserve previous wrapper object
                            
                                if(editActionWrapperObject.displayEditButton != null)
                                    wrprRec.displayEditButton = editActionWrapperObject.displayEditButton;
                                if(editActionWrapperObject.slctLstStepType != null)
                                    wrprRec.slctLstStepType = editActionWrapperObject.slctLstStepType;
                                if(editActionWrapperObject.SelectedActionType != null)
                                    wrprRec.SelectedActionType = editActionWrapperObject.SelectedActionType;
                                if(editActionWrapperObject.stepID != null)
                                    wrprRec.stepID = editActionWrapperObject.stepID; 
                                if(editActionWrapperObject.stepName != null)
                                    wrprRec.stepName = editActionWrapperObject.stepName;
                                if(editActionWrapperObject.SelectedCriteriaToEnable != null)
                                    wrprRec.SelectedCriteriaToEnable = editActionWrapperObject.SelectedCriteriaToEnable;
                                else
                                    wrprRec.SelectedCriteriaToEnable = null;
                                if(editActionWrapperObject.expHeaderDetailRec != null)
                                    wrprRec.expHeaderDetailRec = editActionWrapperObject.expHeaderDetailRec.clone();
                                else
                                    wrprRec.expHeaderDetailRec = null;
                                if(editActionWrapperObject.disableModeOfExec != null)
                                    wrprRec.disableModeOfExec = editActionWrapperObject.disableModeOfExec;
                                if(editActionWrapperObject.disableHandover != null)
                                    wrprRec.disableHandover = editActionWrapperObject.disableHandover;
                                if(editActionWrapperObject.isWebService != null)
                                    wrprRec.isWebService = editActionWrapperObject.isWebService;
                                if(editActionWrapperObject.isActnTypSFMOutputDoc != null)
                                    wrprRec.isActnTypSFMOutputDoc = editActionWrapperObject.isActnTypSFMOutputDoc;
                                if(wrprRec.isActnTypChecklist != null)
                                    wrprRec.isActnTypChecklist = editActionWrapperObject.isActnTypChecklist;                                       
                                    
                                wrprRec.SvmxActionRec = editActionWrapperObject.SvmxActionRec.clone(true, true, false, true);
                                wrprRec.strTranslatedActionType = getTranslatedCustomLabel(wrprRec.SvmxActionRec);//added by manish--added for resolving defect 010398
                            }
                        }
                        SFWActionsSEQLst.add(wrprRec.SvmxActionRec);// commented since it is present in cancelAction()
                    }
                }
                QuickSave();
                System.debug(logginglevel.warn,'NewActionRecCreationMode : '+NewActionRecCreationMode);
                if(NewActionRecCreationMode && (!(QuickSaveSuccessful) || ActionValidationFailed))
                {
                    SvmxActionWrapperLst.remove(SvmxActionWrapperLst.size()-1);
                }
                else if(!(QuickSaveSuccessful) || ActionValidationFailed)
                {
                    SFWActionsSEQLst.clear();// commented since it is present in cancelAction()
                    for(SvmxActionWrapper wrprRec: SvmxActionWrapperLst)
                    {
                        if(wrprRec.SvmxActionRec.id == tempActionWrapperObject.SvmxActionRec.Id)
                        {
                            System.debug(logginglevel.warn,'editActionWrapperObject.SelectedCriteriaToEnable : '+editActionWrapperObject.SelectedCriteriaToEnable);
                            if(tempActionWrapperObject != null && tempActionWrapperObject.SvmxActionRec != null)
                            {
                                if(tempActionWrapperObject.displayEditButton != null)
                                    wrprRec.displayEditButton = tempActionWrapperObject.displayEditButton;
                                if(tempActionWrapperObject.slctLstStepType != null)
                                    wrprRec.slctLstStepType = tempActionWrapperObject.slctLstStepType;
                                if(tempActionWrapperObject.stepID != null)
                                    wrprRec.stepID = tempActionWrapperObject.stepID;
                                if(tempActionWrapperObject.stepName != null)
                                    wrprRec.stepName = tempActionWrapperObject.stepName;
                                if(tempActionWrapperObject.SelectedActionType != null)
                                    wrprRec.SelectedActionType = tempActionWrapperObject.SelectedActionType;
                                if(tempActionWrapperObject.SelectedCriteriaToEnable != null)
                                    wrprRec.SelectedCriteriaToEnable = tempActionWrapperObject.SelectedCriteriaToEnable;
                                else
                                    wrprRec.SelectedCriteriaToEnable = null;
                                if(tempActionWrapperObject.expHeaderDetailRec != null)
                                    wrprRec.expHeaderDetailRec = tempActionWrapperObject.expHeaderDetailRec.clone();
                                else
                                    wrprRec.expHeaderDetailRec = null;
                                if(tempActionWrapperObject.disableModeOfExec != null)
                                    wrprRec.disableModeOfExec = tempActionWrapperObject.disableModeOfExec;
                                if(tempActionWrapperObject.disableHandover != null)
                                    wrprRec.disableHandover = tempActionWrapperObject.disableHandover;
                                if(tempActionWrapperObject.isWebService != null)
                                    wrprRec.isWebService = tempActionWrapperObject.isWebService;
                                if(tempActionWrapperObject.isActnTypSFMOutputDoc != null)
                                    wrprRec.isActnTypSFMOutputDoc = tempActionWrapperObject.isActnTypSFMOutputDoc;
                                if(tempActionWrapperObject.isActnTypChecklist != null)
                                    wrprRec.isActnTypChecklist = tempActionWrapperObject.isActnTypChecklist;                                    
                                wrprRec.SvmxActionRec = tempActionWrapperObject.SvmxActionRec.clone(true, true, false, true);
                                wrprRec.strTranslatedActionType = getTranslatedCustomLabel(wrprRec.SvmxActionRec);//added by manish---added for resolving defect 010398
                            }
                        }
                        SFWActionsSEQLst.add(wrprRec.SvmxActionRec);// commented since it is present in cancelAction()
                    }
                    System.debug(logginglevel.warn,'SvmxActionWrapperLst[0] '+SvmxActionWrapperLst[0]);
                }
                else
                {
                    renderPanelWizrdStep = false;
                    NewActionRecCreationMode = false;
                    renderTab2ExprBlock  = false;
                }
            }
        }
        // Jaysukh:added for view state defect 040618
        MapNamedExpressionRecords.clear();
        MapExpressionHdrDetailsLst.clear();
        return null;
    }
    
    public pagereference EditAction()
    {
        NewActionRecCreationMode = false;
        renderTab2ExprBlock  = false;
        Integer intCountSelected = 0;
        
        for(SvmxActionWrapper ActionWrprRec : SvmxActionWrapperLst)
        {   
            system.debug(ActionWrprRec+ '-------ActionWrprRec');
            if(ActionWrprRec.SvmxActionRec.Select__c)
            {
                intCountSelected = intCountSelected+1;
                if(ActionWrprRec != null && ActionWrprRec.SvmxActionRec != null)
                {
                    editActionWrapperObject = ActionWrprRec.clone();
                    editActionWrapperObject.displayEditButton = ActionWrprRec.displayEditButton;
                    editActionWrapperObject.SvmxActionRec = ActionWrprRec.SvmxActionRec.clone(true, true, false, true);
                    editActionWrapperObject.strTranslatedActionType = getTranslatedCustomLabel(editActionWrapperObject.SvmxActionRec);//added by Manish-----added for resolving defect 010398
                }
            }
        }
        if(intCountSelected == 0) 
        {
            renderPanelWizrdStep = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag040()));
        }
        else if(intCountSelected > 1)
        {
            renderPanelWizrdStep = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag034()));
        }
        else
        {
            renderPanelWizrdStep = true;
        }
        return null;
    }
    
//onChange method of available ServiceMax SFWs and its related methods
    public void rerenderAvailableSFWs()
    {
        SelectedProfilesOptns.clear();
        SelectedProfMap.clear();
        AvailProfMap.putall(AllGrpProfilesMap);

        //If the SFW is selected in the picklist of the manage permission tab, then, permission records are queried depending on the selected SFW in the picklist
        if( selectedSvmxSFW != 'ServiceMax_None' )//&& Mode == 'Edit' 
        {
            LstSFWPermsnRecs_SelectedSFW.clear();
            LstSFWPermsnRecs_SelectedSFW = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :selectedSvmxSFW');
            for(SVMXC__ServiceMax_Config_Data__c PermissionRec: LstSFWPermsnRecs_SelectedSFW)
            {
                if(PermissionRec.SVMXC__Access_Configuration_Profile__c != null && AvailProfMap.containsKey(PermissionRec.SVMXC__Access_Configuration_Profile__c) )
                {
                    SelectedProfilesOptns.add(new SelectOption(PermissionRec.SVMXC__Access_Configuration_Profile__c , AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c)));
                    AvailProfMap.remove(PermissionRec.SVMXC__Access_Configuration_Profile__c);
                    SelectedProfMap.put(PermissionRec.SVMXC__Access_Configuration_Profile__c,AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c));
                }
            }
            AvailableProfilesOptns.clear();
            for(String AvailableProfId :AvailProfMap.keyset())
            {
                if(AvailProfMap.get(AvailableProfId) != null)
                    AvailableProfilesOptns.add(new SelectOption(AvailableProfId, AvailProfMap.get(AvailableProfId)));
            }
        }
        else if( selectedSvmxSFW == 'ServiceMax_None' && SVMXRecId != null && SVMXRecId != '' )
        {
            LstSFWPermsnRecs_SelectedSFW.clear();
            LstSFWPermsnRecs_SelectedSFW = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :SVMXRecId');
            for(SVMXC__ServiceMax_Config_Data__c PermissionRec: LstSFWPermsnRecs_SelectedSFW)
            {
                if(PermissionRec.SVMXC__Access_Configuration_Profile__c != null && AvailProfMap.containsKey(PermissionRec.SVMXC__Access_Configuration_Profile__c) )
                {
                    SelectedProfilesOptns.add(new SelectOption(PermissionRec.SVMXC__Access_Configuration_Profile__c , AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c)));
                    AvailProfMap.remove(PermissionRec.SVMXC__Access_Configuration_Profile__c);
                    SelectedProfMap.put(PermissionRec.SVMXC__Access_Configuration_Profile__c,AllGrpProfilesMap.get(PermissionRec.SVMXC__Access_Configuration_Profile__c));
                }
            }
            AvailableProfilesOptns.clear();
            for(String AvailableProfId :AvailProfMap.keyset())
            {
                if(AvailProfMap.get(AvailableProfId) != null)
                    AvailableProfilesOptns.add(new SelectOption(AvailableProfId, AvailProfMap.get(AvailableProfId)));
            }
        }
    }

/* Methods to disable the buttons in manage actions tab when there are no actions */
    public Boolean IsbuttonsDisabled = false;
    public Boolean getIsbuttonsDisabled()
    {
        return IsbuttonsDisabled;
    }
    /* Methods to disable the buttons in manage actions tab when there are no actions */

    /* picklist 'Criteria to enable' population and related methods in manage actions tab - Starts here */

    public String SelectedCriteriaToenable;
    public String getSelectedCriteriaToenable()
    {
        return SelectedCriteriaToenable;
    }
    public void setSelectedCriteriaToenable(String val)
    {
        this.SelectedCriteriaToenable = val;
    }

    public List<SelectOption> CriteriaToEnableOptns = new List<SelectOption>();
    public List<SelectOption> getCriteriaToEnableOptns()
    {
        return CriteriaToEnableOptns;
    }

    /* picklist 'Criteria to enable' population and related methods in manage actions tab - Stops here */
    public Boolean DisableCriToEnableEditLink = false;
    public Boolean getDisableCriToEnableEditLink(){
        return DisableCriToEnableEditLink;
    }

    /*onChange method of picklist - Manage Actions tab - Starts here */
    public pagereference onChangeOfActionFieldPicklist()
    {
        if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c != null && editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c != 'ServiceMax_None')
        {
            editActionWrapperObject.strTranslatedActionType = getTranslatedCustomLabel(editActionWrapperObject.SvmxActionRec);//added by manish----added for resolving defect 010398
            editActionWrapperObject.SvmxActionRec.SVMXC__Expertise_Match_Enabled__c = false;
            editActionWrapperObject.SvmxActionRec.SVMXC__Name__c = null;
            editActionWrapperObject.SvmxActionRec.SVMXC__Description__c = null;
            editActionWrapperObject.stepID = null;
            List<SelectOption> tempLstOptns = new  List<SelectOption>();
            //editActionWrapperObject.slctLstStepType = new List<SelectOption>();
            //editActionWrapperObject.slctLstStepType.add(new SelectOption('ServiceMax_None',getTAG041()));
            editActionWrapperObject.SelectedActionType = 'ServiceMax_None';
            
            editActionWrapperObject.disableModeOfExec = true; //added by shashank on 19th Dec 2011 to disable ModeOf execution picklist
            editActionWrapperObject.disableHandover = false; //added by shashank on 3rd Feb 2012 to disable/enable Handover checkbox
            editActionWrapperObject.isWebService = true;
            editActionWrapperObject.SvmxActionRec.SVMXC__Select_Template_At_Runtime__c = false;
            editActionWrapperObject.isActnTypSFMOutputDoc = true;
            editActionWrapperObject.isActnTypChecklist = true;
           
            if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'SFM' && slctLstSFM != null && slctLstSFM.size() > 0)
                tempLstOptns.addAll(slctLstSFM);
                
            if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'OUTPUT_DOCUMENT' && slctLstOutPutDoc != null && slctLstOutPutDoc.size() > 0)
            {
                tempLstOptns.addAll(slctLstOutPutDoc);
                editActionWrapperObject.isActnTypSFMOutputDoc = false;
                editActionWrapperObject.disableHandover = true;
            }
            if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'INVENTORY' && slctLstINVENTORY != null && slctLstINVENTORY.size() > 0)
            {
                editActionWrapperObject.SvmxActionRec.Mode_Of_Execution__c = 'Interactive';
                editActionWrapperObject.disableHandover = true;
                tempLstOptns.addAll(slctLstINVENTORY);
            }
            if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'OTHERS' && slctLstOthers != null && slctLstOthers.size() > 0)
            {
                editActionWrapperObject.SvmxActionRec.Mode_Of_Execution__c = 'Interactive';
                editActionWrapperObject.disableHandover = false;
                tempLstOptns.addAll(slctLstOthers);
            }
            if((editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'RECEIPT' || editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'DELIVERY') && slctLstReceipt_Delivery != null && slctLstReceipt_Delivery.size() > 0)
            {
                editActionWrapperObject.SvmxActionRec.Mode_Of_Execution__c = 'Interactive';
                tempLstOptns.addAll(slctLstReceipt_Delivery);
            }   
            if((editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'SHIP' || editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'PICK_MOVE') && slctLstShip_Pick != null && slctLstShip_Pick.size() > 0)
            {
                editActionWrapperObject.SvmxActionRec.Mode_Of_Execution__c = 'Interactive';
                tempLstOptns.addAll(slctLstShip_Pick);
            }
            if((editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'BACKGROUND_EXEC') && slctLstBackGroundExecution != null && slctLstBackGroundExecution.size() > 0)
                tempLstOptns.addAll(slctLstBackGroundExecution);
            if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'INITIATE_RETURN' && slctLstInitiateReturn != null && slctLstInitiateReturn.size() > 0)
                tempLstOptns.addAll(slctLstInitiateReturn);
            if((editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'FULFILLMENT' ) && slctLstFulfillment != null && slctLstFulfillment.size() > 0)
            {
                editActionWrapperObject.SvmxActionRec.Mode_Of_Execution__c = 'Interactive';
                tempLstOptns.addAll(slctLstFulfillment);
            }
            if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'CHECKLIST')
            {
                editActionWrapperObject.SelectedActionType = 'ServiceMax_None';
                editActionWrapperObject.stepID = '';
                editActionWrapperObject.stepName = '';
                editActionWrapperObject.SvmxActionRec.Select_Template_At_Runtime__c = true;
                editActionWrapperObject.disableHandover = true;
                editActionWrapperObject.isActnTypChecklist = false;
                editActionWrapperObject.SvmxActionRec.Name__c = 'Default title for Checklist';
                editActionWrapperObject.SvmxActionRec.Description__c = 'Default Desc for Checklist';                
            }            
            
            editActionWrapperObject.slctLstStepType = new List<SelectOption>();
            editActionWrapperObject.slctLstStepType.add(new SelectOption('ServiceMax_None',getTAG041()));
            if(tempLstOptns != null && tempLstOptns.size() > 0)
            {
                tempLstOptns = sortingSelectOption(tempLstOptns);
                editActionWrapperObject.slctLstStepType.addAll(tempLstOptns);
            }
        }
        else if(editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c != null && editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'ServiceMax_None')
        {
            editActionWrapperObject.slctLstStepType = new List<SelectOption>();
            editActionWrapperObject.slctLstStepType.add(new SelectOption('ServiceMax_None',getTAG041()));
            editActionWrapperObject.SvmxActionRec.SVMXC__Name__c = null;
            editActionWrapperObject.SvmxActionRec.SVMXC__Description__c = null;
        }
        return null;
    }

    public void onChangeOfActionPicklist()
    {
        if(editActionWrapperObject.SelectedActionType != 'ServiceMax_None')
        {
            //Start : BAC-4763
            if(Map_AllActionRecs != null && Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Purpose__c != null)
            {
              editActionWrapperObject.selectedActionTypeURL = (Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Purpose__c).replaceAll(' ','_');
            }
            else
            {
             editActionWrapperObject.selectedActionTypeURL = '';
            }
            //End : BAC-4763
            if((editActionWrapperObject.SvmxActionRec.SVMXC__Action_Type__c == 'SFM' ) && Map_AllActionRecs != null && Map_AllActionRecs.containsKey(editActionWrapperObject.SelectedActionType) && (Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Purpose__c == 'STANDALONE CREATE' || Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Purpose__c == 'SOURCE TO TARGET ALL' || Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Purpose__c == 'SOURCE TO TARGET CHILD' || Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Purpose__c == 'STANDALONE EDIT'))
                editActionWrapperObject.disableModeOfExec = false;
            else
            {
                editActionWrapperObject.disableModeOfExec = true;
                editActionWrapperObject.SvmxActionRec.Mode_Of_Execution__c = 'Interactive';
            }
            if(Map_AllActionRecs != null && editActionWrapperObject.SelectedActionType != null && Map_AllActionRecs != null && Map_AllActionRecs.containsKey(editActionWrapperObject.SelectedActionType) && Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType) != null )
            {
                if(Map_AllActionRecs.containsKey(editActionWrapperObject.SelectedActionType) && Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType) != null)
                {
                    if(Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Custom_Action_Type__c == 'Web-Service')
                        editActionWrapperObject.isWebService = false;
                    else
                        editActionWrapperObject.isWebService = true;
                }
                else
                    editActionWrapperObject.isWebService = true;
                editActionWrapperObject.SvmxActionRec.SVMXC__Expertise_Match_Enabled__c = false;
                editActionWrapperObject.SvmxActionRec.SVMXC__Name__c = Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Name__c;
                editActionWrapperObject.stepID = Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__ProcessID__c;
                editActionWrapperObject.stepName = Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Name__c;
                editActionWrapperObject.SvmxActionRec.SVMXC__Description__c = Map_AllActionRecs.get(editActionWrapperObject.SelectedActionType).SVMXC__Description__c;
            }

        }
        else
        {
            editActionWrapperObject.SvmxActionRec.SVMXC__Expertise_Match_Enabled__c = false;
            editActionWrapperObject.SvmxActionRec.SVMXC__Name__c = null;
            editActionWrapperObject.SvmxActionRec.SVMXC__Description__c = null;
            editActionWrapperObject.isWebService = true;
        }
    }
    /*onChange method of picklist - Manage Actions tab - Ends here */

    public void preDeleteAction()
    {
        renderPanelWizrdStep = false;
        for(SvmxActionWrapper ActionWrprRec : SvmxActionWrapperLst)
        {
            if(selectedSequence != null && selectedSequence != '' && ActionWrprRec.SvmxActionRec.Sequence__c != null )
            {
                if(ActionWrprRec.SvmxActionRec.SVMXC__Sequence__c == Decimal.valueOf(selectedSequence))
                {
                    ActionWrprRec.SvmxActionRec.SVMXC__Select__c = true;
                    break;
                }
            }
        }
        DeleteAction();
    }
    
    public pagereference DeleteAction()
    {
        //DisableActnSequence = false;
        renderPanelWizrdStep = false;
        Boolean DoneDeleteOperation = false;
        Integer noOfRecsSelected = 0;
        List<SVMXC__ServiceMax_Processes__c> ProcessLst_RecsToDelete = new List<SVMXC__ServiceMax_Processes__c>();
        for(Integer i=0;i<SvmxActionWrapperLst.size();i++)
        {
            if(SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Select__c)
            {
                noOfRecsSelected += 1;
            }
        }
        if ( noOfRecsSelected != 0 )
        {
            List<SvmxActionWrapper> NwWrapperList = new List<SvmxActionWrapper>();
            for(SvmxActionWrapper WrapperRec :SvmxActionWrapperLst)
            {
                if(!(WrapperRec.SvmxActionRec.SVMXC__Select__c))
                    NwWrapperList.add(WrapperRec);
                else
                {
                    if(WrapperRec.SvmxActionRec != null && WrapperRec.SvmxActionRec.Id != null)
                        ProcessLst_RecsToDelete.add(WrapperRec.SvmxActionRec);
                    //else if( WrapperRec.SvmxActionRec != null )
                    DoneDeleteOperation = true;
                }
            }
            if( ProcessLst_RecsToDelete != null && ProcessLst_RecsToDelete.size() > 0 )
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                    
                    delete ProcessLst_RecsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    DoneDeleteOperation = true;
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            SvmxActionWrapperLst.clear();
            if( NwWrapperList != null && NwWrapperList.size() > 0)
            {
                SvmxActionWrapperLst.addAll(NwWrapperList);
                for(Integer i=0;i<SvmxActionWrapperLst.size();i++)
                {
                    SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Sequence__c = i + 1;
                }
            }

        }
        else
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,getTag035(),''));
        if( DoneDeleteOperation)
        {
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Confirm,getTAG055(),''));
            //cancelAction();
            /** After deleting the Expression record,need to update the sequence list-Issue Fix 12/03/2012 by Manjula K */
            SFWActionsLst = database.query('Select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Module__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Action_URL__c,  SVMXC__Submodule__c, SVMXC__IsStandard__c,SVMXC__Purpose__c,SVMXC__Mode_Of_Execution__c,SVMXC__Expertise_Match_Enabled__c,SVMXC__Handover__c,   SVMXC__Select_Template_At_Runtime__c,   SVMXC__Confirmation_Message__c From SVMXC__ServiceMax_Processes__c Where RecordType.Name = \'Wizard Step\' And SVMXC__Module__c = :SVMXRecId Order By SVMXC__Sequence__c ASC');
            SFWActionsSEQLst.clear();
            SFWActionsSEQLst.addAll(SFWActionsLst);
        }
        if(SvmxActionWrapperLst == null || (SvmxActionWrapperLst != null && SvmxActionWrapperLst.size() == 0 ))
        {
            DisableActnDelete = true;
            DisableActnSequence = true;
        }
        else if(SvmxActionWrapperLst != null && SvmxActionWrapperLst.size() == 1)
        {
            DisableActnDelete = false;
            DisableActnSequence = true;
        }
        renderTab2ExprBlock = false;
        actnexpwrapperObj = null;
        return null;
    }
    public PageReference SaveWizardStep()
    {
        renderPanelWizrdStep = false;
        return null;
    }
    
    public Integer getCountSteps()
    {
        if(SvmxActionWrapperLst != null)
            return SvmxActionWrapperLst.size();
        else
            return 0;
    }

/* Sequence Block - Related methods - Starts here*/
    public Boolean RenderSeqBlock = false;
    public Boolean getRenderSeqBlock()
    { 
        return RenderSeqBlock; 
    }
    public void SequenceActions()
    {
        RenderSeqBlock = true;
    }
    /* Sequence Block - Related methods - ends here*/
    //Save action starts here
    public Boolean ActionValidationFailed = false;
    public Boolean ValidateSteps()
    {
        ActionValidationFailed = false; //needed by quick save hence we make it public 
        if(QuickSaveSuccessful)
        {
            for(Integer i=0;i<SvmxActionWrapperLst.size();i++)
            {

                if(!(SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Select_Template_At_Runtime__c))
                {
                    
                    if( SvmxActionWrapperLst[i].SelectedActionType == null ||(SvmxActionWrapperLst[i].SelectedActionType != null &&  ((SvmxActionWrapperLst[i].SelectedActionType.contains('ServiceMax_None') || SvmxActionWrapperLst[i].SelectedActionType == 'ServiceMax_None' ))))
                    {
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,getTag036(),''));
                        ActionValidationFailed = true;
                        break;
                    }
                }
                if( SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Action_type__c == null ||(SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Action_type__c != null &&  (((SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Action_type__c).contains('ServiceMax_None') || (SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Action_type__c == 'ServiceMax_None') ))))
                {
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,getTag036(),''));
                    ActionValidationFailed = true;
                    break;
                }
                if( SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Name__c == null || SvmxActionWrapperLst[i].SvmxActionRec.SVMXC__Name__c == '' )
                {
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error,getTag037(),''));
                    ActionValidationFailed = true;
                    break;
                }
            }
        }
        return ActionValidationFailed;
    }
    public pagereference SaveAction()
    {
        if ( QuickSaveSuccessful && !(ActionValidationFailed) )
        {
            List<SVMXC__ServiceMax_Processes__c> Modified_ActionsLst = new List<SVMXC__ServiceMax_Processes__c>();
            for(SvmxActionWrapper WrapperRec :SvmxActionWrapperLst)
            {
                SVMXC__ServiceMax_Processes__c NewActionRec = new SVMXC__ServiceMax_Processes__c();
                NewActionRec.SVMXC__Select__c = false;
                NewActionRec.RecordTypeId = RtypeSVMX_SFW_Action.id;
                NewActionRec.SVMXC__Module__c = SVMXRecId;
                NewActionRec.SVMXC__Sequence__c = WrapperRec.SvmxActionRec.SVMXC__Sequence__c;
                NewActionRec.SVMXC__Name__c = WrapperRec.SvmxActionRec.SVMXC__Name__c;
                NewActionRec.Description__c = WrapperRec.SvmxActionRec.SVMXC__Description__c;
                NewActionRec.SVMXC__ProcessID__c = WrapperRec.SvmxActionRec.SVMXC__ProcessID__c;//Added this field to support ServiceMax Translation
                NewActionRec.SVMXC__Mode_Of_Execution__c = WrapperRec.SvmxActionRec.SVMXC__Mode_Of_Execution__c;//added on 19th dec 2011-shashank
                NewActionRec.SVMXC__Handover__c = WrapperRec.SvmxActionRec.SVMXC__Handover__c;//added on 19th dec 2011-shashank 
                NewActionRec.SVMXC__Select_Template_At_Runtime__c = WrapperRec.SvmxActionRec.SVMXC__Select_Template_At_Runtime__c;//added on 4th Oct 2011-sharad
                NewActionRec.SVMXC__Confirmation_Message__c = WrapperRec.SvmxActionRec.SVMXC__Confirmation_Message__c;//added on 18th May 2011-sharad
                NewActionRec.SVMXC__Expertise_Match_Enabled__c = WrapperRec.SvmxActionRec.SVMXC__Expertise_Match_Enabled__c;//added on 19th Sep 2011-sharad
                if(!(WrapperRec.SvmxActionRec.SVMXC__Select_Template_At_Runtime__c))
                {
                    if(WrapperRec.SelectedActionType != null && WrapperRec.SelectedActionType != 'ServiceMax_None' && WrapperRec.SelectedActionType != 'ServiceMaxAddNw')
                    {
                        NewActionRec.SVMXC__Action_Type__c = WrapperRec.SvmxActionRec.SVMXC__Action_Type__c;
                        NewActionRec.SVMXC__Process__c = WrapperRec.SelectedActionType;
                    }
                    else
                    {
                        NewActionRec.SVMXC__Action_Type__c = null;
                        NewActionRec.SVMXC__Process__c = null;
                    }
                }
                else
                {
                    NewActionRec.SVMXC__Action_Type__c = WrapperRec.SvmxActionRec.SVMXC__Action_Type__c;
                    NewActionRec.SVMXC__Process__c = null;
                }
                
                if(WrapperRec.SelectedCriteriaToEnable != null && (WrapperRec.SelectedCriteriaToEnable != 'ServiceMax_None' || WrapperRec.isSFWActionCriteraNew) )
                    NewActionRec.SVMXC__SubModule__c = WrapperRec.SelectedCriteriaToEnable;// Set the Enable Criteria = Reference to selected named-expression in Criteria to enable picklist
                else
                    NewActionRec.SVMXC__SubModule__c = null;
                    
                Modified_ActionsLst.add(NewActionRec);
                WrapperRec.SvmxActionRec = new SVMXC__ServiceMax_Processes__c();
                WrapperRec.SvmxActionRec = NewActionRec;
                WrapperRec.strTranslatedActionType = getTranslatedCustomLabel(NewActionRec);//added by manish-----added for resolving defect 010398
            }
            try
            {
                if( Modified_ActionsLst != null && Modified_ActionsLst.size() > 0 )
                {
                    List<SVMXC__ServiceMax_Processes__c> ActnListToDelete = new List<SVMXC__ServiceMax_Processes__c>();
                    ActnListToDelete = database.query('Select Id, SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c Where RecordType.Name = \'Wizard Step\' And SVMXC__Module__c = :SVMXRecId And SVMXC__IsStandard__c != true');
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                        
                        delete ActnListToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        ActionValidationFailed = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }

                    //upsert Modified_ActionsLst;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Modified_ActionsLst, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert Modified_ActionsLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        ActionValidationFailed = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    SFWRec.SVMXC__Dispatch_Process_Status__c = 'Complete';
                    //disable action related buttons
                    DisableActnNew = false;
                    DisableActnDelete = false;
                    DisableActnSequence = false;
                    renderTab2ExprBlock  = false;
                    //disable header buttons

                    SFWActionsSEQLst.clear();// commented since it is present in cancelAction()
                    SFWActionsSEQLst.addall(Modified_ActionsLst);// commented since it is present in cancelAction()
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Confirm,getTag039(),''));
                }
                else
                {
                    SFWRec.SVMXC__Dispatch_Process_Status__c = 'Incomplete';
                    //upsert SFWRec;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SFWRec, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert SFWRec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        ActionValidationFailed = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                }
            }
            catch(exception ex)
            {
                ActionValidationFailed = true;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,ex.getmessage(),''));
            }
        }
        return null;
    }

//new additions
    public boolean disableSourceObjField = false;
    public Boolean getdisableSourceObjField(){ return disableSourceObjField; }
    public Map<Id,SVMXC__ServiceMax_Processes__c> MapNamedExpressionRecords = new Map<Id,SVMXC__ServiceMax_Processes__c>(); //transient
    public Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> MapExpressionHdrDetailsLst = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>(); //transient
    //Jaysukh :changed below varible from global to local
    //public Set<Id> setExprHdrIds = new Set<Id>(); 
    public void rerenderExpressionsblock()
    {
        Set<Id> setExprHdrIds = new Set<Id>(); 
        ObjectName = SFWRec.SVMXC__Source_Object_Name__c;
        if( ObjectName != null && ObjectName != '' )
        {
            COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);//manish
            MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();//manish
            String APIName = ObjName_util.getOriginalAPIName(ObjectName, allObjs);
            if( APIName != null && allObjs.get(APIName) != null ) 
            {
                ObjectKeyPrefix = allObjs.get(APIName).getDescribe().getKeyPrefix();
            }

            //populate the field list for the selected object
            Hdrfldlist.clear();
            Hdrfldlist.add(new SelectOption('SVMX.NONE',getTag041()));
            WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
            DispMethods.RetriveField(ObjectName, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        }
        List<SelectOption> Temp_showNHideCriteria = new List<SelectOption>();
        Temp_showNHideCriteria.add(new SelectOption('ServiceMax_None',getTag041()));
        //Temp_showNHideCriteria.add(new SelectOption('ServiceMaxAddNw',getTag057()));
        if( ObjectName != 'None' &&  ObjectName != '' && ObjectName != null )
        {
            disableSourceObjField = true;
            /* Get expression List by calling getNamedExpressionList ends here */
            List<SVMXC__ServiceMax_Processes__c> LstnamedExpressionSorted = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__Parent_Object_Criteria__c,SVMXC__IsStandard__c, SVMXC__ProcessID__c,SVMXC__Purpose__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__Source_Object_Name__c = :ObjectName Order By SVMXC__ProcessID__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Processes__c Sfm_Exp: LstnamedExpressionSorted) //ResEXP.expressions
            {
                Temp_showNHideCriteria.add(new SelectOption(Sfm_Exp.Id, Sfm_Exp.SVMXC__ProcessID__c + '-' + Sfm_Exp.SVMXC__Name__c ));
                setExprHdrIds.add(Sfm_Exp.Id);
            }
            renderActionPicklistvalues();
            MapNamedExpressionRecords.putAll(LstnamedExpressionSorted);
        }
        
        //Exp details query done here 
        String strExpRowQuery ='Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, Name, Id ';
        strExpRowQuery += ' From SVMXC__ServiceMax_Config_Data__c ';
        //strExpRowQuery += ' where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Type__c = \'EXP_Named\' And SVMXC__Expression_Rule__c IN :setExprHdrIds';
        strExpRowQuery += ' where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Type__c = \'EXP_Named\' And SVMXC__Expression_Rule__c IN :setExprHdrIds Order by SVMXC__Sequence__c ASC'; //Added order by clause for fixing defect 044863
        List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRows = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstExpressionRows = database.query(strExpRowQuery);

        //Loop through and build the map exp hdr -> detail list recs
        for (SVMXC__ServiceMax_Config_Data__c qr : lstExpressionRows)
        {
            List<SVMXC__ServiceMax_Config_Data__c> tempLstOfexprRows = new List<SVMXC__ServiceMax_Config_Data__c>();
            if(MapExpressionHdrDetailsLst.containsKey(qr.SVMXC__Expression_Rule__c))
                tempLstOfexprRows = MapExpressionHdrDetailsLst.get(qr.SVMXC__Expression_Rule__c);
            tempLstOfexprRows.add(qr);    
            MapExpressionHdrDetailsLst.put(qr.SVMXC__Expression_Rule__c, tempLstOfexprRows);
        }
        
        ShowNHideOptns.clear();
        ShowNHideOptns.addAll(Temp_showNHideCriteria);
        if( selectedCriteria == 'ServiceMax_None' )
        {
            DisableEditCriteriaLnk = true;
        }
    }

    public Boolean QuickSaveSuccessful = true;
    public Boolean ValidationsOnSave()
    {
        Boolean result = true;
        if ( SFWRec.SVMXC__Source_Object_Name__c == null ||  SFWRec.SVMXC__Source_Object_Name__c == '' || SFWRec.SVMXC__Source_Object_Name__c == 'None' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG043(), ''));
            result = false;
        }
        if ( SFWRec.SVMXC__Name__c == null ||  SFWRec.SVMXC__Name__c == '' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag028(), ''));
            result = false;
        }
        if( SFWRec.SVMXC__ProcessID__c == null ||  SFWRec.SVMXC__ProcessID__c == '' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTag029(), ''));
            result = false;
        }
        List<SVMXC__ServiceMax_Processes__c> SFWLstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId = SFWRec.SVMXC__ProcessID__c;
        if( Mode == 'Clone' || Mode == 'New' )
                SFWLstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :UniqueProcessId AND RecordType.Name = \'Wizard\'');
                if( ( SVMXRecId != null && SVMXRecId!= '' && Mode == 'Edit' ) )
                SFWLstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :UniqueProcessId AND RecordType.Name = \'Wizard\' AND Id != :SVMXRecId');
        if( SFWLstToCheckId != null && SFWLstToCheckId.size() > 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG054(), ''));
            result = false;
        }
        if ( SvmxActionWrapperLst == null ||  SvmxActionWrapperLst.size() == 0 )
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG044(), ''));
            SFWRec.SVMXC__Dispatch_Process_Status__c = 'Incomplete';
            //result = false;
        }
        else
            SFWRec.SVMXC__Dispatch_Process_Status__c = 'Complete';
        if( selectedCriteria != 'ServiceMax_None' && selectedCriteria != 'ServiceMaxAddNw')
        {
            SFWRec.SVMXC__SubModule__c = selectedCriteria;
        }
        else
        {
            SFWRec.SVMXC__SubModule__c = null;
        }
        return result;
    }
    public SVMXC__ServiceMax_Processes__c SFWRecClone = new SVMXC__ServiceMax_Processes__c();
    
    public PageReference QuickSave()
    {
        if(disableOnView)
        {
            List<SVMXC__ServiceMax_Config_Data__c> PermissionRecLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(String SelectedProfileId :SelectedProfMap.keyset())
            {
                SVMXC__ServiceMax_Config_Data__c PermissionRec = new SVMXC__ServiceMax_Config_Data__c();
                PermissionRec.RecordTypeId = Rtype_SVMXSFWPermission.Id;
                //PermissionRec.SVMXC__Dispatch_Process__c = selectedSvmxSFW;// This line should be uncommented if we need to save selected SFW id in the available SFWs picklist in this field
                PermissionRec.SVMXC__Dispatch_Process__c = SVMXRecId;
                PermissionRec.SVMXC__Access_Configuration_Profile__c = SelectedProfileId;
                PermissionRecLst.add(PermissionRec);
            }
            List<SVMXC__ServiceMax_Config_Data__c> LstPermissionRecsToDelete = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :SVMXRecId');
            try
            {
                //upsert SFWRec;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SFWRec, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert SFWRec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    QuickSaveSuccessful = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    Delete LstPermissionRecsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    QuickSaveSuccessful = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(PermissionRecLst, COMM_SecurityUtils.Access.Createable)){
                    insert PermissionRecLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    QuickSaveSuccessful = false;
                    return null; 
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, getTag030(), ''));
                QuickSaveSuccessful = true;
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage(),''));
                QuickSaveSuccessful = false;
            }
            return null;
        }
        else
        {
            QuickSaveSuccessful = true;
            if(ValidationsOnSave())
            {
                Savepoint sp;
                try
                {
                    sp = Database.setSavepoint();
                    if(!(ValidateSteps()))
                    {
                        
                        if(selectedCriteria != null && (selectedCriteria != 'ServiceMax_None' || isSFWCriteriaNew) && expwrapperObj != null && expwrapperObj.ExpHeader != null && expwrapperObj.ExpDetailLst != null && !(expwrapperObj.ExpHeader.SVMXC__IsStandard__c) )
                        {
                            if( expwrapperObj.ExpHeader.SVMXC__Name__c == null || expwrapperObj.ExpHeader.SVMXC__Name__c == '' )
                            {
                                expwrapperObj.ExpHeader.SVMXC__Name__c.addError(getTAG0011());
                                QuickSaveSuccessful = false;
                            }
                            if( expwrapperObj.ExpHeader.SVMXC__ProcessId__c == null || expwrapperObj.ExpHeader.SVMXC__ProcessId__c == '' || (expwrapperObj.ExpHeader.SVMXC__ProcessId__c).length() < 8)
                            {
                                QuickSaveSuccessful = false;
                                expwrapperObj.ExpHeader.SVMXC__ProcessId__c.addError(getTAG0012());
                            }
                            if(QuickSaveSuccessful)
                            {

                                if(expwrapperObj.ExpDetailLst.size() > 0)
                                {
                                    for(Integer i =0 ; i <=  expwrapperObj.ExpDetailLst.size()-1 ; i++)
                                    {
                                        if(expwrapperObj.ExpDetailLst[i].SVMXC__Operator__c == 'SVMX.NONE' &&   expwrapperObj.ExpDetailLst[i].SVMXC__Field_Name__c == 'SVMX.NONE')
                                        {
                                            expwrapperObj.ExpDetailLst.remove(i);
                                            i--;
                                        }
                                    }
                                }
                                if(expwrapperObj.ExpDetailLst.size() > 0)
                                {
                                    SVMXC.SFM_saveExpression clsSave = new SVMXC.SFM_saveExpression();
                                    SFM_WrapperDef.SFM_Response saveResponse;
                                    Boolean isRollBack = false;
                                    //save header expressions
                                    List<SFM_WrapperDef.SFM_Expression> lstSFMExpression = new List<SFM_WrapperDef.SFM_Expression>();
                                    expwrapperObj.ExpHeader.SVMXC__SettingId__c = expwrapperObj.ExpHeader.SVMXC__ProcessID__c;
                                    expwrapperObj.ExpHeader.SVMXC__Source_Object_Name__c = objectName;
                                    for(SVMXC__ServiceMax_Config_Data__c exprRowRec :expwrapperObj.ExpDetailLst)
                                    {
                                        exprRowRec.SVMXC__Object_Name2__c = ObjectName;
                                    }
                                    APL_Utils aplutls = new APL_Utils();
                                    expwrapperObj.ExpDetailLst = aplutls.PopulateInfoForReferenceFields(expwrapperObj.ExpDetailLst);
                                    lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(expwrapperObj.ExpHeader, expwrapperObj.ExpDetailLst));
                                    SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
                                    saveResponse = new SFM_WrapperDef.SFM_Response();
                                    saveResponse = clsSave.SFM_saveExpression(expressionRequest);
                                    if(saveResponse.success == false)
                                    {
                                        isRollBack = true;
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,' '+saveResponse.message,''));
                                    }
                                    else 
                                    {
                                        if(saveResponse != null && saveResponse.resultIds != null && saveResponse.resultIds.size() > 0)
                                        {
                                            sfwRec.SVMXC__Submodule__c = saveResponse.resultIds[0];
                                            selectedCriteria = saveResponse.resultIds[0];
                                        }
                                    }
                                    if(isRollBack)
                                    {
                                        sfwRec.SVMXC__Submodule__c = null;
                                        Database.rollback(sp);
                                        QuickSaveSuccessful = false;
                                    }
                                }
                                else
                                {
                                    HdrADDRow();
                                    HdrADDRow();
                                    QuickSaveSuccessful = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, expwrapperObj.ExpHeader.SVMXC__Name__c + ':' + getTAG096(), ''));
                                }
                            }
                        }
                        
                        if(!QuickSaveSuccessful) return null;
                    
                        //Save chnaged or added detail expressions
                        List<SvmxActionWrapper> SvmxActionWrapperLstTemp = new List<SvmxActionWrapper>();
                        SvmxActionWrapperLstTemp = SaveExpression(SvmxActionWrapperLst);
                        SvmxActionWrapperLst = new List<SvmxActionWrapper>();
                        SvmxActionWrapperLst = SvmxActionWrapperLstTemp;
                        if ( Mode == 'Clone' )
                        {
                            SFWRecClone.RecordTypeId = SFWRec.RecordTypeId;
                            SFWRecClone.SVMXC__Name__c = SFWRec.SVMXC__Name__c;
                            SFWRecClone.SVMXC__ProcessID__c = SFWRec.SVMXC__ProcessID__c;
                            SFWRecClone.SVMXC__SettingID__c = SFWRec.SVMXC__ProcessID__c;
                            SFWRecClone.SVMXC__Description__c = SFWRec.SVMXC__Description__c;
                            SFWRecClone.SVMXC__Source_Object_Name__c = SFWRec.SVMXC__Source_Object_Name__c;
                            SFWRecClone.SVMXC__Object_key_prefix__c = SFWRec.SVMXC__Object_key_prefix__c;
                            SFWRecClone.SVMXC__Submodule__c = SFWRec.SVMXC__Submodule__c;
                            SFWRecClone.SVMXC__IsStandard__c = false;
                            SFWRecClone.SVMXC__Select__c = false;
                            SFWRecClone.SVMXC__Active__c = SFWRec.SVMXC__Active__c;
                            SFWRecClone.SVMXC__Dispatch_Process_Status__c = SFWRec.SVMXC__Dispatch_Process_Status__c;
                            //SFWRecClone.SVMXC__IsGlobal__c = SFWRec.SVMXC__IsGlobal__c;
                            
                            
                            //upsert SFWRecClone;
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SFWRecClone, COMM_SecurityUtils.Access.Upsertable ) ) {
                                upsert SFWRecClone; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            } else {
                                Database.rollback(sp);
                                QuickSaveSuccessful = false;
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                                return null;
                            }
                            SVMXRecId = SFWRecClone.Id;
                            Mode = 'Edit';
                            SFWRec = new SVMXC__ServiceMax_Processes__c();
                            SFWRec = SFWRecClone;
                        }    
                        else if ( Mode == 'Edit' ||  Mode == 'New' )
                        {
                            //insert or update SFW Definition record
                            System.debug('Save New SFW : '+SFWRec.Id);
                            SFWRec.RecordTypeId = Rtype_SFWHeader.Id;
                            SFWRec.SVMXC__Source_Object_Name__c = ObjectName;
                            SFWRec.SVMXC__Object_key_prefix__c = ObjectKeyPrefix;
                            SFWRec.IsStandard__c = false;
                            //upsert SFWRec;
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SFWRec, COMM_SecurityUtils.Access.Upsertable ) ) {
                                upsert SFWRec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            } else {
                                Database.rollback(sp);
                                QuickSaveSuccessful = false;
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                                return null;
                            }
                            SVMXRecId = SFWRec.Id;
                            Mode = 'Edit';
                        }

                        //List of SFW permission
                        //Insert permission records - New mode; Delete and insert permission records - Edit mode
                        List<SVMXC__ServiceMax_Config_Data__c> PermissionRecLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                        for(String SelectedProfileId :SelectedProfMap.keyset())
                        {
                                SVMXC__ServiceMax_Config_Data__c PermissionRec = new SVMXC__ServiceMax_Config_Data__c();
                                PermissionRec.RecordTypeId = Rtype_SVMXSFWPermission.Id;
                                //PermissionRec.SVMXC__Dispatch_Process__c = selectedSvmxSFW;// This line should be uncommented if we need to save selected SFW id in the available SFWs picklist in this field
                                PermissionRec.SVMXC__Dispatch_Process__c = SVMXRecId;
                                PermissionRec.SVMXC__Access_Configuration_Profile__c = SelectedProfileId;
                                PermissionRecLst.add(PermissionRec);
                        }
                        List<SVMXC__ServiceMax_Config_Data__c> LstPermissionRecsToDelete = Database.query('Select SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Access\' And SVMXC__Dispatch_Process__c = :SVMXRecId');
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                            Delete LstPermissionRecsToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                        } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            Database.rollback(sp);
                            QuickSaveSuccessful = false;
                            return null;
                        }
                        
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(PermissionRecLst, COMM_SecurityUtils.Access.Createable)){
                            insert PermissionRecLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                            Database.rollback(sp);
                            QuickSaveSuccessful = false;
                            return null; 
                        }
                        
                        if( Mode == 'Edit' )//Mode == 'Clone'  )// SFW Layout record is inserted in the following section
                        {
                            //Check whether Layout record exists for the NewSFW being created
                            List<SVMXC__ServiceMax_Config_Data__c> SFWLayout_CheckRecLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                            SFWLayout_CheckRecLst = database.query('Select Id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c, SVMXC__Wizard_Layout_Row__c, SVMXC__Wizard_Layout_Column__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Layout\' And SVMXC__Object_Name__c = :ObjectName AND SVMXC__Dispatch_Process__c = :SVMXRecId');
                            if( (SFWLayout_CheckRecLst == null || SFWLayout_CheckRecLst.size() == 0) )
                            {
                                Map<String,String> Map_SFWLayoutPositions = new Map<String,String>();
                                List<SVMXC__ServiceMax_Config_Data__c> ListCurrentSFWLayouts = new List<SVMXC__ServiceMax_Config_Data__c>();
                                ListCurrentSFWLayouts = database.query('Select Id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c, SVMXC__Wizard_Layout_Row__c, SVMXC__Wizard_Layout_Column__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Layout\' And SVMXC__Object_Name__c = :ObjectName');
                                Integer NewSFWRowNum = 0;
                                for(SVMXC__ServiceMax_Config_Data__c SFWLayoutRec: ListCurrentSFWLayouts)
                                {
                                    if( SFWLayoutRec.SVMXC__Wizard_Layout_Row__c != null ) //Calculate the highest row number currently used
                                    {
                                        if( NewSFWRowNum < Math.Round(SFWLayoutRec.SVMXC__Wizard_Layout_Row__c))
                                            NewSFWRowNum = Math.Round(SFWLayoutRec.SVMXC__Wizard_Layout_Row__c);
                                    }
                                    if( SFWLayoutRec.SVMXC__Wizard_Layout_Row__c != null && SFWLayoutRec.SVMXC__Wizard_Layout_Column__c != null )
                                    {
                                        String Rec_LayoutPosition = String.valueOf(Math.Round(SFWLayoutRec.SVMXC__Wizard_Layout_Row__c)) + ':' + String.valueOf(Math.Round(SFWLayoutRec.SVMXC__Wizard_Layout_Column__c));
                                        Map_SFWLayoutPositions.put( Rec_LayoutPosition, Rec_LayoutPosition );
                                    }
                                }
                                //This is commented to consume less SOQL as part of BAC-3259
                                //Recordtype Rtype_SFWLayout = [Select Id, Name from RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Wizard Layout' Limit 1];

                                SVMXC__ServiceMax_Config_Data__c NewSFWLayoutRecord = new SVMXC__ServiceMax_Config_Data__c();
                                NewSFWLayoutRecord.RecordTypeId = Rtype_SFWLayout.Id;
                                NewSFWLayoutRecord.SVMXC__Dispatch_Process__c = SVMXRecId;
                                NewSFWLayoutRecord.SVMXC__Object_Name__c = ObjectName;
                                if( Map_SFWLayoutPositions.get( String.valueOf(Math.Round(NewSFWRowNum)) + ':2' ) == null ) 
                                {
                                    NewSFWLayoutRecord.SVMXC__Wizard_Layout_Row__c = Math.Round(NewSFWRowNum);
                                    NewSFWLayoutRecord.SVMXC__Wizard_Layout_Column__c = 2;
                                }
                                else
                                {
                                    NewSFWLayoutRecord.SVMXC__Wizard_Layout_Row__c = Math.Round(NewSFWRowNum) + 1;
                                    NewSFWLayoutRecord.SVMXC__Wizard_Layout_Column__c = 1;
                                }
                                if(NewSFWLayoutRecord.SVMXC__Button_Size__c == null)
                                    NewSFWLayoutRecord.SVMXC__Button_Size__c = 'Medium';
                                //upsert NewSFWLayoutRecord;
                                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( NewSFWLayoutRecord, COMM_SecurityUtils.Access.Upsertable ) ) {
                                    upsert NewSFWLayoutRecord; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                } else {
                                    Database.rollback(sp);
                                    QuickSaveSuccessful = false;
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                                    return null;
                                }
                            }
                        }
                        if( QuickSaveSuccessful )//&& !(ActionValidationFailed)
                        {
                            SaveAction();
                            //Start-19th Dec 2011 by Shashank
                            List<SVMXC__ServiceMax_Processes__c> LstWzrdSteps = new List<SVMXC__ServiceMax_Processes__c>();
                            LstWzrdSteps = Database.query('Select Id, SVMXC__Select__c, SVMXC__Active__c, SVMXC__Sequence__c, SVMXC__Module__c, SVMXC__Process__c, SVMXC__Process1__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Action_Type__c,SVMXC__Expertise_Match_Enabled__c,SVMXC__Action_URL__c, SVMXC__Submodule__c, SVMXC__IsStandard__c, SVMXC__Mode_Of_Execution__c, SVMXC__Purpose__c, SVMXC__Handover__c, SVMXC__Select_Template_At_Runtime__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Confirmation_Message__c From SVMXC__ServiceMax_Processes__c Where RecordType.Name = \'Wizard Step\' And SVMXC__Module__r.Id = :SVMXRecId Order By SVMXC__Sequence__c ASC');
                            for(Integer i = 0; i< LstWzrdSteps.size() - 1; i++)
                            {
                                LstWzrdSteps[i].SVMXC__Process1__c = LstWzrdSteps[i+1].Id;
                            }
                            //upsert LstWzrdSteps;
                            //End-19th Dec 2011 by Shashank
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( LstWzrdSteps, COMM_SecurityUtils.Access.Upsertable ) ) {
                                upsert LstWzrdSteps; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            } else {
                                Database.rollback(sp);
                                QuickSaveSuccessful = false;
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                                return null;
                            }
                        }
                        system.debug('error0004 :'+QuickSaveSuccessful + ' :'+ActionValidationFailed);
                        
                    }
                    if(!(QuickSaveSuccessful) || (ActionValidationFailed))
                    {
                        System.debug('Roll Back happen');
                        Database.rollback(sp);
                    }
                    else if((QuickSaveSuccessful) && !(ActionValidationFailed))
                    {
                        rerenderExpressionsblock();
                        renderTab1ExprBlock = false;
                        renderTab2ExprBlock = false;
                        expwrapperObj = null;
                        actnexpwrapperObj = null;
                        if(SvmxActionWrapperLst == null || (SvmxActionWrapperLst != null && SvmxActionWrapperLst.size() == 0 ))
                        {
                            DisableActnDelete = true;
                            DisableActnSequence = true;
                        }
                        else if(SvmxActionWrapperLst != null && SvmxActionWrapperLst.size() == 1)
                        {
                            DisableActnDelete = false;
                            DisableActnSequence = true;
                        }
                        DisableActnNew = false;
                        //Defect BAC-4874 : To support translation on Quick save
                        generateMasterTag();
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, getTag030(), ''));
                        String Retlocation = '/apex/CONF_SetupServiceFlowWizard?SVMX_RecordId='+SVMXRecId;
                        PageReference ReturnPage = new PageReference(Retlocation);
                        ReturnPage.setRedirect(true);
                        return ReturnPage;
                    }
                    system.debug('error0005 :'+QuickSaveSuccessful + ' :'+SvmxActionWrapperLst);
                    return null;
                }
                catch( exception ex )
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage(), ''));
                    Database.rollback(sp);
                    QuickSaveSuccessful = false;
                    return null;
                }
            }
            else
            {
                QuickSaveSuccessful = false;
                return null;
            }
        }
    }
    
    public pageReference isChkSelecTempltRunTime()
    {
        editActionWrapperObject.SelectedActionType = 'ServiceMax_None';
        editActionWrapperObject.stepID = '';
        editActionWrapperObject.stepName = '';
        if(editActionWrapperObject.SvmxActionRec.SVMXC__Select_Template_At_Runtime__c == false)
        {   
            editActionWrapperObject.SvmxActionRec.Name__c = '';
            editActionWrapperObject.SvmxActionRec.Description__c = '';
            
        }
        if(editActionWrapperObject.SvmxActionRec.SVMXC__Select_Template_At_Runtime__c == true)
        {
            editActionWrapperObject.SvmxActionRec.Name__c = 'Default title for output doc';
            editActionWrapperObject.SvmxActionRec.Description__c = 'Default Desc for output doc';
        }
        return null;
    }
    
    
    public pageReference SaveNClose()
    {
        QuickSave();
        if((QuickSaveSuccessful) && !(ActionValidationFailed))
        {
            String Retlocation;
            if(sfwRec != null && sfwRec.Id != null)
                Retlocation = '/apex/SVMXC__CONF_ManageServiceFlowWizard?SVMX_ObjectName='+sfwRec.Source_Object_Name__c;
            else
                Retlocation = '/apex/SVMXC__CONF_ManageServiceFlowWizard';
            //BAC-4012 - To support translation for Wizards
            generateMasterTag();            
            PageReference ReturnPage = new PageReference(Retlocation);
            ReturnPage.setRedirect(true);
            return ReturnPage;
        }
        else
        {
            return null;    
        }
    }
    //BAC-4012 AND DEFECT 4874- To support translation for Wizards
    public void generateMasterTag()
    {
        System.debug('sfwRec id: '+sfwRec.Id );
        if((QuickSaveSuccessful) && !(ActionValidationFailed))
        {
            if(sfwRec != null && sfwRec.Id != null)
            {
               CONF_ManageTranslations conf_manageTranslations = new CONF_ManageTranslations();
               conf_manageTranslations.generateMasterTag(sfwRec.id);   
            } 
        }
    }
    /*  Test methods */
    public SVMXC__ServiceMax_Processes__c SelectedexpHeader = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Config_Data__c[] expdtlLst = new SVMXC__ServiceMax_Config_Data__c[]{};
    public SVMXC__ServiceMax_Processes__c getSelectedexpHeader(){ return SelectedexpHeader;}
    public SVMXC__ServiceMax_Config_Data__c[] getexpdtlLst(){ return expdtlLst; }
    public void AddNewCriteriaForSFW()
    {
        DisableEditCriteriaLnk = true;
        isSFWCriteriaNew = true;
        renderTab1ExprBlock = true;
        if(ObjectName != '' && ObjectName != null)
        {
            expwrapperObj = new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c( RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = ObjectName), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);
            HdrADDRow();
            HdrADDRow();
            if(expwrapperObj.ExpDetailLst != null)
                ExpDetailSize = expwrapperObj.ExpDetailLst.size();
            selectedCriteria = 'ServiceMax_None';
        }
    }
    public void OnchangeOfcriteriaPicklist()
    {
        DisableEditCriteriaLnk = false;
        renderTab1ExprBlock = true;
        isSFWCriteriaNew = false;
        expwrapperObj = null;
        if( selectedCriteria != null && selectedCriteria != ''  && selectedCriteria != 'ServiceMax_None' )
        {
            renderTab1ExprBlock = false;
        }
        else if( selectedCriteria == null || selectedCriteria == '' || selectedCriteria.startswith('ServiceMax_None') || ObjectName != '' || ObjectName != null )
        {
            displaycomponent = false;
            DisableEditCriteriaLnk = true;
            renderTab1ExprBlock = false;
        }
        else if( SFWRec.SVMXC__IsStandard__c )
        {
            DisableEditCriteriaLnk = true;
        }
    }
    
    public void OnClickOfEditCriteria()
    {
        renderTab1ExprBlock = true;
        ExpDetailSize = 0;
        String SelectedExpId = selectedCriteria;
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        if( SelectedExpId != null && SelectedExpId != '' )
        {
            String ExprId = SelectedExpId;
            ExprId = ExprId.substring(0, 15);
            stringMap.add(new SFM_WrapperDef.SFM_StringMap ('EXPRESSIONID',ExprId));
            //Create the request
            SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',stringMap);
            
            //Result
            SFM_GetNamedExpressionList getExpCls = new SFM_GetNamedExpressionList();
            SFM_WrapperDef.SFM_Response_Expression ResEXP; // We make it available public, since it needs to be used by component also.
            ResEXP = getExpCls.SFM_getNamedExpressionList(request);
        
            //Create the picklist entries by looping through the resultant exp list obtained above
        
            Map<String, SVMXC__ServiceMax_Config_Data__c> Map_ConfigRecs = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> ModifiedExpressionDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SFM_WrapperDef.SFM_Expression Sfm_Exp:ResEXP.expressions)
            {
                Integer tempHighestSeqNum = 0;
                Map_ConfigRecs.putAll(Sfm_Exp.expressionDetails);
                for( SVMXC__ServiceMax_Config_Data__c  Sfm_DetailExpression :Sfm_Exp.expressionDetails )
                {
                    if( Sfm_DetailExpression.SVMXC__Sequence__c != null )
                    {
                        Map_SequenceNumRec.put((Sfm_DetailExpression.SVMXC__Sequence__c).intvalue(), Sfm_DetailExpression);
                    }
                }
                If(Sfm_Exp.expressionDetails != null)
                    ExpDetailSize = Math.Round(Sfm_Exp.expressionDetails.size());
                for( integer i=1; i < Sfm_Exp.expressionDetails.size() + 1; i++ )
                {
                    if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i) != null )
                    {    
                        Map_SequenceNumRec.get(i).SVMXC__Sequence__c = Math.Round(Map_SequenceNumRec.get(i).SVMXC__Sequence__c);
                        ModifiedExpressionDetailLst.add(Map_SequenceNumRec.get(i));
                    }
                }
            
                if( Sfm_Exp.namedExpression != null && !(Sfm_Exp.namedExpression.SVMXC__IsStandard__c) )
                {
                    //DisableSave = false;
                }
                expwrapperObj = new ExpressionWrapper(Sfm_Exp.namedExpression, ModifiedExpressionDetailLst, true, false);
                if(expwrapperObj.ExpDetailLst != null)
                    ExpDetailSize = expwrapperObj.ExpDetailLst.size();
            }
        }
    }
    public pagereference HeaderCancel()
    {
        String Retlocation;
        if(sfwRec != null && sfwRec.Id != null )
          Retlocation = '/apex/SVMXC__CONF_ManageServiceFlowWizard?SVMX_ObjectName='+sfwRec.Source_Object_Name__c;
        else if(ObjectName != null && ObjectName.length() > 0)
            Retlocation = '/apex/SVMXC__CONF_ManageServiceFlowWizard?SVMX_ObjectName='+ObjectName;
        else
            Retlocation = '/apex/SVMXC__CONF_ManageServiceFlowWizard';
        PageReference ReturnPage = new PageReference(Retlocation);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    public Map<Integer,String> mapSequenceResultId = new Map<Integer,String>();
    Integer ActnExpDetailSize = 0;
    public Integer getActnExpDetailSize(){ return ActnExpDetailSize; }

    public pagereference ChangeActnExprCriteria()
    {
        renderTab2ExprBlock = false;
        actnexpwrapperObj = null;
        editActionWrapperObject.isSFWActionCriteraNew = false;
        if(editActionWrapperObject.SelectedCriteriaToEnable != 'ServiceMax_None')
        {
            editActionWrapperObject.displayEditButton = true;
            editActionWrapperObject.expHeaderDetailRec = null;
            actnexpwrapperObj = null;
        }
        else if(editActionWrapperObject.SelectedCriteriaToEnable == 'ServiceMax_None' )
        {
            editActionWrapperObject.displayEditButton = false;
            editActionWrapperObject.expHeaderDetailRec = null;
            actnexpwrapperObj = null;
        }
        return null;
    }

    //Component mode declaration and related methods
    public String componentMode;
    public String getcomponentMode()
    {
        return componentMode;
    }
    public void setcomponentMode(String val){
        this.componentMode = val;
    }
    
    public pagereference createNewCriteria()
    {
        editActionWrapperObject.isSFWActionCriteraNew = true;
        renderTab2ExprBlock = true;
        ActnExpDetailSize = 0;
        actnexpwrapperObj = new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = ObjectName), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);
        ActnHdrADDRow();
        ActnHdrADDRow();
        editActionWrapperObject.expHeaderDetailRec = actnexpwrapperObj;
        editActionWrapperObject.displayEditButton = false;
        editActionWrapperObject.SelectedCriteriaToEnable = 'ServiceMax_None';
        return null;
    }
    
    public pagereference EditActionCriteria()
    {
            if(editActionWrapperObject.SelectedCriteriaToEnable != 'ServiceMax_None')
            {
                editActionWrapperObject.isSFWActionCriteraNew = false;
                renderTab2ExprBlock = true;
                ActnExpDetailSize = 0;
                
                if(editActionWrapperObject.expHeaderDetailRec != null && editActionWrapperObject.expHeaderDetailRec.ExpHeader.Id == editActionWrapperObject.SelectedCriteriaToEnable)
                {
                    actnexpwrapperObj = editActionWrapperObject.expHeaderDetailRec;
                    if(editActionWrapperObject.expHeaderDetailRec.ExpDetailLst != null)
                        ActnExpDetailSize = editActionWrapperObject.expHeaderDetailRec.ExpDetailLst.size();
                }
                else
                {
                    List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
                    stringMap.add(new SFM_WrapperDef.SFM_StringMap ('EXPRESSIONID',selectedCriteriaActn));

                    //Create the request
                    SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request('','','',stringMap);
            
                    //Result
                    SFM_GetNamedExpressionList getExpCls = new SFM_GetNamedExpressionList();
                    SFM_WrapperDef.SFM_Response_Expression ResEXP; // We make it available public, since it needs to be used by component also.
                    ResEXP = getExpCls.SFM_getNamedExpressionList(request);
                    
                    /* new addition */
                    // Get the definition for all the relevant named expressions
                    selectedCriteriaActn = editActionWrapperObject.SelectedCriteriaToEnable;
                    
                    String strExpDefQuery = 'Select Id, Name, SVMXC__Sequence__c, SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__SettingId__c, SVMXC__ProcessID__c , SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c, SVMXC__IsStandard__c ';
                    strExpDefQuery += ' From SVMXC__ServiceMax_Processes__c ';
                    strExpDefQuery += ' Where Recordtype.Name=\'SVMX Rule\' AND SVMXC__Rule_Type__c = \'Named Expression\' AND Id = :selectedCriteriaActn';
                    List<SVMXC__ServiceMax_Processes__c> lstNamedExpDefintion = new List<SVMXC__ServiceMax_Processes__c>();
                    lstNamedExpDefintion = database.query(strExpDefQuery);
                    
                            
                    // Get the expression rows for all the above named expressions
                    String strExpRowQuery ='Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, Name, Id ';
                    strExpRowQuery += ' From SVMXC__ServiceMax_Config_Data__c ';
                    strExpRowQuery += ' where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Type__c = \'EXP_Named\' And SVMXC__Expression_Rule__c = :selectedCriteriaActn Order by SVMXC__Sequence__c ASC';
                    List<SVMXC__ServiceMax_Config_Data__c> lstExpressionRows = new List<SVMXC__ServiceMax_Config_Data__c>();
                    lstExpressionRows = database.query(strExpRowQuery);
                    actnexpwrapperObj = editActionWrapperObject.expHeaderDetailRec;
                    /* new addition */

                    //Create the picklist entries by looping through the resultant exp list obtained above
                    Map<String, SVMXC__ServiceMax_Config_Data__c> Map_ConfigRecs = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
                    Map_SequenceNumRec.clear();
                    List<SVMXC__ServiceMax_Config_Data__c> ModifiedExpressionDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                        Integer tempHighestSeqNum = 0;
                        Map_ConfigRecs.putAll(lstExpressionRows);
                        for( SVMXC__ServiceMax_Config_Data__c  Sfm_DetailExpression :lstExpressionRows)//Sfm_Exp.expressionDetails )
                        {
                            if( Sfm_DetailExpression.SVMXC__Sequence__c != null )
                            {
                                Map_SequenceNumRec.put((Sfm_DetailExpression.SVMXC__Sequence__c).intvalue(), Sfm_DetailExpression);
                            }
                        }
                        If(lstExpressionRows != null)
                            ActnExpDetailSize = Math.Round(lstExpressionRows.size());
                        for( integer j=1; j < lstExpressionRows.size() + 1; j++ )
                        {
                            if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(j) != null )
                            {    
                                Map_SequenceNumRec.get(j).SVMXC__Sequence__c = Math.Round(Map_SequenceNumRec.get(j).SVMXC__Sequence__c);
                                ModifiedExpressionDetailLst.add(Map_SequenceNumRec.get(j));
                            }
                        }
                        actnexpwrapperObj = new ExpressionWrapper(lstNamedExpDefintion[0], ModifiedExpressionDetailLst, true, false);
                        if(actnexpwrapperObj.ExpDetailLst != null)
                            ActnExpDetailSize = actnexpwrapperObj.ExpDetailLst.size();
                        editActionWrapperObject.expHeaderDetailRec = actnexpwrapperObj;
                }
            }
            else if(editActionWrapperObject.SelectedCriteriaToEnable == 'ServiceMax_None' || editActionWrapperObject.isSFWActionCriteraNew)
            {
                editActionWrapperObject.expHeaderDetailRec = null;
                renderTab2ExprBlock = false;
            }
        return null;
    }

    //------------------------------------------- Method to sort the Fields --------------------------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            if(!(tempLst.ContainsKey(SO.getLabel().toUpperCase())))//added for defect 11667 (SFM with same name problem)
                tempLst.put(SO.getLabel().toUpperCase(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel().toUpperCase()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }

    public Boolean disableOnView = false;
    public Boolean getdisableOnView(){ return disableOnView; }

    

    /* Expression methods start her */

    /* Expression Wrapper object for the current Wizard */
    public void setexpwrapperObj(ExpressionWrapper value){ this.expwrapperObj = value; }
    public ExpressionWrapper getexpwrapperObj(){ return expwrapperObj;}
    public ExpressionWrapper expwrapperObj = null;//new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);

    /* Expression Wrapper object for the current Wizard step*/
    public ExpressionWrapper actnexpwrapperObj = new ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(), new List<SVMXC__ServiceMax_Config_Data__c>(), true, false);
    public void setactnexpwrapperObj(ExpressionWrapper value){ this.actnexpwrapperObj = value; }
    public ExpressionWrapper getactnexpwrapperObj(){ return actnexpwrapperObj;}


    RecordType ExpressionHeader_Rtype;
    RecordType ExpressionsDetail_Rtype;
    //Field List for selected object
    public List<SelectOption> Hdrfldlist = new List<SelectOption>();
    public List<SelectOption> getHdrfldlist(){return Hdrfldlist;}

    //Sequence no. of the record currently dealing with - Related methods
        public string SelectedIndex;
        public string getSelectedIndex (){return this.SelectedIndex;}
        public void setSelectedIndex (string str){this.SelectedIndex = str;}

    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();

    public List<SelectOption> getOperatorSelectLst()
    {
        return OperatorSelectLst;
    }
    public Integer ExpDetailSize = 0;
    public Integer getExpDetailSize()
    { 
        return ExpDetailSize;
    }

    public void HdrADDRow()
    {
        try
        {
            if( expwrapperObj != null && expwrapperObj.ExpDetailLst != null )
            {
                SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( expwrapperObj.ExpDetailLst.size() + 1 ) );
                Map_SequenceNumRec.put( Math.Round(Integer.valueOf( expwrapperObj.ExpDetailLst.size() + 1 )), NewExpDetailRec );
                expwrapperObj.ExpDetailLst.add( NewExpDetailRec );
                if(expwrapperObj.ExpDetailLst != null)
                    ExpDetailSize = expwrapperObj.ExpDetailLst.size();
                else
                    ExpDetailSize = 0;
                        if( ExpDetailSize == 0 )
                                expwrapperObj.ExpDetailLst.clear();
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void ActnHdrADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( actnexpwrapperObj.ExpDetailLst.size() + 1 ) );
            Map_SequenceNumRec.put( Math.Round(Integer.valueOf( actnexpwrapperObj.ExpDetailLst.size() + 1 )), NewExpDetailRec );
            actnexpwrapperObj.ExpDetailLst.add( NewExpDetailRec );
            if(actnexpwrapperObj.ExpDetailLst != null)
                ActnExpDetailSize = actnexpwrapperObj.ExpDetailLst.size();
            else
                ActnExpDetailSize = 0;
            if( ActnExpDetailSize == 0 )
                    actnexpwrapperObj.ExpDetailLst.clear();
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }

    //Method which displays exception on page as required
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
    }
    
    
    //Method which checks if string is valid or not
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    public void HdrDeleteRow()
    { 
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < expwrapperObj.ExpDetailLst.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != Math.Round(integer.valueOf(SelectedIndex)) )
                {
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, expwrapperObj.ExpDetailLst[i] );
                }
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == Math.Round(integer.valueOf(SelectedIndex))) )  
                {
                    SeqNumToSubtract = 1;
                }
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
            {
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            }
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            expwrapperObj.ExpDetailLst.clear();
            expwrapperObj.ExpDetailLst.addAll(Temp_ExpDetailsLst);
            
            if(expwrapperObj.ExpDetailLst != null)
                ExpDetailSize = expwrapperObj.ExpDetailLst.size();
            else
                ExpDetailSize = 0;
                    
                    if( ExpDetailSize == 0){
                            expwrapperObj.ExpDetailLst.clear();
                    }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }

    public void ActnHdrDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            for( integer i=0; i < actnexpwrapperObj.ExpDetailLst.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != Math.Round(integer.valueOf(SelectedIndex)) )
                {
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, actnexpwrapperObj.ExpDetailLst[i] );
                }
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == Math.Round(integer.valueOf(SelectedIndex))) )  
                {
                    SeqNumToSubtract = 1;
                }
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
            {
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            }
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            actnexpwrapperObj.ExpDetailLst.clear();
            actnexpwrapperObj.ExpDetailLst.addAll(Temp_ExpDetailsLst);
            
            if(actnexpwrapperObj.ExpDetailLst != null)
                ActnExpDetailSize = actnexpwrapperObj.ExpDetailLst.size();
            else
                ActnExpDetailSize = 0;
            if( ActnExpDetailSize == 0)
            {
                actnexpwrapperObj.ExpDetailLst.clear();
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }

    public String getObjLabel()
    {
        if( ObjectName != null && ObjectName != '' )
        {
            COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);//manish
            MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();//manish
            String APIName = ObjName_util.getOriginalAPIName(ObjectName, allObjs);
            if( APIName != null && allObjs.get(APIName) != null ) 
            {
                //populate the field list for the selected object
                Hdrfldlist.clear();
                Hdrfldlist.add(new SelectOption('SVMX.NONE',getTag041()));
                WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
                DispMethods.RetriveField(ObjectName, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
                return getTAG0007() +' ' + allObjs.get(APIName).getDescribe().getlabel();
            }
            else
                return getTAG0007();
        }
        else
            return getTAG0007();
    }

    public List<CONF_SetupServiceFlowWizard.SvmxActionWrapper> SaveExpression(List<CONF_SetupServiceFlowWizard.SvmxActionWrapper> request)
    {
        if(request != NULL && request.size() > 0)
        {
            Savepoint sp = Database.setSavepoint();
            SVMXC.SFM_saveExpression clsSave = new SVMXC.SFM_saveExpression();
            SFM_WrapperDef.SFM_Response saveResponseExp;
            Boolean isRollBack = false;
            System.debug(logginglevel.info, 'request : ' + request);
            for(CONF_SetupServiceFlowWizard.SvmxActionWrapper action: request)
            {
                if(action.expHeaderDetailRec != NULL )
                {
                    CONF_SetupServiceFlowWizard.ExpressionWrapper expression = action.expHeaderDetailRec;
                    List<SFM_WrapperDef.SFM_Expression> lstSFMExpression = new List<SFM_WrapperDef.SFM_Expression>();
                    if(expression != null && expression.ExpHeader != null && expression.ExpDetailLst != null && expression.ExpHeader.SVMXC__IsStandard__c != true && QuickSaveSuccessful)
                    {
                        if( expression.ExpHeader.SVMXC__Name__c == null || expression.ExpHeader.SVMXC__Name__c == '' )
                        {
                            expression.ExpHeader.SVMXC__Name__c.addError(getTAG0011());
                            QuickSaveSuccessful = false;
                        }

                        if(expression.ExpHeader.SVMXC__ProcessID__c == null || expression.ExpHeader.SVMXC__ProcessID__c == '' || (expression.ExpHeader.SVMXC__ProcessID__c).length() < 8)
                        {
                            QuickSaveSuccessful = false;
                            expression.ExpHeader.SVMXC__ProcessID__c.addError(getTAG0012());
                        }
                        if(QuickSaveSuccessful)
                        {
                        
                            if(expression.ExpDetailLst.size() > 0)
                            {
                                for(Integer i =0 ; i <=  expression.ExpDetailLst.size()-1 ; i++)
                                {
                                    if(expression.ExpDetailLst[i].SVMXC__Operator__c == 'SVMX.NONE' &&  expression.ExpDetailLst[i].SVMXC__Field_Name__c == 'SVMX.NONE')
                                    {
                                        expression.ExpDetailLst.remove(i);
                                        i--;
                                    }
                                }
                            }
                            if(expression.ExpDetailLst.size() > 0)
                            {
                                expression.ExpHeader.SVMXC__SettingId__c = expression.ExpHeader.SVMXC__ProcessID__c;
                                expression.ExpHeader.SVMXC__Source_Object_Name__c = objectName;
                                lstSFMExpression.add(new SFM_WrapperDef.SFM_Expression(expression.ExpHeader, expression.ExpDetailLst));
                                SFM_WrapperDef.SFM_Request_Expression expressionRequest = new SFM_WrapperDef.SFM_Request_Expression(lstSFMExpression);
                                saveResponseExp = new SFM_WrapperDef.SFM_Response();
                                saveResponseExp = clsSave.SFM_saveExpression(expressionRequest);
                                
                                if(saveResponseExp.success == false)
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, action.SvmxActionRec.SVMXC__Name__c + ':' + saveResponseExp.message, ''));
                                    isRollBack = true;
                                    break;
                                }
                                else
                                {
                                    if(saveResponseExp != null && saveResponseExp.resultIds != null && saveResponseExp.resultIds.size() > 0)
                                    {
                                        action.SelectedCriteriaToEnable = saveResponseExp.resultIds[0];
                                        action.expHeaderDetailRec = null;
                                    }
                                }
                                expression.expressionSaveResponse = saveResponseExp;
                            }
                            else
                            {
                                ActnHdrADDRow();
                                ActnHdrADDRow();
                                isRollBack = true;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, expression.ExpHeader.SVMXC__Name__c + ':' + getTAG096(), ''));
                                break;
                            }
                        }
                    }
                }
            }
            system.debug(logginglevel.warn,'isRollBack : '+isRollBack);
            if(isRollBack == true)
            {
                Database.rollback(sp);
                QuickSaveSuccessful = false;
            }
        }
        return request;
    }
/* Expression methods end here */

//-------New Method for resolving defect 010398 to setting strTranslatedActionType in wrapper object based on SVMXC__Action_Type__c--------
//added by Manish
    private String getTranslatedCustomLabel(SVMXC__ServiceMax_Processes__c objActionRecord){
        if(objActionRecord.SVMXC__Action_Type__c == 'SFM')
            return getTAG073();
        else if(objActionRecord.SVMXC__Action_Type__c == 'INVENTORY')
            return getTAG075();
        else if(objActionRecord.SVMXC__Action_Type__c == 'RECEIPT')
            return getTAG077();
        else if(objActionRecord.SVMXC__Action_Type__c == 'DELIVERY')
            return getTAG078();
        else if(objActionRecord.SVMXC__Action_Type__c == 'PICK_MOVE')
            return getTAG080();
        else if(objActionRecord.SVMXC__Action_Type__c == 'SHIP')
            return getTAG079();
        else if(objActionRecord.SVMXC__Action_Type__c == 'FULFILLMENT')
            return getTAG083();
        else if(objActionRecord.SVMXC__Action_Type__c == 'OTHERS')
            return getTAG076();
        else if(objActionRecord.SVMXC__Action_Type__c == 'OUTPUT_DOCUMENT')
            return getTAG095();
        else if(objActionRecord.SVMXC__Action_Type__c == 'INITIATE_RETURN')
            return getTAG081();
        else if(objActionRecord.SVMXC__Action_Type__c == 'CHECKLIST')
            return 'Checklist';            
        return '';
    }
//---------------------------------------------------------------------------------------------------------------
    // Custom labels

    public String getTag001(){ return system.label.CONF016_TAG030 ;}//'Quick Save'
    public String getTag002(){ return system.label.CONF016_TAG031 ;}//'Save & close'
    public String getTag003(){ return system.label.CONF016_TAG032 ;}//'Cancel'
    public String getTag004(){ return system.label.CONF016_TAG033 ;}//'Action Title'
    public String getTag005(){ return system.label.CONF016_TAG016 ;}//'SFW Id'//CONF016_TAG034
    public String getTag006(){ return system.label.CONF016_TAG035 ;}//'Description'
    public String getTag007(){ return system.label.CONF016_TAG036 ;}//'Show/Hide Criteria'
    public String getTag008(){ return system.label.CONF016_TAG040 ;} //CONF016_TAG037 ;}//'Edit Criteria'
    public String getTag009(){ return system.label.CONF016_TAG038 ;}//'Manage Actions >>'
    public String getTag010(){ return system.label.CONF016_TAG039 ;}//'New'
    public String getTag011(){ return system.label.CONF016_TAG040 ;}//'Edit'
    public String getTag012(){ return system.label.CONF016_TAG041 ;}//'Save'
    public String getTag013(){ return system.label.CONF016_TAG042 ;}//'Delete'
    public String getTag014(){ return system.label.CONF016_TAG043 ;}//'Sequence'
    public String getTag015(){ return system.label.CONF016_TAG044 ;}//'Cancel'
    public String getTag016(){ return system.label.CONF016_TAG045 ;}//'Use this section to define one or more actions in SFW.'
    public String getTag017(){ return system.label.CONF016_TAG046 ;}//'Select'
    public String getTag018(){ return system.label.CONF016_TAG047 ;}//'Sequence No.'
    public String getTag019(){ return system.label.CONF016_TAG048 ;}//'Action'
    public String getTag020(){ return system.label.CONF016_TAG049 ;}//'Criteria to Enable this Action'
    public String getTag021(){ return system.label.CONF016_TAG050 ;}//'<< General Information'
    public String getTag022(){ return system.label.CONF016_TAG051 ;}//'Manage Permissions >>'
    public String getTag023(){ return system.label.CONF016_TAG052 ;}//Move ServiceMax Group Profiles from Available list to Selected list to enable access for this Service Flow Wizard, 'Select ServiceMax Group Profile in the right list to enable access for this SFW'
    public String getTag024(){ return system.label.CONF016_TAG053 ;}//'Set the permissions for SFW as'
    public String getTag025(){ return system.label.CONF016_TAG054 ;}//'<< Manage Actions'
    public String getTag026(){ return system.label.CONF016_TAG055 ;}//'Configure SFW for '
    public String getTag027(){ return system.label.CONF016_TAG056 ;}//'Configure SFW'
    public String getTag028(){ return system.label.CONF016_TAG057 ;}// 'SFW Name cannot be left blank.';}
    public String getTag029(){ return system.label.CONF016_TAG058 ;}// 'SFW Id cannot be left blank.';}
    public String getTag030(){ return system.label.CONF016_TAG059 ;}// 'SFW Record saved successfully.';}
    public String getTag031(){ return system.label.CONF016_TAG060 ;}// 'Please select at least one profile in available list to move.';}
    public String getTag032(){ return system.label.CONF016_TAG060 ;}// 'Please select at least one profile in selected list to move.';}//CONF016_TAG061
    public String getTag033(){ return system.label.CONF016_TAG062 ;}// 'Please select an action to edit.';}
    public String getTag034(){ return system.label.CONF016_TAG063 ;}// 'Please select only one action to edit.';}
    public String getTag035(){ return system.label.CONF016_TAG062 ;}// 'Please select a record to delete.';}
    public String getTag036(){ return system.label.CONF016_TAG064 ;}// 'Please select a valid action in the Action Picklist.';}
    public String getTag037(){ return system.label.CONF016_TAG065 ;}// 'Please Enter a valid Title for the Selected Action Record.';}
    public String getTag038(){ return system.label.CONF016_TAG065 ;}// 'Please enter a valid title.';}
    public String getTag039(){ return system.label.CONF016_TAG066 ;}// 'Action Record created successfully.';}
    public String getTag040(){ return system.label.CONF016_TAG062 ;}// 'Please select an action.';}
    public String getTAG041(){return system.label.CONF016_TAG067 ;}//'--None--';}//--None--
    public String getTAG042(){return system.label.CONF016_TAG068 ;}//'Source Object';} //Source Object //Object
    public String getTAG043(){return system.label.CONF016_TAG001 ;}//'Please select a valid source object for which SFW is being defined';}//TAG034
    public String getTAG044(){return system.label.CONF016_TAG069 ;}//'Please define atleast one action for the selected SFW';}
    public String getTAG045(){return system.label.CONF016_TAG028 ;}//'General Information';}
    public String getTAG046(){return system.label.CONF016_TAG026 ;}//'Manage permissions';}
    public String getTAG047(){return system.label.CONF016_TAG004 ;}//'Manage actions';}
    public String getTAG048(){return system.label.CONF016_TAG075 ;}//help title//CONF016_TAG080
    public String getTAG049(){return system.label.CONF016_HLPURL2 ;}//help url
    public String getTAG050(){return system.label.CONF016_TAG020 ;}//Create Service Flow Wizard //title changed
    public String getTAG051(){return system.label.CONF016_TAG021 ;}//Edit Service Flow Wizard //title changed
    public String getTAG052(){return system.label.CONF016_TAG024 ;}//processing....
    public String getTAG053(){return system.label.CONF016_TAG017 ;}//wizard title
    public String getTAG054(){return system.label.CONF016_TAG080 ;}//Please enter a unique Process Id for the SFW
    public String getTAG055(){return system.label.CONF016_TAG055 ;}//successfully deleted
    public String getTAG056(){return system.label.CONF016_TAG079 ;}//'Is Active'
    public String getTAG057(){return system.label.CONF016_TAG034 ;}//'Add New'
    public String getTAG058(){return system.label.CONF016_TAG037 ;}//'Available ServiceMax Group Profiles'
    public String getTAG059(){return system.label.CONF016_TAG056 ;}//'Selected ServiceMax Group Profiles'
    //public String getTag057(){return 'Permissions saved successfully' ;}
    public String getTAG060(){return system.label.CONF016_TAG081;}
    public String getTAG061(){return system.label.CONF016_TAG082;}
    public String getTAG062(){return system.label.CONF016_TAG083;}
    public String getTAG063(){return system.label.CONF016_TAG084;}
    public String getTAG064(){return system.label.CONF016_TAG085;}
    public String getTAG065(){return system.label.CONF016_TAG086;}
    public String getTAG066(){return system.label.CONF016_TAG087;}
    public String getTAG067(){return system.label.CONF016_TAG088;}
    public String getTAG068(){return system.label.CONF016_TAG089;}
    public String getTAG069(){return system.label.CONF016_TAG090;}
    public String getTAG070(){return system.label.CONF016_TAG091;}
    public String getTAG071(){return system.label.CONF016_TAG092;}
    public String getTAG072(){return system.label.CONF016_TAG093;}
    
    public String getTAG073(){return system.label.CONF016_TAG094;}//SFM
    public String getTAG074(){return 'Background Execution';}//Background Execution
    public String getTAG075(){return system.label.CONF016_TAG096;}//Inventory
    public String getTAG076(){return system.label.CONF016_TAG097;}//Others
    public String getTAG077(){return system.label.CONF016_TAG098;}//Receiving Process
    public String getTAG078(){return system.label.CONF016_TAG099;}//Delivery Process
    public String getTAG079(){return system.label.CONF016_TAG100;}//Shipping Process
    public String getTAG080(){return system.label.CONF016_TAG101;}//Picking Process
    public String getTAG081(){return system.label.CONF016_TAG102;}//Initiate Returns
    public String getTAG082(){return system.label.CONF016_TAG061;}//Wizard Step Type
    public String getTAG083(){return system.label.CONF016_TAG103;}//Fulfillment Process
    public String getTAG084(){return system.label.CONF016_TAG104;}//Mode Of Execution
    public String getTAG085(){return system.label.CONF016_TAG105;}//Handover
   
    
    //Named Expression tags
    public String getTAG0001(){ return  System.Label.CONF017_TAG001;}//'Save'
    public String getTAG0002(){ return  System.Label.CONF017_TAG002;}//'Cancel'
    public String getTAG0003(){ return  System.Label.CONF017_TAG003;}//'Expression Name'
    public String getTAG0004(){ return  System.Label.CONF017_TAG004;}//'Unique Id'
    public String getTAG0005(){ return  System.Label.CONF017_TAG005;}//'Advanced Expression'
    public String getTAG0006(){ return  System.Label.CONF017_TAG006;}//'Error message to display if a record does not meet the above criteria'//Field Name
    public String getTAG0007(){ return  System.Label.CONF017_TAG007;}//'Define expression for '
    public String getTAG0008(){ return  System.Label.CONF017_TAG008;}//'Define expression'//Processing...
    public String getTAG0009(){ return  System.Label.CONF017_TAG009;}//'Expression Record Saved successfully'
    public String getTAG0010(){ return  System.Label.CONF017_TAG010;}//'Internal Error Occured, Please Try Later'
    public String getTAG0011(){ return  System.Label.CONF017_TAG011;}//'Please enter a valid Expression Name'
    public String getTAG0012(){ return  System.Label.CONF017_TAG012;}//'Expression Id should be atleast 8 characters long'
    public String getTAG0013(){ return  System.Label.CONF017_TAG016; }//help title
    public String getTAG0014(){ return  System.Label.CONF017_HLPURL1; }//help url
    public String getTAG0015(){ return  System.Label.CONF017_TAG014; }//Operator
    public String getTAG0016(){ return  System.Label.CONF017_TAG018; }//Operand or Value
    public String getTAG086(){return System.Label.CONF016_TAG106;}// 'Confirm on Launch'
    public String getTAG087(){return System.Label.CONF016_TAG107;}//'Confirmation Message'
    public String getTAG088() {return System.Label.COMM001_TAG077;}//'An unexpected error occurred. Please contact your ServiceMax Administrator.'
    public String getTAG089() {return System.Label.COMM001_TAG059;}//'please enter all mendatary field'
    public String getTAG090() {return System.Label.CONF016_TAG108;}//'Perform Synch After WS Call'
    public String getTAG091() {return System.Label.COMM001_TAG057;}//'Are You Sure?'
    public String getTAG092() {return System.Label.COMM001_TAG036;}//'Add'
    public String getTAG093() {return System.Label.CONF016_TAG111;}//'Select Template At Runtime'
    public String getTAG094() {return System.Label.CONF016_TAG013;}//'
    public String getTAG095() {return System.Label.CONF016_TAG112;}//'Output Doc'
    public String getTAG096() {return System.Label.COMM002_TAG004;}// invalid expression
    public String getTag097() { return System.label.CONF016_TAG116 ;}//'Step Properties'
    public String getTag098() { return System.label.CONF016_TAG117 ;}//'Step Name'
    public String getTag099() { return System.label.CONF016_TAG118 ;}//'Step ID'
    public String getTag100() { return System.label.CONF016_TAG120 ;}//'Checklist'
}