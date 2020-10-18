public with sharing class CONF_SetupServiceFlowWizardLayout {

    //Picklist and related getter setter methods
    List<SelectOption> ObjectsOptns = new  List<SelectOption>();
    public List<SelectOption> getObjectsOptns()
    {
        return ObjectsOptns;
    }
    
    Public String SelectedObject;
    public String getSelectedObject(){
        return SelectedObject;
    } 
    public void setSelectedObject(String val){
        //SelectedObject = val; //Commented for security fix
        SelectedObject = String.escapeSingleQuotes(val); //Added for security fix
    }
    //Global Describe
    public Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();

    
    
    public List<SelectOption> AllsfwOptns = new List<SelectOption>();
    public List<SelectOption> getAllsfwOptns(){return this.AllsfwOptns;}
    
    public List<SVMXC__ServiceMax_Processes__c> AllsfwRecs = new List<SVMXC__ServiceMax_Processes__c>();
    public List<ServiceMax_Config_Data__c> sfwLayoutRecs_SelectedObject = new List<ServiceMax_Config_Data__c>();
    
    /* Maps for UI creation - Starts here*/
    public Map<String,String> Map_RowNumColNum_SelectedPicklistId = new Map<String,String>();
    public Integer HighestRowNum = 0;
    public Map<String, SVMXC__ServiceMax_Config_Data__c> MapsfwLayoutId_Rec = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
    /* Maps for UI creation - Ends here*/
    
    public List<SVMXC__ServiceMax_Config_Data__c> sfwLayoutRecs_Column1 = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> sfwLayoutRecs_Column2 = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getsfwLayoutRecs_Column1(){return sfwLayoutRecs_Column1;}
    public List<SVMXC__ServiceMax_Config_Data__c> getsfwLayoutRecs_Column2(){return sfwLayoutRecs_Column2;}
    public void setsfwLayoutRecs_Column1(List<SVMXC__ServiceMax_Config_Data__c> val){this.sfwLayoutRecs_Column1 = val;}
    public void setsfwLayoutRecs_Column2(List<SVMXC__ServiceMax_Config_Data__c> val1){this.sfwLayoutRecs_Column2 = val1;}
    RecordType Rtype_SVMX_sfw_Layout;
    Map<String,String> Map_sfwId_Name = new Map<String,String>();
    Map<String,String> Map_sfwId_ProcessId = new Map<String,String>();
    public CONF_SetupServiceFlowWizardLayout(){
        String UrlObjectName = System.currentPageReference().getParameters().get('SVMX_ObjectName');
        AllsfwOptns.add(new SelectOption('ServiceMax_None',getTag009()));
        Rtype_SVMX_sfw_Layout = [Select Id, Name, SObjectType from RecordType where Name = 'Wizard Layout' and  SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if( UrlObjectName != null && UrlObjectName != '' )
            SelectedObject = String.escapeSingleQuotes(UrlObjectName);
        ButtonsizeObj = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_SVMX_sfw_Layout.Id);

        /* Source Object Picklist creation starts here */
        COMM_Utils commUtils = new COMM_Utils();
        Map<String,String> Map_ObjName_Label = new Map<String,String>();
        allObjs = Schema.getGlobalDescribe();
        for(String key: allObjs.keySet())
        {
            Schema.SObjectType objT = allObjs.get(key) ;
            String CurrentObjName = objT.getDescribe().getName();
            if(!((CurrentObjName.toUpperCase()).Contains('__SHARE')) && !((CurrentObjName.toUpperCase()).Contains('__FEED')) && !((CurrentObjName.toUpperCase()).Contains('__HISTORY')) && objT.getDescribe().isAccessible())
                Map_ObjName_Label.put(CurrentObjName,objT.getDescribe().getLabel());
        }

        //Create Instance of the class sfw_Utils
        ServiceFlowWizard_Utils sfwUtils = new ServiceFlowWizard_Utils();
        
        Map<String,List<SVMXC__ServiceMax_Processes__c>> Map_ObjName_RelatedsfwRecs = new Map<String,List<SVMXC__ServiceMax_Processes__c>>();
        Map_ObjName_RelatedsfwRecs = sfwUtils.SVMX_GetObjNamesNsfwRecs('All');
        if( UrlObjectName != null && UrlObjectName != '')
            SelectedObject = String.escapeSingleQuotes(UrlObjectName);
        ObjectsOptns.add(new SelectOption('ServiceMax_None',getTag009()));
        
        for(String Current_objname :Map_ObjName_RelatedsfwRecs.keyset())
        {
            if( Map_ObjName_Label != null && Map_ObjName_Label.containsKey(Current_objname) )
                ObjectsOptns.add(new SelectOption(Current_objname, Map_ObjName_Label.get(Current_objname)));
                
        }
        ObjectsOptns = sortingSelectOption(ObjectsOptns);
        /* Source Object Picklist creation ends here */
        RedrawLayout();
    }

    public Boolean continueQuickSave = true;
    public Boolean getcontinueQuickSave(){ return continueQuickSave; }
    public Set<Id> RecIdsToDelete = new Set<Id>();
        public List<SVMXC__ServiceMax_Config_Data__c> Temp_sfwLayoutLstCol1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        public List<SVMXC__ServiceMax_Config_Data__c> Temp_sfwLayoutLstCol2 = new List<SVMXC__ServiceMax_Config_Data__c>();
        public Map<String,String> Map_sfwRecIdsSelctdInLayout = new Map<String,String>();
        public List<SVMXC__ServiceMax_Config_Data__c> sfwLayout_ListToUpsert = new List<SVMXC__ServiceMax_Config_Data__c>();
        public String validationOnSave(){
        continueQuickSave = true;
        if(SelectedObject == null || SelectedObject == 'ServiceMax_None')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTag016()));
            continueQuickSave = false;
            return null;
        }
        Temp_sfwLayoutLstCol1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        Temp_sfwLayoutLstCol2 = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map_sfwRecIdsSelctdInLayout = new Map<String,String>();
        sfwLayout_ListToUpsert = new List<SVMXC__ServiceMax_Config_Data__c>();
        //Boolean continueQuickSave = true;
        RecIdsToDelete = new Set<Id>();
        for( SVMXC__ServiceMax_Config_Data__c sfwLayoutRec : sfwLayoutRecs_Column1 )
        {
            String TempDpId = sfwLayoutRec.SVMXC__Dispatch_Process__c;
            String CurrentRecId = '';
            CurrentRecId = sfwLayoutRec.Id;
            if( TempDpId != null && !((TempDpId).contains('ServiceMax_None')) )
            {
               /* if ((TempDpId).contains('ServiceMax_None'))
                {
                    continueQuickSave = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Invalid sfw Selected: None'));
                    //sfwLayout_ListToDelete.add(sfwLayoutRec);
                    break;
                }
                else
                {
                */
                    if( !(Map_sfwRecIdsSelctdInLayout.containsKey(TempDpId)))
                    {
                        Map_sfwRecIdsSelctdInLayout.put( TempDpId, TempDpId);
                        Temp_sfwLayoutLstCol1.add(sfwLayoutRec);
                    }
                    else 
                    {
                        continueQuickSave = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A sfw can\'t be used more than once in sfw layout: ' + ' - '+ Map_sfwId_ProcessId.get(sfwLayoutRec.SVMXC__Dispatch_Process__c) + ' - '+ Map_sfwId_Name.get(sfwLayoutRec.SVMXC__Dispatch_Process__c),''));
                        break;
                    }
                //}
            }
            else if( TempDpId != null && ((TempDpId).contains('ServiceMax_None')) &&  CurrentRecId != null && CurrentRecId != '' )
                RecIdsToDelete.add(sfwLayoutRec.Id);
        }
        if( ButtonsizeObj.Button_Size__c == null || ButtonsizeObj.Button_Size__c == '' ) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTag015(),''));
            continueQuickSave = false;
        }
        for( SVMXC__ServiceMax_Config_Data__c sfwLayoutRec : sfwLayoutRecs_Column2 )
        {
            String CurrentRecId = '';
            CurrentRecId = sfwLayoutRec.Id;
            if(continueQuickSave)
            {
                String TempDpId = sfwLayoutRec.SVMXC__Dispatch_Process__c;
                if( TempDpId != null && !((TempDpId).contains('ServiceMax_None')) )
                {
                   /* if((TempDpId).contains('ServiceMax_None'))
                    {
                        continueQuickSave = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid sfw Selected: None'));
                        break;
                    }
                    else
                    {
                    */
                        if(!(Map_sfwRecIdsSelctdInLayout.containsKey(TempDpId)))
                        {
                            Map_sfwRecIdsSelctdInLayout.put(sfwLayoutRec.SVMXC__Dispatch_Process__c,sfwLayoutRec.SVMXC__Dispatch_Process__c);
                            Temp_sfwLayoutLstCol2.add(sfwLayoutRec);
                        }
                        else
                        {
                            continueQuickSave = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A sfw can\'t be used more than once in sfw layout: '+ Map_sfwId_ProcessId.get(sfwLayoutRec.SVMXC__Dispatch_Process__c) + ' - '+  Map_sfwId_Name.get(sfwLayoutRec.SVMXC__Dispatch_Process__c),''));
                            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Confirm,'Closed'+String.valueOf(continueQuickSave),'')); 
                            break;
                        }
                    //}
                }
                else if( ((TempDpId).contains('ServiceMax_None')) &&  CurrentRecId != null && CurrentRecId != '' )
                    RecIdsToDelete.add(sfwLayoutRec.Id);
                //else
                //    break;
            }
        }
        return null;
    }
    public pagereference QuickSave()
    {
        validationOnSave();
        if(continueQuickSave)
        {
            Savepoint sp;
            try
            {
                sp = Database.setSavepoint();
                if( RecIdsToDelete != null && RecIdsToDelete.size() > 0 )
                        Delete [Select Id from SVMXC__ServiceMax_Config_Data__c where Id IN :RecIdsToDelete];
                if( Temp_sfwLayoutLstCol1 != null && Temp_sfwLayoutLstCol1.size() > 0 )
                {
                    for(integer i = 1; i <= Temp_sfwLayoutLstCol1.size(); i++)
                    {
                        Temp_sfwLayoutLstCol1[i - 1].SVMXC__Wizard_Layout_Row__c = i;
                        Temp_sfwLayoutLstCol1[i - 1].SVMXC__Wizard_Layout_Column__c = 1;
                        Temp_sfwLayoutLstCol1[i - 1].SVMXC__Button_size__c = ButtonsizeObj.SVMXC__Button_size__c;
                    }
                    sfwLayout_ListToUpsert.addAll(Temp_sfwLayoutLstCol1);
                }
                if( Temp_sfwLayoutLstCol2 != null && Temp_sfwLayoutLstCol2.size() > 0 )
                {
                    for(integer i = 1; i <=Temp_sfwLayoutLstCol2.size(); i++)
                    {
                        Temp_sfwLayoutLstCol2[i - 1].SVMXC__Wizard_Layout_Row__c = i;
                        Temp_sfwLayoutLstCol2[i - 1].SVMXC__Wizard_Layout_Column__c = 2;
                        Temp_sfwLayoutLstCol2[i - 1].SVMXC__Button_size__c = ButtonsizeObj.SVMXC__Button_size__c;
                    }
                    sfwLayout_ListToUpsert.addAll(Temp_sfwLayoutLstCol2);
                }
                //upsert sfwLayout_ListToUpsert;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( sfwLayout_ListToUpsert, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert sfwLayout_ListToUpsert; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                RedrawLayout();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTag011(),''));
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getmessage(),''));
                Database.rollback(sp);
            }
        }
        else
        {
            Map_sfwRecIdsSelctdInLayout.clear();
            sfwLayout_ListToUpsert.clear();
        }
        return null;
    }
    public pagereference Preview()
    {
        validationOnSave();
        if(continueQuickSave)
        {
            //if( RecIdsToDelete != null && RecIdsToDelete.size() > 0 )
            //Delete [Select Id from SVMXC__ServiceMax_Config_Data__c where Id IN :RecIdsToDelete];
            /*for(String RecIdToRemoveFromLayout :RecIdsToDelete )
            {
                //if( RecIdsToDelete != null && RecIdsToDelete.size() > 0 )
                        if( Temp_sfwLayoutLstCol1.contains(RecIdToRemoveFromLayout) )
                                                Temp_sfwLayoutLstCol1.remove(RecIdToRemoveFromLayout);
                                        if( Temp_sfwLayoutLstCol2.contains(RecIdToRemoveFromLayout) )
                                                Temp_sfwLayoutLstCol1.remove(RecIdToRemoveFromLayout);
            }*/
            if( Temp_sfwLayoutLstCol1 != null && Temp_sfwLayoutLstCol1.size() > 0 )
            {
                for(integer i = 1; i <= Temp_sfwLayoutLstCol1.size(); i++)
                {
                    Temp_sfwLayoutLstCol1[i - 1].SVMXC__Wizard_Layout_Row__c = i;
                    Temp_sfwLayoutLstCol1[i - 1].SVMXC__Wizard_Layout_Column__c = 1;
                    Temp_sfwLayoutLstCol1[i - 1].SVMXC__Button_size__c = ButtonsizeObj.SVMXC__Button_size__c;
                }
                sfwLayout_ListToUpsert.addAll(Temp_sfwLayoutLstCol1);
            }
            if( Temp_sfwLayoutLstCol2 != null && Temp_sfwLayoutLstCol2.size() > 0 )
            {
                for(integer i = 1; i <=Temp_sfwLayoutLstCol2.size(); i++)
                {
                    Temp_sfwLayoutLstCol2[i - 1].SVMXC__Wizard_Layout_Row__c = i;
                    Temp_sfwLayoutLstCol2[i - 1].SVMXC__Wizard_Layout_Column__c = 2;
                    Temp_sfwLayoutLstCol2[i - 1].SVMXC__Button_size__c = ButtonsizeObj.SVMXC__Button_size__c;
                }
                sfwLayout_ListToUpsert.addAll(Temp_sfwLayoutLstCol2);
            }
            //RedrawLayout();
            //PreviewLayout();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTag011(),''));// displayPreview = true;
        }
        else
        {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTag011(),''));// 
            Map_sfwRecIdsSelctdInLayout.clear();
            sfwLayout_ListToUpsert.clear();
        }
        return null;
    }
    public pagereference AddRow(){
        HighestRowNum ++;
        sfwLayoutRecs_Column1.add(new 
                    SVMXC__ServiceMax_Config_Data__c(SVMXC__Wizard_Layout_Row__c = HighestRowNum, 
                            SVMXC__Wizard_Layout_Column__c = 1,RecordTypeId=Rtype_SVMX_sfw_Layout.Id,
                            SVMXC__Object_Name__c = SelectedObject ));
        sfwLayoutRecs_Column2.add(new 
                    SVMXC__ServiceMax_Config_Data__c(SVMXC__Wizard_Layout_Row__c = HighestRowNum, 
                            SVMXC__Wizard_Layout_Column__c = 1,RecordTypeId=Rtype_SVMX_sfw_Layout.Id,
                            SVMXC__Object_Name__c = SelectedObject ));

        return null;
    }
    
    public pagereference SaveNClose(){
        
        QuickSave();
        if(continueQuickSave)
        {
            //Do the Save operation here
            //On success of save, do the Close opertaion here
            String loc1;
            if( SelectedObject != 'None' ){
                String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes
                loc1 = baseURL + '/apex/SVMXC__CONF_ManageServiceFlowWizard?SVMX_ObjectName='+SelectedObject;
            }
            PageReference pr1 = new PageReference(loc1);
            pr1.setRedirect(true);
            return pr1;
        }
        else
            return null;
    }
    public pagereference Cancel(){
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes
        String loc1 = '/apex/SVMXC__CONF_ManageServiceFlowWizard?SVMX_ObjectName='+SelectedObject;
        //PageReference pr1 = new PageReference(loc1); //Commented for the Security fixes
        PageReference pr1 = new PageReference(baseURL + loc1);
        pr1.setRedirect(true);
        return pr1;
    }
    
    public pagereference BackToSetupHome(){
        //String loc2 = '/apex/SVMXC__CONF_SetupHome';
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String loc2 ='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            loc2 = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            loc2 ='/apex/SVMXC__CONF_SetupHome';
        }
        //Changes done by Nidhi ends here
        PageReference pr2 = new PageReference(loc2);
        pr2.setRedirect(true);
        return pr2;
    }
    public SVMXC__ServiceMax_Config_Data__c ButtonsizeObj;

    public SVMXC__ServiceMax_Config_Data__c getButtonsizeObj(){
        return ButtonsizeObj;
    }
    public void setButtonsizeObj(SVMXC__ServiceMax_Config_Data__c val){
        this.ButtonsizeObj = val;
    }
    public void RedrawLayout()
    {
        sfwLayoutRecs_Column1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        sfwLayoutRecs_Column2 = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        /* sfw records are retreived here - Starts here */
        AllsfwOptns.clear();
        AllsfwOptns.add(new SelectOption( 'ServiceMax_None', getTag009() ));
        if( SelectedObject != 'ServiceMax_None' && SelectedObject != '' && SelectedObject != null )
            AllsfwRecs = Database.query('Select SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Description__c, SVMXC__Object_key_prefix__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = \'Wizard\' And SVMXC__Source_Object_Name__c = :SelectedObject');
        
        for( SVMXC__ServiceMax_Processes__c CurrentsfwRec :AllsfwRecs)
        {
            Map_sfwId_Name.put( CurrentsfwRec.Id, CurrentsfwRec.SVMXC__Name__c );
            Map_sfwId_ProcessId.put( CurrentsfwRec.Id, CurrentsfwRec.SVMXC__ProcessID__c );
            
            AllsfwOptns.add( new SelectOption(CurrentsfwRec.Id, CurrentsfwRec.SVMXC__Name__c + ' - ' + CurrentsfwRec.SVMXC__ProcessID__c ));
        }
        /* sfw records are retreived here - Ends here */
        
        //populating the already available layout records
        sfwLayoutRecs_Column1 = Database.query('Select Id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c, SVMXC__Wizard_Layout_Row__c, SVMXC__Wizard_Layout_Column__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Button_size__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Layout\' And SVMXC__Object_Name__c = :SelectedObject AND SVMXC__Wizard_Layout_Column__c = 1 ORDER BY SVMXC__Wizard_Layout_Row__c ASC');
        sfwLayoutRecs_Column2 = Database.query('Select Id, SVMXC__Dispatch_Process__c, SVMXC__Object_Name__c, SVMXC__Wizard_Layout_Row__c, SVMXC__Wizard_Layout_Column__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Button_size__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name = \'Wizard Layout\' And SVMXC__Object_Name__c = :SelectedObject AND SVMXC__Wizard_Layout_Column__c = 2 ORDER BY SVMXC__Wizard_Layout_Row__c ASC');
        if( sfwLayoutRecs_Column1 != null && sfwLayoutRecs_Column1.size() > 0 )
            ButtonsizeObj.SVMXC__Button_size__c = sfwLayoutRecs_Column1[0].SVMXC__Button_size__c;
        else if( sfwLayoutRecs_Column2 != null && sfwLayoutRecs_Column2.size() > 0 )
            ButtonsizeObj.SVMXC__Button_size__c = sfwLayoutRecs_Column2[0].SVMXC__Button_size__c;
        }
        public String PreviewHtml = '';
        public String getPreviewHtml(){ return PreviewHtml;}
        public void PreviewLayout(){
                // The below are the necessary entities to be sent in request for the sfw html
                Preview();
                SVMXC.INTF_GetServiceFlowWizard GetsfwHTML = new SVMXC.INTF_GetServiceFlowWizard();
                Set<Id> AllsfwIds = new Set<Id>();
                Map<Id, SVMXC__ServiceMax_Processes__c> Map_sfwId_Rec = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                Map<Id,Boolean>  NamedExpId_QualifiedStatus = new Map<Id,Boolean>();
                if( SelectedObject != 'ServiceMax_None' && SelectedObject != '' && SelectedObject != null )
                {
                        GetsfwHTML.setQualifiedWizardIds.clear();
                        for( SVMXC__ServiceMax_Processes__c CurrentsfwRec :AllsfwRecs)
                    {
                                AllsfwIds.add(CurrentsfwRec.Id);//param 1
                                Map_sfwId_Rec.put(CurrentsfwRec.Id, CurrentsfwRec);//param 3
                                if( CurrentsfwRec.SVMXC__Submodule__c != null )
                                        NamedExpId_QualifiedStatus.put(CurrentsfwRec.SVMXC__Submodule__c, true);
                        }
                        if( AllsfwIds != null )
                                GetsfwHTML.setQualifiedWizardIds.addAll(AllsfwIds);
                        if( Map_sfwId_Rec != null )
                                GetsfwHTML.mapWizardRecords.putAll(Map_sfwId_Rec);
                        
                        //param 2
                        Map<Id,List<SVMXC__ServiceMax_Processes__c>> Map_sfwId_ActionsList = new Map<Id,List<SVMXC__ServiceMax_Processes__c>>();    // Map of sfwId, List of sfwAction
                        List<SVMXC__ServiceMax_Processes__c> ListsfwActions = [Select Id, SVMXC__Module__c, SVMXC__Process__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                                                SVMXC__Action_Type__c, SVMXC__Action_URL__c,  SVMXC__Sequence__c, SVMXC__Submodule__c, SVMXC__IsStandard__c,SVMXC__Process1__c,
                                                                SVMXC__Process__r.SVMXC__ProcessId__c,SVMXC__Mode_Of_Execution__c,SVMXC__Handover__c,SVMXC__Confirmation_Message__c,SVMXC__Enable_Confirmation_Dialog__c, SVMXC__Select_Template_At_Runtime__c
                                                        From SVMXC__ServiceMax_Processes__c
                                                        Where RecordType.Name = 'Wizard Step' 
                                                        And SVMXC__Module__c In : AllsfwIds 
                                                        Order By SVMXC__Sequence__c];
                        for (SVMXC__ServiceMax_Processes__c qr : ListsfwActions)
                        {
                                List<SVMXC__ServiceMax_Processes__c> tempLstOfActions = new List<SVMXC__ServiceMax_Processes__c>();
                                if(Map_sfwId_ActionsList.containsKey(qr.SVMXC__Module__c)) 
                                        tempLstOfActions = Map_sfwId_ActionsList.get(qr.SVMXC__Module__c);
                                if( qr.SVMXC__Submodule__c != null )
                                        NamedExpId_QualifiedStatus.put(qr.SVMXC__Submodule__c, true);
                                tempLstOfActions.add(qr);   
                                Map_sfwId_ActionsList.put(qr.SVMXC__Module__c,tempLstOfActions);
                        } //GetsfwHTML.ActionsListForsfwMap = sfwid, List of sfw actions [select all the actions for all the qualified sfw ids ]//param 2
                        if( Map_sfwId_ActionsList != null )
                                GetsfwHTML.mapWizardIdStepsList.putAll(Map_sfwId_ActionsList);
                
                        if( NamedExpId_QualifiedStatus != null )
                                GetsfwHTML.mapExprIdIsMatched.putAll(NamedExpId_QualifiedStatus); //put all the named expression from sfw and actions here
                        if( sfwLayout_ListToUpsert != null )
                                GetsfwHTML.lstWizardLayouts.addAll(sfwLayout_ListToUpsert);
                        if( AllsfwRecs != null && AllsfwRecs.size() > 0 )
                        {
                                PreviewHtml =  GetsfwHTML.SVMX_Generate_sfw_HTML(AllsfwRecs[0].SVMXC__Object_key_prefix__c, 'preview');
                                PreviewHtml = PreviewHtml.replaceAll('\'','`');

                        }

                }

        }
        
    //------------------------------------------- Method to sort the Fields --------------------------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel().toUpperCase(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel().toUpperCase()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
  
    public String getTag001(){ return System.label.CONF016_TAG070; }//'Configure sfw Layout'; }
    public String getTag002(){ return System.label.CONF016_TAG071; }//'Quick Save'; }
    public String getTag003(){ return System.label.CONF016_TAG072; }//'Save & Close'; }
    public String getTag004(){ return System.label.CONF016_TAG073; }//'Cancel'; }
    public String getTag005(){ return System.label.CONF016_TAG074; }//'Back To Setup Home'; }
    public String getTag006(){ return System.label.CONF016_TAG024; }//'Processing...'; }//TAG075
    public String getTag007(){ return System.label.CONF016_TAG068; }//'Select Object for which you want to configure'; }//Object
    public String getTag008(){ return 'AddRow'; }//'AddRow'; }//System.label.CONF016_TAG076;
    public String getTag009(){ return System.label.CONF016_TAG067; }//'None';}//'--None--'
    public String getTag010(){ return System.label.CONF016_TAG077; }//'Button size';}//'Display size'
    public String getTag011(){ return System.label.CONF016_TAG078; }//'Record Saved successfully';}
    public String getTag012(){ return System.label.CONF016_TAG069; }//'Preview';}//TAG079//TAG076
    public String getTag013(){ return System.label.CONF016_TAG076; }//'SFW Layout Help';}//CONF016_TAG081
    public String getTag014(){ return System.label.CONF016_HLPURL3; }//'http://userdocs.servicemax.com:8080/ServiceMaxHelp/Summer11/en_us/svmx_redirector.htm?uid=';}
    public String getTag015(){ return System.label.CONF016_TAG005; }//'Display size cannot be None';}
    public String getTag016(){ return System.label.CONF016_TAG001; }//'Please select an Object.';}
}