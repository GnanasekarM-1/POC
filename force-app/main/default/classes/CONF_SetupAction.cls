public with sharing class CONF_SetupAction
{
    //Defect 032495 fix
    public class FieldListWrapper{
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

    public FieldListWrapper listOfObjects{
        get{
            if(listOfObjects==null){
                  listOfObjects=new FieldListWrapper();
                  for(Integer i=0;i<sourceObjectsOptns.size();i++){
                        listOfObjects.add(sourceObjectsOptns[i]);
                  }
            }
            return listOfObjects;
        }
        set;
    }
    public Boolean getIsSecondListHasItemObject(){
        Integer sizeOfList = listOfObjects.get1stList().size();
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }

    //Added new wrapper class for the story BAC-4706
    public class ActionParameterWrapper{
        public SVMXC__ServiceMax_Config_Data__c objConfigData;
        public SVMXC__ServiceMax_Config_Data__c getobjConfigData(){return this.objConfigData;}
        public void setobjConfigData(SVMXC__ServiceMax_Config_Data__c obj){this.objConfigData = obj;}
        /*Commented for BAC-5583
        public FieldListWrapper ObjFieldList = new FieldListWrapper();
        public FieldListWrapper getObjFieldList(){return ObjFieldList;}
        public void setObjFieldList(FieldListWrapper SelOpt){this.ObjFieldList = ObjFieldList;}
        */
        public String objNameDefination{get;set;} //Added for BAC-5583
        public List<SelectOption> RelatedObjects = new List<SelectOption>();
        public List<SelectOption> getRelatedObjects(){return RelatedObjects;}
        public void setRelatedObjects(List<SelectOption> RelatedObjects){this.RelatedObjects = RelatedObjects;}

        public Boolean disableParameterSource{set; get;}
        /*Commented for BAC-5583
        public Boolean getIsSecondListHasItem(){
            Integer sizeOfList = this.ObjFieldList.get1stList().size();
            if(sizeOfList > 0)
                return true;
            else
                return false;
        }
        */

        public ActionParameterWrapper() {}
        public ActionParameterWrapper(SVMXC__ServiceMax_Config_Data__c objConfigData)
        {
            this.objConfigData = objConfigData;
        }
    }
    public Map<String,List<SelectOption>> mapObjWithFields{get;set;} //Added for BAC-5583
    public List<ActionParameterWrapper> ListActionParameterWrapper = new List<ActionParameterWrapper>();
    public List<ActionParameterWrapper> getListActionParameterWrapper(){ return this.ListActionParameterWrapper;}
    public void setListActionParameterWrapper(List<ActionParameterWrapper> value){ this.ListActionParameterWrapper = value; }

    //=========================================Declarations and Getter-Setter Methods========================================================
    public string mode;
    public String ActionRTypeId = '';
    public String ActionRTypeId1 = '';
    public RecordType Action_Rtype;
    public RecordType Parameter_RType;
    public SVMXC__ServiceMax_Processes__c SVMXActn;
    public SVMXC__ServiceMax_Processes__c getSVMXActn(){return this.SVMXActn;}
    public SVMXC__ServiceMax_Processes__c SVMXActnClone = new SVMXC__ServiceMax_Processes__c();
    public void setSVMXActn(SVMXC__ServiceMax_Processes__c process){this.SVMXActn = process;}
    public List<SVMXC__ServiceMax_Processes__c> actionsLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ActionParamToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ActionParam = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ActionParamClone = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getActionParam(){return this.ActionParam;}
    public void setActionParam(List<SVMXC__ServiceMax_Config_Data__c> config){this.ActionParam = config;}
    public integer i;
    public String SelectedSourceObject = '';
    public List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public String ObjectName;
    boolean isEnterprise;
    public Map<String,String> mapfieldApiLabel_Name = new Map<String,String>(); 
    public Map<String,String> mapfieldApiName_Label = new Map<String,String>();
    public string URLTrgtType{get;set;}
    public string actnTitle{get;set;}
    public string URL{get;set;}
    public string actnId{get;set;}
    public String wndwHgt{get;set;}
    public String wndwWdt{get;set;}
    public string description{get;set;}
    public string cancelBack{get;set;}
    public boolean isActive{get;set;}

    public boolean openAsFullWindow = false;
    public boolean getopenAsFullWindow(){return this.openAsFullWindow;}
    public void setopenAsFullWindow(boolean openAsFullWindow){this.openAsFullWindow = openAsFullWindow;}


    public boolean showScrollbars{get;set;}
    public boolean disabled{get;set;}
    public boolean disabledScrollbar{get;set;}
    public string paramType{get;set;}
    public string paramSource{get;set;}
    public string paramValue{get;set;}
    public string paramName{get;set;}
    public boolean showPckLst{get;set;}
    public boolean showText{get;set;}
    public boolean Validate = true;
    public boolean addPress = false;
    public integer addLine = 0;
    public string SlctdParamValue{get; set;}
    public boolean renderRow{get; set;}
    public String PageBlockTitle;
    public String getPageBlockTitle(){return this.PageBlockTitle;}
    public void setPageBlockTitle(String title){this.PageBlockTitle = title;}
    // variable created by sharad
    public String strActnType{get; set;}
    public boolean chkActnTyp{get; set;}
    public boolean chkActnTypURL{get; set;}
  //new for App
  public boolean chkActnTypeApp{get;set;}
  //App to App
    public List<SelectOption> ActnTypeOptns = new List<SelectOption>();
    public List<SelectOption> getActnTypeOptns(){return ActnTypeOptns;}
    public void setActnTypeOptns(List<SelectOption> tempOptn){ActnTypeOptns = tempOptn;}
    public String strNmSps{get; set;}
    public String strClsNm{get; set;}
    public String strMethNm{get; set;}
    public String strPrcssingMsg{get; set;}
  //app to App
  public String schemaName{get; set;}
  public String path{get; set;}
  public boolean includeObjectData{get;set;}
  //app to App
    public String getObjectName()
    {
        return ObjectName;
    }
    public List<SelectOption> getObjectsWithAction()
    {
        return sourceObjectsOptns;
    }
    public String getSelectedSourceObject()
    {
        return SelectedSourceObject;
    }
    public void setSelectedSourceObject(String val)
    {
        SelectedSourceObject = val;
    }
    public boolean DisableHeightWidthFields = false;
    public Boolean getDisableHeightWidthFields() { return DisableHeightWidthFields;}
    //Mobile Activity Space
    public boolean chkActnTypMobile{get; set;}
    public String packageName{get; set;}
    public transient blob packageData{ get; set;}
    public integer packageSize{ get; set;}
    public String savedPackageName{get; set;}
    public List<Id> contentDocumentIdList = new List<Id>();

    //----------------------------------- Method to define the list of the Target URL Type ---------------------------------------
    public List<SelectOption> getURLType()
    {
        List<SelectOption> URLTypeLst = new List<SelectOption>();
        URLTypeLst.add(new SelectOption('New Window',getTAG040()));
        URLTypeLst.add(new SelectOption('Existing Window',getTAG041()));
        //24-Mar-2017:Sourabh:Added option for Modal Window on Clone:ST-274
        if((mode == 'Clone') || (mode == 'Edit' && URLTrgtType == 'Modal Window'))
            URLTypeLst.add(new SelectOption('Modal Window',getTAG068()));
        return URLTypeLst;
    }
    //----------------------------------- Method to define the list of the Action Parameter Type ---------------------------------------
    public List<SelectOption> getParamTypePckLst()
    {
        List<SelectOption> ParamTypePckLst = new List<SelectOption>();
        ParamTypePckLst.add(new SelectOption(getTAG031(),getTAG031()));
        ParamTypePckLst.add(new SelectOption('Field Name',getTAG042()));
        ParamTypePckLst.add(new SelectOption('Field Source',getTAG084()));
        ParamTypePckLst.add(new SelectOption('Value',getTAG043()));
        return ParamTypePckLst;
    }

    List<SelectOption> ParameterSourcePckLst = new List<SelectOption>();
    //Added new nethod for the story BAC-4706 which return related object fields list
    public void populateParameterSourcePckLst(Map<String,Boolean> permitdStdObjMap, Boolean isEnterprise, String strObjectName, COMM_Utils utils)
    {
        if(strObjectName != '--None--' && strObjectName != null && strObjectName != ''){
            ParameterSourcePckLst.clear();
            ParameterSourcePckLst.add(new SelectOption(getTAG031(),getTAG031()));
            Schema.DescribeSobjectResult objDesc = Schema.describeSObjects(new List<String>{strObjectName})[0];

            ParameterSourcePckLst.add(new SelectOption(strObjectName, objDesc.getLabel(), true));

            Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>();
            LfieldsMap = objDesc.fields.getMap();

            Schema.DescribeFieldResult DesResult;
            for(String s : LfieldsMap.keyset())
            {
                String APIName = LfieldsMap.get(s).getDescribe().getName();
                Map<String, Schema.SObjectField> fieldsMap = new Map<String, Schema.SObjectField>();

                fieldsMap.put(APIName,LfieldsMap.get(s));
                DesResult = fieldsMap.get(APIName).getDescribe();
                if(DesResult.getType() == Schema.DisplayType.REFERENCE )
                {
                    if((!DesResult.isNamePointing()) || DesResult.getName().equals('OwnerId'))
                    {
                        if(!DesResult.getName().equals('RecurrenceActivityId'))
                        {
                            List<Schema.sObjectType> Ref = DesResult.getReferenceTo();
                            if(Ref != NULL && Ref.size() > 0)
                            {
                                if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])))
                                {
                                    string str = objDesc.getLabel()+' ' + '-' +' ' +DesResult.getLabel();
                                    ParameterSourcePckLst.add(new SelectOption(string.valueOf(Ref[0]+'~'+DesResult.getRelationshipName()),str));
                                }
                                else if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])) == false)
                                {
                                    if((permitdStdObjMap.containsKey(String.valueof(Ref[0])) || isEnterprise))
                                    {
                                        string str = objDesc.getLabel()+' ' + '-' +' ' +DesResult.getLabel();
                                        ParameterSourcePckLst.add(new SelectOption(string.valueOf(Ref[0]+'~'+DesResult.getRelationshipName()),str));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //----------------------------------------------- Constructor for the OnLoad --------------------------------------------------------
    public CONF_SetupAction()
    {
        mapObjWithFields = new Map<String,List<SelectOption>>(); //Added for BAC-5583
        renderRow = true;
        cancelBack = getTAG004();
        disabled = false;
        showScrollbars = true;
        disabledScrollbar = false;
        includeObjectData=true;
        //------------------------ Check for the Enterprise License -----------------------------
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
        isEnterprise = utils.SVMX_isEnterpriseLicense();
        Map<String,Boolean> permitdStdObjLst = utils.SVMX_getPermittedStandardObjectList();
        if(!isEnterprise) permitdStdObjLst = utils.SVMX_getPermittedStandardObjectList();

        sourceObjectsOptns.add(new SelectOption(getTAG031(),getTAG031()));

        //------------------------------- List of Objects ---------------------------------
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectType> allObjsWithApiName = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();

        ActnTypeOptns.clear();
        ActnTypeOptns.add(new SelectOption(getTAG031(),getTAG031()));
        ActnTypeOptns.add(new SelectOption('URL',getTAG064()));
        ActnTypeOptns.add(new SelectOption('Web-Service',getTAG065()));


        //BAC-2980 : Hiding app-to-app custom action as per the story
        ActnTypeOptns.add(new SelectOption('App-to-App',getTAG070()));
        ActnTypeOptns.add(new SelectOption('Mobile-Activity-Space',getTAG087()));
        strActnType = getTAG031();


        /*Schema.DescribeFieldResult Prcss = SVMXC__ServiceMax_Processes__c.SVMXC__Custom_Action_Type__c.getDescribe();
        for(Schema.PicklistEntry pickEntry : Prcss.getPicklistValues())
        {
            ActnTypeOptns.add(new SelectOption(pickEntry.getValue(),pickEntry.getValue()));
        }*/

        for(String s : allObjs.keyset())
        {
            Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
            if(objDesc.isAccessible() == true && objDesc.isCreateable() == true && objDesc.isCustom() == true && objDesc.isUpdateable())
            {
                mapfieldApiLabel_Name.put(objDesc.getName(),objDesc.getLabel());
                sourceObjectsOptns.add(new SelectOption(objDesc.getName(),objDesc.getLabel()));
                allObjsWithApiName.put(objDesc.getName(),allObjs.get(s));
            }
            else if(objDesc.isAccessible() == true && objDesc.isCreateable() == true && objDesc.isCustom() == false && objDesc.isUpdateable() && (permitdStdObjLst.containsKey(objDesc.getName()) || isEnterprise))
            {
                mapfieldApiLabel_Name.put(objDesc.getName(),objDesc.getLabel());
                sourceObjectsOptns.add(new SelectOption(objDesc.getName(),objDesc.getLabel()));
                allObjsWithApiName.put(objDesc.getName(),allObjs.get(s));
            }
        }

        sourceObjectsOptns = sortingSelectOption(sourceObjectsOptns);

        //------------------ Querying the Record Types for the SF Action and SF Action Parameter--------------------------
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ActionRTypeId = Action_Rtype.Id;

        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ActionRTypeId1 = Parameter_RType.Id;

        //------------------ Querying SF Action --------------------------
        //actionsLst = [select Id, SVMXC__ProcessID__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Show_Scrollbars__c, SVMXC__Open_As_Full_Window__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c,  SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SF Action']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA // Commented for Defect-046782

        //------------ Getting the Record Id, Object Name and Action from the Page URL --------------------
        string action = System.currentPageReference().getParameters().get('SVMX_Action');
        string recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        //system.debug('1. Id passed from URL: ' + recordId );
        //system.debug('2. Action to be taken: ' + action );
        string objectName = System.currentPageReference().getParameters().get('SVMX_ObjectName');
        string objectForFields = '';

        if(recordId == null || recordId == '')
        {
            mode = 'New';
            SVMXActn = new SVMXC__ServiceMax_Processes__c();//SVMXC__Record_Type_Name__c = 'SF Action'
            ActionParam = new List<SVMXC__ServiceMax_Config_Data__c>();
            ListActionParameterWrapper = new List<ActionParameterWrapper>();
            objectForFields = objectName;

            //Calling method to poppulate related object list
            populateParameterSourcePckLst(permitdStdObjLst, isEnterprise, objectForFields, utils);
        }
        else
        {
            //---------------- Querying the Standard and Custom Actions for the Selected Object ------------------------
            string SOQL = 'Select  SVMXC__Name__c, SVMXC__ProcessID__c,SVMXC__Window_Height__c,SVMXC__Window_Width__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Show_Scrollbars__c, SVMXC__Open_As_Full_Window__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c, SVMXC__IsStandard__c, SVMXC__Custom_action_Type__c, SVMXC__Service_Namespace__c, SVMXC__Service_Class_Name__c, SVMXC__Service_Method_Name__c, SVMXC__Parent_Error_Msg__c,SVMXC__SM_Schema_Name__c,SVMXC__SM_Path__c,SVMXC__SM_Include_Object_Data_Set__c from ServiceMax_Processes__c Where Id =: recordId';
            SVMXActn = database.Query(SOQL);
            if( SVMXActn != null )
            {
                if( SVMXActn.SVMXC__Target_Type__c == 'Existing Window' )
                {
                    DisableHeightWidthFields = true;
                    disabledScrollbar = true;
                }
                showScrollbars = SVMXActn.SVMXC__Show_Scrollbars__c;
                openAsFullWindow = SVMXActn.SVMXC__Open_As_Full_Window__c;
                URLTrgtType = SVMXActn.SVMXC__Target_Type__c;
                strActnType = SVMXActn.SVMXC__Custom_action_Type__c;
                strNmSps = SVMXActn.SVMXC__Service_Namespace__c;
                strClsNm = SVMXActn.SVMXC__Service_Class_Name__c;
                strMethNm = SVMXActn.SVMXC__Service_Method_Name__c;
                strPrcssingMsg = SVMXActn.SVMXC__Parent_Error_Msg__c;
                //app to App
        schemaName = SVMXActn.SVMXC__SM_Schema_Name__c;
                path = SVMXActn.SVMXC__SM_Path__c;
        includeObjectData = SVMXActn.SVMXC__SM_Include_Object_Data_Set__c;

                if(openAsFullWindow == true)
                    DisableHeightWidthFields = true;
                else if((SVMXActn.SVMXC__Target_Type__c == 'New Window') ||(SVMXActn.SVMXC__Target_Type__c == 'Modal Window'))
                    DisableHeightWidthFields = false;


                //Added fields "SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name2__c" for the story BAC-4706
                ActionParam = [select id, SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name2__c, RecordTypeId, SVMXC__Object_Name__c, SVMXC__Select__c, SVMXC__Parameter_Name__c,SVMXC__Parameter_Type__c,SVMXC__Parameter_Value__c,SVMXC__Expression_Rule__c,SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: SVMXActn.id AND RecordType.Name = 'SF Action Parameter' Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                Integer i = 1;
                for(SVMXC__ServiceMax_Config_Data__c conf : ActionParam)
                {
                    if(conf.SVMXC__Parameter_Type__c == 'Field Source' || conf.SVMXC__Parameter_Type__c == getTAG084()){
                        conf.SVMXC__Lookup_Field_API_Name__c = conf.SVMXC__Object_Name2__c + '~' + conf.SVMXC__Lookup_Field_API_Name__c;
                    }
                    conf.SVMXC__Sequence__c = Integer.valueOf(i);
                    ListActionParameterWrapper.add(new ActionParameterWrapper(conf));
                    i++;
                }
            }

            //system.debug('3. List of Action Parameters: '+ ActionParam);
            //system.debug('4. Selected Action: '+ SVMXActn);

            //------------------------- Determining Modes for the Action ----------------------------
            if(SVMXActn.SVMXC__IsStandard__c == true)
            {
                if(action == 'Clone')
                    mode = 'Clone';
                else
                    {
                        mode = 'View';
                        DisableHeightWidthFields = true;
                        disabledScrollbar = true;
                    }
                cancelBack = getTAG025();
            }
            else
            {
                if( action == 'Clone')
                {
                    mode = 'Clone';
                }
                else
                {
                    mode = 'Edit';
                }
            }
            objectForFields = SVMXActn.SVMXC__Source_Object_Name__c;

            //Calling method to poppulate related object list
            populateParameterSourcePckLst(permitdStdObjLst, isEnterprise, objectForFields, utils);

            for(ActionParameterWrapper objActionParameterWrapper : ListActionParameterWrapper){
                if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c == 'Field Name'){
                    System.debug('ObjectName for field name: '+objectForFields);
                    List<SelectOption> lstFieldSO = getFieldList(objectForFields);
                    /*Commented for BAC-5583
                    FieldListWrapper listOfFields = new FieldListWrapper();
                    listOfFields.collectionList = lstFieldSO;
                    objActionParameterWrapper.ObjFieldList = listOfFields;
                    */
                    mapObjWithFields.put(objectForFields,lstFieldSO); //Added for BAC-5583
                    objActionParameterWrapper.disableParameterSource = true;
                    objActionParameterWrapper.RelatedObjects.clear();
                    objActionParameterWrapper.RelatedObjects.addAll(ParameterSourcePckLst);
                    objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c = objectForFields;
                    objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c = objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c != null ? objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase() : null;
                }
                else if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c == 'Field Source'){
                    System.debug('ObjectName for field Source: '+objActionParameterWrapper.objConfigData.SVMXC__Object_Name2__c);
                    List<SelectOption> lstFieldSO = getFieldList(objActionParameterWrapper.objConfigData.SVMXC__Object_Name2__c);
                    /*Commented for BAC-5583
                    FieldListWrapper listOfFields = new FieldListWrapper();
                    listOfFields.collectionList = lstFieldSO;
                    objActionParameterWrapper.ObjFieldList = listOfFields;
                    */
                    mapObjWithFields.put(objActionParameterWrapper.objConfigData.SVMXC__Object_Name2__c,lstFieldSO); //Added for BAC-5583
                    objActionParameterWrapper.RelatedObjects.clear();
                    objActionParameterWrapper.RelatedObjects.addAll(ParameterSourcePckLst);
                    objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c = objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c != null ? objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase() : null;
                }
                else if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c == 'Value'){
                    objActionParameterWrapper.disableParameterSource = true;
                }
            }
        }

        if(mode == 'Clone' || mode == 'New'){
            actionsLst = [select Id, SVMXC__ProcessID__c, SVMXC__Window_Height__c, SVMXC__Window_Width__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Show_Scrollbars__c, SVMXC__Open_As_Full_Window__c, SVMXC__Target_Type__c, SVMXC__Target_URL__c,  SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SF Action']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        //system.debug('5. Object of the Selected Action: '+ objectForFields);

        //system.debug('6. Mode: '+ mode);
        if(mode == 'View' || mode == 'Edit')
        {
            if(mode == 'View')
            {
                disabled = true;
            }
            SelectedSourceObject = SVMXActn.SVMXC__Source_Object_Name__c;
            URLTrgtType = SVMXActn.SVMXC__Target_Type__c;
            actnTitle = SVMXActn.SVMXC__Name__c;
            URL = SVMXActn.SVMXC__Target_URL__c;
            actnId = SVMXActn.SVMXC__ProcessID__c;
            if( SVMXActn != null && SVMXActn.SVMXC__Window_Height__c != null )
                wndwHgt = String.valueOf(SVMXActn.SVMXC__Window_Height__c);
            if(SVMXActn != null && SVMXActn.SVMXC__Window_Width__c != null )
                wndwWdt = String.valueOf(SVMXActn.SVMXC__Window_Width__c);
            description = SVMXActn.SVMXC__Description__c;
            isActive = SVMXActn.SVMXC__Active__c;
            showScrollbars = SVMXActn.SVMXC__Show_Scrollbars__c;
            openAsFullWindow = SVMXActn.SVMXC__Open_As_Full_Window__c;
            strActnType = SVMXActn.SVMXC__Custom_action_Type__c;
            strNmSps = SVMXActn.SVMXC__Service_Namespace__c;
            strClsNm = SVMXActn.SVMXC__Service_Class_Name__c;
            strMethNm = SVMXActn.SVMXC__Service_Method_Name__c;
            strPrcssingMsg = SVMXActn.SVMXC__Parent_Error_Msg__c;
            schemaName=SVMXActn.SVMXC__SM_Schema_Name__c;
            path=SVMXActn.SVMXC__SM_Path__c;
            includeObjectData=SVMXActn.SVMXC__SM_Include_Object_Data_Set__c;

            //Calling method to poppulate related object list
            populateParameterSourcePckLst(permitdStdObjLst, isEnterprise, SelectedSourceObject, utils);
        }
        else if(mode == 'Clone')
        {
            //-------------- Cloning the Action And Action Parameter --------------------
            SVMXActnClone = SVMXActn.clone(false,true);
            SVMXActnClone.SVMXC__IsStandard__c = false;
            SelectedSourceObject = SVMXActnClone.SVMXC__Source_Object_Name__c;
            URLTrgtType = SVMXActnClone.SVMXC__Target_Type__c;
            actnTitle = SVMXActnClone.SVMXC__Name__c;
            URL = SVMXActnClone.SVMXC__Target_URL__c;
            actnId = SVMXActnClone.SVMXC__ProcessID__c;
            if( SVMXActnClone != null && SVMXActnClone.SVMXC__Window_Height__c != null )
                wndwHgt = String.valueOf(SVMXActnClone.SVMXC__Window_Height__c);
            if(SVMXActn != null && SVMXActn.SVMXC__Window_Width__c != null )
                wndwWdt = String.valueOf(SVMXActnClone.SVMXC__Window_Width__c);
            description = SVMXActnClone.SVMXC__Description__c;
            isActive = SVMXActnClone.SVMXC__Active__c;
            showScrollbars = SVMXActnClone.SVMXC__Show_Scrollbars__c;
            openAsFullWindow = SVMXActnClone.SVMXC__Open_As_Full_Window__c;
            strActnType = SVMXActnClone.SVMXC__Custom_action_Type__c;
            strNmSps = SVMXActnClone.SVMXC__Service_Namespace__c;
            strClsNm = SVMXActnClone.SVMXC__Service_Class_Name__c;
            strMethNm = SVMXActnClone.SVMXC__Service_Method_Name__c;
            strPrcssingMsg = SVMXActnClone.SVMXC__Parent_Error_Msg__c;
            //system.debug('7. Action Cloned: ' + SVMXActnClone);
            //app to app
            schemaName=SVMXActnClone.SVMXC__SM_Schema_Name__c;
            path=SVMXActnClone.SVMXC__SM_Path__c;
            includeObjectData=SVMXActnClone.SVMXC__SM_Include_Object_Data_Set__c;
            //app to app
            ListActionParameterWrapper.clear();
            for(i=0;i<ActionParam.size();i++)
            {
                SVMXC__ServiceMax_Config_Data__c param = new SVMXC__ServiceMax_Config_Data__c();
                param = ActionParam[i].clone(false,true);
                ActionParamClone.add(param);

                param.SVMXC__Sequence__c = i+1;
                ActionParameterWrapper objAPW = new ActionParameterWrapper();
                objAPW.objConfigData = param;

                if(objAPW.objConfigData.SVMXC__Parameter_Type__c == 'Field Name'){
                    System.debug('SelectedSourceObject for field name: '+SelectedSourceObject);
                    List<SelectOption> lstFieldSO = getFieldList(SelectedSourceObject);
                    /*Commented for BAC-5583
                    FieldListWrapper listOfFields = new FieldListWrapper();
                    listOfFields.collectionList = lstFieldSO;
                    objAPW.ObjFieldList = listOfFields;
                    */
                    mapObjWithFields.put(SelectedSourceObject,lstFieldSO); //Added for BAC-5583
                    objAPW.disableParameterSource = true;
                    objAPW.RelatedObjects.clear();
                    objAPW.RelatedObjects.addAll(ParameterSourcePckLst);
                    objAPW.objConfigData.SVMXC__Lookup_Field_API_Name__c = SelectedSourceObject;
                    objAPW.objConfigData.SVMXC__Parameter_Value__c = objAPW.objConfigData.SVMXC__Parameter_Value__c != null ? objAPW.objConfigData.SVMXC__Parameter_Value__c.toUpperCase() : null;
                }
                else if(objAPW.objConfigData.SVMXC__Parameter_Type__c == 'Field Source'){
                    System.debug('ObjectName for field Source: '+objAPW.objConfigData.SVMXC__Object_Name2__c);
                    List<SelectOption> lstFieldSO = getFieldList(objAPW.objConfigData.SVMXC__Object_Name2__c);
                    /*Commented for BAC-5583
                    FieldListWrapper listOfFields = new FieldListWrapper();
                    listOfFields.collectionList = lstFieldSO;
                    objAPW.ObjFieldList = listOfFields;
                    */
                    mapObjWithFields.put(objAPW.objConfigData.SVMXC__Object_Name2__c,lstFieldSO); //Added for BAC-5583
                    objAPW.RelatedObjects.clear();
                    objAPW.RelatedObjects.addAll(ParameterSourcePckLst);
                    objAPW.objConfigData.SVMXC__Parameter_Value__c = objAPW.objConfigData.SVMXC__Parameter_Value__c != null ? objAPW.objConfigData.SVMXC__Parameter_Value__c.toUpperCase() : null;
                }
                else if(objAPW.objConfigData.SVMXC__Parameter_Type__c == 'Value'){
                    objAPW.disableParameterSource = true;
                }

                ListActionParameterWrapper.add(objAPW);
            }
            ActionParam.clear();
            ActionParam.addAll(ActionParamClone);

            //Calling method to poppulate related object list
            populateParameterSourcePckLst(permitdStdObjLst, isEnterprise, SelectedSourceObject, utils);
            //system.debug('7. Action Parameters Cloned: ' + ActionParamClone);
        }
        else if(mode == 'New')
        {
            system.debug('objectName : '+ objectName);
            SelectedSourceObject = objectName;
            wndwHgt = '400';
            wndwWdt = '600';
            //system.debug('8. Selected Object: '+ SelectedSourceObject);
        }
        PageBlockTitle = getTAG001()+' '+mapfieldApiLabel_Name.get(SelectedSourceObject);

        //retrieve package file for strActnType == 'Mobile-Activity-Space'
        if(strActnType == 'Mobile-Activity-Space' && recordId != null) {
            for(ContentDocumentLink documentLink : [select ContentDocumentId,ContentDocument.Title from ContentDocumentLink where LinkedEntityId =: recordId]){
                contentDocumentIdList.add(documentLink.ContentDocumentId);
                savedPackageName = documentLink.ContentDocument.Title;
            }
        }

        if((recordId != null || recordId == '') && (strActnType == '' || strActnType == null))
        {
            strActnType = 'URL';
        }
        if(strActnType == getTAG031()  || strActnType == '' || strActnType == null)
            chkActnTyp = false;
        else
            chkActnTyp = true;

      if(strActnType == 'URL')
      {
        chkActnTypURL = true;
        chkActnTypeApp=false;
        chkActnTypMobile = false;
      }
      else if(strActnType == 'Web-Service')
      {
        chkActnTypURL = false;
        chkActnTypeApp=false;
        chkActnTypMobile = false;
      }else if(strActnType == 'App-to-App')
      {
        chkActnTypeApp=true;
        chkActnTypMobile = false;
      }
      else if(strActnType == 'Mobile-Activity-Space'){
        chkActnTypURL = false;
        chkActnTypeApp=false;
        chkActnTypMobile = true;
      }
    }

    //--------------------------------------- Method to cheak Action Type and make it disable or not ----------------------------------------------
    public pageReference onChngActnType()
    {
        if(strActnType == getTAG031())
            chkActnTyp = false;
        else
            chkActnTyp = true;

        if(strActnType == 'URL'){
            chkActnTypURL = true;
            chkActnTypeApp=false;
            chkActnTypMobile = false;
        }
        else if(strActnType == 'Web-Service')
        {
            chkActnTypURL = false;
            chkActnTypeApp=false;
            chkActnTypMobile = false;
        }
        else if(strActnType == 'App-to-App')
        {
            chkActnTypeApp=true;
            chkActnTypMobile = false;
        }
        else if(strActnType == 'Mobile-Activity-Space'){
            chkActnTypURL = false;
            chkActnTypeApp = false;
            chkActnTypMobile = true;
          }

        return null;
    }
    //--------------------------------------- Method to sort the Fields ----------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>());
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }

    //----------------------------------- Method To Save and Close ---------------------------------------------------
    public pageReference saveAndClose()
    {
        save();
        if(Validate != false)
        {
            pageReference pageref1 = Page.CONF_ManageActions ;
            pageref1.getParameters().put('SVMX_ObjectName',SelectedSourceObject);
            return pageref1;
        }
        return null;
    }

    //------------------------------------------- Method To Quick Save -------------------------------------------
    public pageReference quickSave()
    {
        save();
        if(Validate != false)
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG026(),''));

        PageReference pageReference = ApexPages.currentPage();
        pageReference.setRedirect(false);
        return pageReference;
    }

    //----------------------- Method To Set Window Height and Width for the New Window Selected ---------------------------------------
    public void WndwHgtWdt()
    {
        if((URLTrgtType == 'New Window')||(URLTrgtType == 'Modal Window'))
        {
            showScrollbars = true;
            disabledScrollbar = false;
            if(mode == 'View' || mode == 'Edit')
            {
                if( SVMXActn != null && SVMXActn.SVMXC__Window_Height__c != null )
                    wndwHgt = String.valueOf(SVMXActn.SVMXC__Window_Height__c);
                else
                    wndwHgt = '400';
                if(SVMXActn != null && SVMXActn.SVMXC__Window_Width__c != null )
                    wndwWdt = String.valueOf(SVMXActn.SVMXC__Window_Width__c);
                else
                    wndwWdt = '600';
            }
            else if(mode == 'Clone')
            {
                if( SVMXActnClone != null && SVMXActnClone.SVMXC__Window_Height__c != null )
                    wndwHgt = String.valueOf(SVMXActnClone.SVMXC__Window_Height__c);
                else
                    wndwHgt = '400';
                if(SVMXActn != null && SVMXActn.SVMXC__Window_Width__c != null )
                    wndwWdt = String.valueOf(SVMXActnClone.SVMXC__Window_Width__c);
                else
                    wndwWdt = '600';
            }
            else
            {
                wndwHgt = '400';
                wndwWdt = '600';
            }
        }
        else
        {
            disabledScrollbar = true;
            wndwHgt = null;
            wndwWdt = null;
        }

        if(openAsFullWindow == true || URLTrgtType == 'Existing Window')
        {
            DisableHeightWidthFields = true;
        }
        else
            DisableHeightWidthFields = false;
    }

    //----------------------- Method To Validate and Saving Action and Action Parameters---------------------------------------
    public void save()
    {
        Validate = true;
        if(actnTitle == null || actnTitle == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG029()));
        }
        if(actnId == null || actnId == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG030()));
        }
        if(strActnType == 'URL')
        {
            if(URL == null || URL == '')
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG038()));
            }
        }
        else if(strActnType == 'App-to-App')
        {
            //commented as part of BAC-4425
            /*
            if(path == null || path == '')
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG074()));
            }*/

            if(schemaName==null || schemaName == '')
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG075()));
          }
        }
        else if(strActnType != 'Mobile-Activity-Space')
        {
            if(strClsNm == null || strClsNm == '')
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG059()));
            }
            if(strMethNm == null || strMethNm == '')
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG059()));
            }
            if(strPrcssingMsg.length() > 255)
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG066()));
            }
        }
        if(mode == 'Clone' || mode == 'New')
        {
            for(SVMXC__ServiceMax_Processes__c actn : actionsLst)
            {
                if(actnId == actn.SVMXC__ProcessID__c)
                {
                    Validate = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG056()));
                }
            }
        }
        //system.debug('9. Record Type Id of the Action: '+ ActionRTypeId);


        try{
            if(strActnType == 'Mobile-Activity-Space') {
                System.debug('packageData - '+packageData+' contentDocumentIdList -'+contentDocumentIdList);
                if(packageData == null && contentDocumentIdList.size() > 0){
                    List<ContentVersion> contentVersionList = [Select VersionData,Title from ContentVersion where ContentDocumentId IN :contentDocumentIdList];
                    System.debug('Clone Package List- '+contentVersionList);
                    if(contentVersionList != null && contentVersionList.size() > 0){
                        packageData = contentVersionList.get(0).VersionData;
                    }
                }

                if(ApexPages.hasMessages()){
                    Validate = false;
                }
                else{
                    if(packageData == null){
                        Validate = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG091()));
                    }
                    if(packageSize > 10485760){//10MB Size Limit
                        Validate = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG089()));
                    }
                }
            }

            if(mode == 'Clone')
            {
                //24-Mar-2017:Sourabh:ST-274:Warning Messsage on saving with Modal Window option
                if (URLTrgtType == 'Modal Window')
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,getTAG069()));
                SVMXActnClone.RecordTypeId = ActionRTypeId;
                SVMXActnClone.SVMXC__Source_Object_Name__c = SelectedSourceObject;
                SVMXActnClone.SVMXC__Target_Type__c = URLTrgtType;
                SVMXActnClone.SVMXC__Name__c = actnTitle;
                SVMXActnClone.SVMXC__Target_URL__c = URL;
                SVMXActnClone.SVMXC__ProcessID__c = actnId;
                if(wndwHgt != null && wndwHgt != '')
                    SVMXActnClone.SVMXC__Window_Height__c = Integer.valueOf(wndwHgt);
                if(wndwWdt != null && wndwWdt != '')
                    SVMXActnClone.SVMXC__Window_Width__c = Integer.valueOf(wndwWdt);
                SVMXActnClone.SVMXC__Description__c = description;
                SVMXActnClone.SVMXC__Active__c = isActive;
                SVMXActnClone.SVMXC__Show_Scrollbars__c = showScrollbars;
                SVMXActnClone.SVMXC__Open_As_Full_Window__c = openAsFullWindow;

                SVMXActnClone.SVMXC__Custom_action_Type__c = strActnType;
                SVMXActnClone.SVMXC__Service_Namespace__c = strNmSps;
                SVMXActnClone.SVMXC__Service_Class_Name__c = strClsNm;
                SVMXActnClone.SVMXC__Service_Method_Name__c = strMethNm;
                SVMXActnClone.SVMXC__Parent_Error_Msg__c = strPrcssingMsg;
        //app to app
        SVMXActnClone.SVMXC__SM_Schema_Name__c=schemaName;
        SVMXActnClone.SVMXC__SM_Path__c=path;
        SVMXActnClone.SVMXC__SM_Include_Object_Data_Set__c=includeObjectData;
                if(validate == true){
          //upsert SVMXActnClone;
          if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SVMXActnClone, COMM_SecurityUtils.Access.Upsertable)){
            upsert SVMXActnClone; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
          }
          else{
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
          }

          //clone package file for strActnType == 'Mobile-Activity-Space'
            if(strActnType == 'Mobile-Activity-Space' && contentDocumentIdList.size() > 0) {
                System.debug('Clonning Package');
                List<ContentDocumentLink> documentLinkList = [select ContentDocumentId,ContentDocument.Title from ContentDocumentLink where LinkedEntityId =: SVMXActnClone.id];
                if(documentLinkList != null && documentLinkList.size() > 0){
                    ContentDocumentLink documentLink = documentLinkList.get(0);
                    List<ContentVersion> savedContentVersionList = [Select VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId =:documentLink.ContentDocumentId];
                    if(packageData != null && savedContentVersionList != null && savedContentVersionList.size() > 0){
                        ContentVersion contentVersionData = savedContentVersionList.get(0);
                        List<ContentVersion> contentVersionList = new List<ContentVersion>();
                        contentVersionList.add(COMM_FileHandlerUtilities.createContentVersionInstance(contentVersionData.Id, packageName, packageData, null));
                        List<Id> listofReturnIds = COMM_FileHandlerUtilities.updateContentVersion(contentVersionList);
                        if(listofReturnIds.size() > 0){
                            System.debug('Package updated successfully');
                        }
                        else{
                            Validate = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG092()));
                        }
                        if(packageName != null){
                            savedPackageName = packageName;
                        }
                        packageData = null;
                    }
                }
                else{
                    List<ContentVersion> contentVersionList = [Select VersionData,Title from ContentVersion where ContentDocumentId IN :contentDocumentIdList];
                    System.debug('Clone Package List- '+contentVersionList);
                    if(contentVersionList != null && contentVersionList.size() > 0){
                        ContentVersion contentVersionData = contentVersionList.get(0);
                        ContentVersion contentVersion = COMM_FileHandlerUtilities.createContentVersionInstance(null, contentVersionData.Title, contentVersionData.VersionData, null);
                        Id contentVersionId = COMM_FileHandlerUtilities.insertOneContentVersion(contentVersion);
                        if(contentVersionId != null){
                            System.debug('Updating Package contentVersionId - '+contentVersionId);
                            Map<Id,Id> contentVerionMap = new Map<Id,Id>();
                            contentVerionMap.put(contentVersionId, SVMXActnClone.id);
                            Map<Id,Id> contentDocumentMap = COMM_FileHandlerUtilities.getContentDocumentData(contentVerionMap);
                            if(contentDocumentMap.size() == 0){
                                Validate = false;
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG092()));
                            }
                            savedPackageName = contentVersionData.Title;
                        }
                        else{
                            Validate = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG092()));
                        }
                    }
                }
            }
        }
            }
            else
            {
                SVMXActn.RecordTypeId = ActionRTypeId;
                SVMXActn.SVMXC__Source_Object_Name__c = SelectedSourceObject;
                SVMXActn.SVMXC__Target_Type__c = URLTrgtType;
                SVMXActn.SVMXC__Name__c = actnTitle;
                SVMXActn.SVMXC__Target_URL__c = URL;
                SVMXActn.SVMXC__ProcessID__c = actnId;
                if(wndwHgt != null && wndwHgt != '')
                    SVMXActn.SVMXC__Window_Height__c = Integer.valueOf(wndwHgt);
                if(wndwWdt != null && wndwWdt != '')
                    SVMXActn.SVMXC__Window_Width__c = Integer.valueOf(wndwWdt);
                SVMXActn.SVMXC__Description__c = description;
                if(isActive != null)
                    SVMXActn.SVMXC__Active__c = Boolean.valueOf(isActive);
                SVMXActn.SVMXC__Show_Scrollbars__c = showScrollbars;
                SVMXActn.SVMXC__Open_As_Full_Window__c = openAsFullWindow;
                SVMXActn.SVMXC__Custom_action_Type__c = strActnType;
                SVMXActn.SVMXC__Service_Namespace__c = strNmSps;
                SVMXActn.SVMXC__Service_Class_Name__c = strClsNm;
                SVMXActn.SVMXC__Service_Method_Name__c = strMethNm;
                SVMXActn.SVMXC__Parent_Error_Msg__c = strPrcssingMsg;
        SVMXActn.SVMXC__SM_Schema_Name__c=schemaName;
        SVMXActn.SVMXC__SM_Path__c=path;
        SVMXActn.SVMXC__SM_Include_Object_Data_Set__c=includeObjectData;
                if(validate == true){
          //upsert SVMXActn;
          if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SVMXActn, COMM_SecurityUtils.Access.Upsertable)){
            upsert SVMXActn; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
          }
          else{
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
          }

          System.debug('Save package file -'+strActnType + ' - '+packageData);
            if(strActnType == 'Mobile-Activity-Space'){
                if(contentDocumentIdList.size() > 0){
                    System.debug('Updating Package');
                    List<ContentVersion> contentVersionList = new List<ContentVersion>();
                    List<ContentVersion> savedContentVersionList = [Select VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId IN :contentDocumentIdList];
                    if(packageData != null && savedContentVersionList != null && savedContentVersionList.size() > 0){
                        ContentVersion contentVersionData = savedContentVersionList.get(0);
                        contentVersionList.add(COMM_FileHandlerUtilities.createContentVersionInstance(contentVersionData.Id, packageName, packageData, null));
                        List<Id> listofReturnIds = COMM_FileHandlerUtilities.updateContentVersion(contentVersionList);
                        if(listofReturnIds.size() > 0){
                            System.debug('Package updated successfully');
                        }
                        else{
                            Validate = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG092()));
                        }
                        if(packageName != null){
                            savedPackageName = packageName;
                        }
                        packageData = null;
                    }
                }
                else {
                    System.debug('Creating file for uploaded package');
                    ContentVersion contentVersion = COMM_FileHandlerUtilities.createContentVersionInstance(null, packageName, packageData, null);
                    Id contentVersionId = COMM_FileHandlerUtilities.insertOneContentVersion(contentVersion);
                    if(contentVersionId != null){
                        Map<Id,Id> contentVerionMap = new Map<Id,Id>();
                        contentVerionMap.put(contentVersionId, SVMXActn.id);
                        Map<Id,Id> mapContentVersionWIthDocumentIds = COMM_FileHandlerUtilities.getContentDocumentData(contentVerionMap);
                        if(mapContentVersionWIthDocumentIds.size() == 0){
                            Validate = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG092()));
                        }
                        if(mapContentVersionWIthDocumentIds != null && mapContentVersionWIthDocumentIds.size() > 0){
                            for(Id cvId : mapContentVersionWIthDocumentIds.keySet()){
                                contentDocumentIdList.add(mapContentVersionWIthDocumentIds.get(cvId));
                            }
                        }
                        savedPackageName = packageName;
                        packageData = null;
                    }
                    else{
                        Validate = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG092()));
                    }
                }
            }
        }
            }

            for(Integer i=0; i<ListActionParameterWrapper.size(); i++)
            {
                if(mode == 'Clone')
                ListActionParameterWrapper[i].objConfigData.SVMXC__Dispatch_Process__c = SVMXActnClone.id;
                else
                ListActionParameterWrapper[i].objConfigData.SVMXC__Dispatch_Process__c = SVMXActn.id;
                if(ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Name__c == null || ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Name__c == '')
                {
                    Validate = false;
                    ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Name__c.AddError(getTAG052());
                }
                //Pattern MyPattern = Pattern.compile('^[a-zA-Z0-9]+(([_][a-zA-Z0-9])?[a-zA-Z0-9]*)*$');
                //Fix for the defect 030519- allowing special character ~_.-
                Pattern MyPattern = Pattern.compile('^[a-zA-Z0-9~_.-]*$');
                Matcher MyMatcher = MyPattern.matcher(ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Name__c);
                system.debug('Matcher MyMatcher: '+ MyMatcher.matches());
                if(!MyMatcher.matches())
                {
                    Validate = false;
                    ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Name__c.AddError(getTAG067());
                }
                if(ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == getTAG031())
                {
                    Validate = false;
                    ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c.AddError(getTAG053());
                }
                if(((ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == 'Field Name' || ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == getTAG042()) && ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Value__c == getTAG031()) || ((ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == 'Value' || ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == getTAG043()) && (ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Value__c == null || ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Value__c == '')))
                {
                    Validate = false;
                    ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Value__c.AddError(getTAG054());
                }
                if((ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == 'Field Source' || ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == getTAG084()) && ListActionParameterWrapper[i].objConfigData.SVMXC__Lookup_Field_API_Name__c == getTAG031()){
                    Validate = false;
                    ListActionParameterWrapper[i].objConfigData.SVMXC__Lookup_Field_API_Name__c.AddError(getTAG086());
                }
                if((ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == 'Field Source' || ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Type__c == getTAG084()) && ListActionParameterWrapper[i].objConfigData.SVMXC__Lookup_Field_API_Name__c != getTAG031() && ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Value__c == getTAG031()){
                    Validate = false;
                    ListActionParameterWrapper[i].objConfigData.SVMXC__Parameter_Value__c.AddError(getTAG054());
                }
            }
            SVMXActn.RecordTypeId = ActionRTypeId1;
            if(validate == true){
                /*Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> mapFields =  new Map<String, Schema.SObjectField>();
                for(String s : allObjs.keyset()){
                    Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
                    if(String.valueof(objDesc.getName()).equalsIgnoreCase(SelectedSourceObject)){
                        mapFields = objDesc.fields.getMap();
                        break;
                    }
                }
                Map<String, String> mapCapsAndSmallApiName = new Map<String, String>();
                for(String fieldName: mapFields.keyset()){
                    Schema.DescribeFieldResult fieldDesc = mapFields.get(fieldName).getDescribe();
                    mapCapsAndSmallApiName.put(fieldDesc.getName().toUpperCase(), fieldDesc.getName());
                }*/

                Map<String, Map<String, String>> mapObjectCapsAndSmallApiName = new Map<String, Map<String, String>>();
                Set<String> setRelatedObject = new Set<String>();
                for(ActionParameterWrapper objActionParameterWrapper : ListActionParameterWrapper){
                    if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Source')){
                        if(!String.isBlank(objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c) && objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c.contains('~')){
                            String[] strObjectFieldName = objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c.split('~');
                            setRelatedObject.add(strObjectFieldName[0]);
                        }
                    }
                }
                setRelatedObject.add(SelectedSourceObject);

                Schema.DescribeSobjectResult[] objDescResult = Schema.describeSObjects(new List<String>(setRelatedObject));
                for(Schema.DescribeSobjectResult objDesc : objDescResult){
                    Map<String, Schema.SObjectField> fieldsMap = objDesc.fields.getMap();

                    Map<String, Boolean> lstStdObjAccToLicense = new Map<String, Boolean>();
                    COMM_Utils comUtil = new COMM_Utils();
                    lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
                    Map<String, String> mapCapsAndSmallApiName = new Map<String, String>();

                    for(String s : fieldsMap.keyset()){
                        Schema.DescribeFieldResult fieldResult = fieldsMap.get(s).getDescribe();

                        if(fieldResult.getType() == Schema.DisplayType.Reference){
                            if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldResult.getReferenceTo()[0]))){
                                if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldResult.getReferenceTo()[0])))
                                    continue;
                            }
                        }
                        mapCapsAndSmallApiName.put(fieldResult.getName().toUpperCase(), fieldResult.getName());
                    }
                    mapObjectCapsAndSmallApiName.put(objDesc.getName(), mapCapsAndSmallApiName);
                }

                for(ActionParameterWrapper objActionParameterWrapper : ListActionParameterWrapper){
                    if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Name')){
                      objActionParameterWrapper.objConfigData.SVMXC__Object_Name2__c = '';//Added for 047352
                        if(mapObjectCapsAndSmallApiName.get(SelectedSourceObject).containsKey(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase()))
                            objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c = mapObjectCapsAndSmallApiName.get(SelectedSourceObject).get(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase());
                    }
                    else if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Source')){
                        if(!String.isBlank(objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c) && objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c.contains('~')){
                            String[] strObjectFieldName = objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c.split('~');
                            objActionParameterWrapper.objConfigData.SVMXC__Object_Name2__c = strObjectFieldName[0];
                            objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c = strObjectFieldName[1];

                            if(mapObjectCapsAndSmallApiName.get(strObjectFieldName[0]).containsKey(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase()))
                                objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c = mapObjectCapsAndSmallApiName.get(strObjectFieldName[0]).get(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase());
                        }
                    }
                }

                if(ListActionParameterWrapper.size() > 0){
                    ActionParam.clear();
                    for(ActionParameterWrapper objActionParameterWrapper : ListActionParameterWrapper){
                        ActionParam.add(objActionParameterWrapper.objConfigData);
                    }
                }
                if(ActionParam != null && ActionParam.size()>0){
                    //upsert ActionParam;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ActionParam, COMM_SecurityUtils.Access.Upsertable)){
                        upsert ActionParam; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        Validate = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    }
                }

                for(ActionParameterWrapper objActionParameterWrapper : ListActionParameterWrapper){
                    if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Name') || objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c == getTAG042())
                        objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c = objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase();
                    else if(objActionParameterWrapper.objConfigData.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Source')){
                        objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c = objActionParameterWrapper.objConfigData.SVMXC__Object_Name2__c + '~' + objActionParameterWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c;
                        objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c = objActionParameterWrapper.objConfigData.SVMXC__Parameter_Value__c.toUpperCase();
                    }
                }
            }
        }
        catch(exception ex)
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }

    //------------------------------------------- Method To Cancel --------------------------------------------------------------
    public pageReference cancel()
    {
         pageReference pageref1 = Page.CONF_ManageActions ;
         pageref1.getParameters().put('SVMX_ObjectName',SelectedSourceObject);
         return pageref1;
    }

    //------------------------------------ Method To Add new Lines for the Action Parameters -------------------------------------------------
    public pagereference addLines()
    {
        addPress = true;
        showPckLst = true;
        addLine++;
        SVMXC__ServiceMax_Config_Data__c newLine = New SVMXC__ServiceMax_Config_Data__c();
        newLine.RecordTypeId = Parameter_RType.Id;
        ActionParam.add(newLine);

        Integer i = 0;
        for(i = 0 ; i< ListActionParameterWrapper.size(); i++){
            ListActionParameterWrapper[i].objConfigData.SVMXC__Sequence__c = i+1;
        }
        newLine.SVMXC__Sequence__c = i+1;
        ActionParameterWrapper objActionParameterWrapper = new ActionParameterWrapper(newLine);
        ListActionParameterWrapper.add(objActionParameterWrapper);
        return null;
    }

    //------------------------------------ Method To Delete Lines for the Action Parameter -------------------------------------------------
    public pageReference delLines()
    {
        boolean isDeleted = false;
        ActionParamToDelete.clear();
        List<integer> selIndex = new List<integer>();

        for(Integer i=0; i<ListActionParameterWrapper.size(); i++)
        {
            if ( ListActionParameterWrapper[i].objConfigData.SVMXC__Select__c == true)
            {
                if(ListActionParameterWrapper[i].objConfigData.Id != null)
                    ActionParamToDelete.add(ListActionParameterWrapper[i].objConfigData);
                selIndex.add(i);
            }
        }
        if(selIndex.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG023()));
            return null;
        }

        for(Integer i=selIndex.size()-1; i>=0; i--)
        {
            isDeleted = true;
            ListActionParameterWrapper.remove(selIndex[i]);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG028(),''));
        }
        if(isDeleted)
        {
            if(ActionParamToDelete != null && ActionParamToDelete.size() > 0)
            {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {

                    delete ActionParamToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                  ActionParamToDelete.clear();
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
        }

        for(Integer i = 0; i<ListActionParameterWrapper.size(); i++){
            ListActionParameterWrapper[i].objConfigData.SVMXC__Sequence__c = i+1;
        }

        if(addPress == true)
        addLine--;



        return null;
    }

    //------------------------------------ On change of the Parameter Type -------------------------------------------------
    public integer intIndex;
    public integer getintIndex(){return this.intIndex;}
    public void setintIndex(integer index){this.intIndex = index;}
    public pageReference onChngParamType()
    {
        system.debug('paramType: ' + paramType + ' = ' +getTAG042() + ' / ' + getTAG043());
        if(paramType == 'Field Name' || paramType == getTAG042())
        {
            system.debug('Entered in first If hence paramType is checked');
            showPckLst = true;
            showText = false;
            renderRow = true;
        }
        else if(paramType == 'Value' || paramType == getTAG043())
        {
            system.debug('Entered in second If hence paramType is checked');
            showPckLst = false;
            showText = true;
            renderRow = false;
        }

        for(ActionParameterWrapper objAPWrapper : ListActionParameterWrapper)
        {
            System.debug('intIndex: '+intIndex);
            System.debug('SVMXC__Sequence__c: '+objAPWrapper.objConfigData.SVMXC__Sequence__c);
            if(intIndex == objAPWrapper.objConfigData.SVMXC__Sequence__c){
                System.debug('intIndex: '+intIndex);
                System.debug('intIndex: '+objAPWrapper.objConfigData.SVMXC__Parameter_Type__c);
                if(objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == 'Field Source' || objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == getTAG084()){
                    objAPWrapper.disableParameterSource = false;
                    objAPWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c = getTAG031();
                    objAPWrapper.objConfigData.SVMXC__Parameter_Value__c = getTAG031();
                    //objAPWrapper.ObjFieldList.collectionList.clear();//Commented for BAC-5583
                    if (objAPWrapper.objConfigData.SVMXC__Object_Name2__c != null && objAPWrapper.objConfigData.SVMXC__Object_Name2__c !='') { //Added for defect-047352
                        List<SelectOption> lstFieldSO = getFieldList(objAPWrapper.objConfigData.SVMXC__Object_Name2__c);
                        mapObjWithFields.put(objAPWrapper.objConfigData.SVMXC__Object_Name2__c,lstFieldSO);
                    }
                    objAPWrapper.RelatedObjects.clear();
                    objAPWrapper.RelatedObjects.addAll(ParameterSourcePckLst);
                    System.debug('ParameterSourcePckLst: '+ParameterSourcePckLst);
                    //System.debug('objAPWrapper.ObjFieldList.collectionList: '+objAPWrapper.ObjFieldList.collectionList);
                }
                else if(objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == 'Field Name' || objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == getTAG042()){
                    objAPWrapper.RelatedObjects.clear();
                    objAPWrapper.RelatedObjects.addAll(ParameterSourcePckLst);
                    objAPWrapper.disableParameterSource = true;
                    objAPWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c = SelectedSourceObject;
                    objAPWrapper.objConfigData.SVMXC__Parameter_Value__c = getTAG031();
                    paramSource = SelectedSourceObject;
                    onChngParamSource();
                }
                else if(objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == 'Value' || objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == getTAG043()){
                    objAPWrapper.disableParameterSource = true;
                    objAPWrapper.RelatedObjects.clear();
                    objAPWrapper.objConfigData.SVMXC__Parameter_Value__c = null;
                }
                else if(objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == '--None--' || objAPWrapper.objConfigData.SVMXC__Parameter_Type__c == getTAG031()){
                    objAPWrapper.disableParameterSource = true;
                    objAPWrapper.RelatedObjects.clear();
                }
                break;
            }
        }

        return null;
    }

    public integer intIndexParamSource;
    public integer getintIndexParamSource(){return this.intIndexParamSource;}
    public void setintIndexParamSource(integer intIndexParamSource){this.intIndexParamSource = intIndexParamSource;}
    //Added new method for the story BAC-4706 which executes on change of parameter source
    public pageReference onChngParamSource(){
        System.debug('paramSource: '+paramSource);
        System.debug('intIndexParamSource: '+intIndexParamSource);
        if(paramSource != null && paramSource !='' && paramSource != getTAG031()){
            for(ActionParameterWrapper objAPWrapper : ListActionParameterWrapper){
                if(intIndexParamSource == objAPWrapper.objConfigData.SVMXC__Sequence__c && paramSource == objAPWrapper.objConfigData.SVMXC__Lookup_Field_API_Name__c){
                    //Call method to populate fields and break
                    System.debug('paramSource: '+paramSource);
                    String strObjectApiName = paramSource.split('~')[0];
                    System.debug('strObjectApiName: '+strObjectApiName);
                    List<SelectOption> lstFieldSelectOption = getFieldList(strObjectApiName);
                    System.debug('lstFieldSelectOption: '+lstFieldSelectOption);
                    /*Commented for BAC-5583
                    FieldListWrapper listOfFields = new FieldListWrapper();
                    listOfFields.collectionList = lstFieldSelectOption;
                    objAPWrapper.ObjFieldList = listOfFields;
                    */
                    if (objAPWrapper.objConfigData.SVMXC__Object_Name2__c != null && strObjectApiName != null) { //Added for 047418
                        objAPWrapper.objConfigData.SVMXC__Object_Name2__c = strObjectApiName;
                    }
                    objAPWrapper.objConfigData.SVMXC__Parameter_Value__c = getTAG031(); //Added for 047418 
                    objAPWrapper.objNameDefination = strObjectApiName; //Added for BAC-5583
                    mapObjWithFields.put(strObjectApiName,lstFieldSelectOption); //Added for BAC-5583
                }
            }
        }
        return null;
    }

    //Added new method for the story BAC-4706 which return list of fields in the form of SelectOption for the passed object
    public List<SelectOption> getFieldList(String strObjectName){
        List<SelectOption> lstFieldSelectOption = new List<SelectOption>();
        lstFieldSelectOption.add(new SelectOption(getTAG031(),getTAG031()));
        Schema.DescribeSobjectResult objDesc = Schema.describeSObjects(new List<String>{strObjectName})[0];

        Map<String, Schema.SObjectField> fieldsMap = objDesc.fields.getMap();

        Map<String, Boolean> lstStdObjAccToLicense = new Map<String, Boolean>();
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();

        for(String s : fieldsMap.keyset())
        {
            Schema.DescribeFieldResult fieldResult = fieldsMap.get(s).getDescribe();

            if(fieldResult.getType() == Schema.DisplayType.Reference)
            {
                if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldResult.getReferenceTo()[0])))
                {
                    if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldResult.getReferenceTo()[0])))
                    {
                        continue;
                    }
                }
            }
            lstFieldSelectOption.add(new SelectOption(fieldResult.getName().toUpperCase(), fieldResult.getLabel()));
        }
        lstFieldSelectOption = sortingSelectOption(lstFieldSelectOption);
        return lstFieldSelectOption;
    }

    //------------------------------------ On change of the value of Full Window -------------------------------------------------
    public pageReference isFullWindow()
    {
        if(openAsFullWindow == true || URLTrgtType == 'Existing Window')
            DisableHeightWidthFields = true;
        else
            DisableHeightWidthFields = false;
        return null;
    }

    //------------------------------------ Getter Methods for Tags -------------------------------------------------
    public String getTAG001(){return string.escapeSingleQuotes(system.label.CONF018_TAG025);}//ServiceMax Action details for:
    public String getTAG002(){return string.escapeSingleQuotes(system.label.CONF018_TAG026);}//Quick Save
    public String getTAG003(){return string.escapeSingleQuotes(system.label.CONF018_TAG027);}//Save & Close
    public String getTAG004(){return string.escapeSingleQuotes(system.label.CONF018_TAG028);}//Cancel
    public String getTAG005(){return string.escapeSingleQuotes(system.label.CONF018_TAG029);}//Object
    public String getTAG006(){return string.escapeSingleQuotes(system.label.CONF018_TAG030);}//URL Target Type
    public String getTAG007(){return string.escapeSingleQuotes(system.label.CONF018_TAG031);}//Action URL
    public String getTAG008(){return string.escapeSingleQuotes(system.label.CONF018_TAG032);}//Select
    public String getTAG009(){return string.escapeSingleQuotes(system.label.CONF018_TAG033);}//Action Title
    public String getTAG010(){return string.escapeSingleQuotes(system.label.CONF018_TAG034);}//Description
    public String getTAG011(){return string.escapeSingleQuotes(system.label.CONF018_TAG035);}//Action ID
    public String getTAG012(){return string.escapeSingleQuotes(system.label.CONF018_TAG036);}//Window Height
    public String getTAG013(){return string.escapeSingleQuotes(system.label.CONF018_TAG037);}//Window Width
    public String getTAG014(){return string.escapeSingleQuotes(system.label.CONF018_TAG038);}//Specify the parameters for the Action URL. These parameters will be generated and added to the URL at runtime.
    public String getTAG015(){return string.escapeSingleQuotes(system.label.CONF018_TAG039);}//Parameter Name
    public String getTAG016(){return string.escapeSingleQuotes(system.label.CONF018_TAG040);}//Is Active
    public String getTAG017(){return string.escapeSingleQuotes(system.label.CONF018_TAG041);}//Delete
    public String getTAG018(){return string.escapeSingleQuotes(system.label.CONF018_TAG042);}//Are you sure you want to delete the selected Parameter(s)?
    public String getTAG019(){return string.escapeSingleQuotes(system.label.CONF018_TAG019);}//Processing...
    public String getTAG021(){return string.escapeSingleQuotes(system.label.CONF018_TAG044);}//Parameter Value Type
    public String getTAG022(){return string.escapeSingleQuotes(system.label.CONF018_TAG045);}//Parameter Value
    public String getTAG023(){return string.escapeSingleQuotes(system.label.CONF018_TAG046);}//Select at least one Parameter to delete
    public String getTAG024(){return string.escapeSingleQuotes(system.label.CONF018_TAG047);}//Action Home Help
    public String getTAG025(){return string.escapeSingleQuotes(system.label.CONF018_TAG048);}//Back
    public String getTAG026(){return string.escapeSingleQuotes(system.label.CONF018_TAG049);}//Saved successfully
    public String getTAG027(){return string.escapeSingleQuotes(system.label.CONF018_TAG050);}//Add
    public String getTAG028(){return string.escapeSingleQuotes(system.label.CONF018_TAG051);}//Successfully deleted the selected Parameter(s).
    public String getTAG029(){return string.escapeSingleQuotes(system.label.CONF018_TAG052);}//Action Name cannot be left blank.
    public String getTAG030(){return string.escapeSingleQuotes(system.label.CONF018_TAG053);}//Action Id cannot be left blank.
    public String getTAG031(){return string.escapeSingleQuotes(system.label.CONF018_TAG022);}//--None--
    public String getTAG033(){return string.escapeSingleQuotes(system.label.CONF018_TAG054);}//An internal error occurred. Please contact your ServiceMax administrator to resolve this.
    public String getTAG038(){return string.escapeSingleQuotes(system.label.CONF018_TAG055);}//Action Id cannot be left blank.
    public String getTAG040(){return string.escapeSingleQuotes(system.label.CONF018_TAG056);}//
    public String getTAG041(){return string.escapeSingleQuotes(system.label.CONF018_TAG057);}//
    public String getTAG042(){return string.escapeSingleQuotes(system.label.CONF018_TAG058);}//
    public String getTAG043(){return string.escapeSingleQuotes(system.label.CONF018_TAG059);}//
    public String getTAG052(){return string.escapeSingleQuotes(system.label.CONF018_TAG060);}//Please enter a valid Action Parameter Name
    public String getTAG053(){return string.escapeSingleQuotes(system.label.CONF018_TAG061);}//Please enter a valid Action Parameter Name
    public String getTAG054(){return string.escapeSingleQuotes(system.label.CONF018_TAG062);}//Please enter a valid Action Parameter Name
    public String getHLPURL(){return string.escapeSingleQuotes(system.label.CONF018_HLPURL);}//
    public String getTAG055(){return string.escapeSingleQuotes(system.label.CONF018_TAG043);}//'Show Scrollbars'
    public String getTAG056(){return string.escapeSingleQuotes(system.label.CONF018_TAG063);}//'Please enter a unique Action ID for the Action.'
    public String getTAG057(){return string.escapeSingleQuotes(system.label.CONF018_TAG064);}//'Open As Full Window'
    // created by sharad
    public String getTAG058(){return string.escapeSingleQuotes(system.label.CONF018_TAG065);}//'Action Type'
    public String getTAG059(){return string.escapeSingleQuotes(system.label.COMM001_TAG059);}//'Mandatory Field should not be empty'
    public String getTAG060(){return string.escapeSingleQuotes(system.label.CONF018_TAG066);}//'Namespace Prefix'
    public String getTAG061(){return string.escapeSingleQuotes(system.label.CONF018_TAG067);}//'Class Name'
    public String getTAG062(){return string.escapeSingleQuotes(system.label.CONF018_TAG068);}//'Method Name'
    public String getTAG063(){return string.escapeSingleQuotes(system.label.CONF018_TAG069);}//'Processing Message'
    public String getTAG064(){return string.escapeSingleQuotes(system.label.CONF018_TAG072);}//'URL'
    public String getTAG065(){return string.escapeSingleQuotes(system.label.CONF018_TAG071);}//'Web Service'

    public String getTAG066(){return string.escapeSingleQuotes(system.label.COMM001_TAG077);}//showing error
    public String getTAG067(){return string.escapeSingleQuotes(system.label.CONF018_TAG075);}// No special characters are allowed except _
    public String getTAG068(){return string.escapeSingleQuotes(system.label.CONF018_TAG076);}// Modal Window
    public String getTAG069(){return string.escapeSingleQuotes(system.label.CONF018_TAG077);}// Opening of custom actions in modal window is supported only to dispay technical attributes for an installed product!

    //new custom Label for App to App
    public String getTAG070(){return string.escapeSingleQuotes(system.label.CONF018_TAG078);}//app to app
    public String getTAG071(){return string.escapeSingleQuotes(system.label.CONF018_TAG079);}//Schema
    public String getTAG072(){return string.escapeSingleQuotes(system.label.CONF018_TAG080);}//Path
    public String getTAG073(){return string.escapeSingleQuotes(system.label.CONF018_TAG081);}//Include Object data
    public String getTAG074(){return string.escapeSingleQuotes(system.label.CONF018_TAG082);}//Path error
    public string getTAG075(){return string.escapeSingleQuotes(system.label.CONF018_TAG083);}//Schema Error
    //new custom Label for App to App

    //Added for the story BAC-4706
    public string getTAG084(){return string.escapeSingleQuotes(system.label.CONF018_TAG084);}//Field Source
    public string getTAG085(){return string.escapeSingleQuotes(system.label.CONF018_TAG085);}//Parameter Source
    public string getTAG086(){return string.escapeSingleQuotes(system.label.CONF018_TAG086);}//Please enter a valid Action Parameter Source

    //new custom Label for Mobile Activity Space
    public String getTAG087(){return string.escapeSingleQuotes(system.label.CONF018_TAG087);}//Mobile Activity Space
    public String getTAG088(){return string.escapeSingleQuotes(system.label.CONF018_TAG088);}//Upload Package
    public String getTAG089(){return string.escapeSingleQuotes(system.label.CONF018_TAG089);}//Package size limit should be less than 50MB
    public String getTAG090(){return string.escapeSingleQuotes(system.label.CONF018_TAG090);}//Saved Package
    public String getTAG091(){return string.escapeSingleQuotes(system.label.CONF018_TAG091);}//Package is Mandatory
    public String getTAG092(){return string.escapeSingleQuotes(system.label.CONF018_TAG092);}//Error while saving package
    public String getTAG093(){return string.escapeSingleQuotes(system.label.CONF018_TAG093);}//(Maximum File Limit is 10MB)
}