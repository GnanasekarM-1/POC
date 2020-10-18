/*--------------------------------------------File Definition ----------------------*/
//DXT_Console is the controller class for VF page DXT_Console
//Created as part of Dec 13 Sprint for Quick Book extract feature development

public with sharing class DXT_Console {

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

/*---------------Global variable declaration----------------------*/

    //public List<String> lstDisplayFields{set; get;}
    public List<DisplayFieldWrapper> lstDisplayFieldWrapper{set; get;}
    public List<DXT_Console.sObjectWrapper> lstSObjectWrapper{set; get;}    
    public List<TransactionWrapper> lstTRANSWrapper = new List<TransactionWrapper>();
    public List<TransactionWrapper> lstSPLWrapper = new List<TransactionWrapper>();
    public List<SourceUpdateWrapper> lstSourceUpdate = new List<SourceUpdateWrapper>();
    public List<String> lstColumnLabel{set; get;}   
    public String sObjectId{set; get;}
    public String eMailId{set; get;}
    public Set<String> setID = new Set<String>();
    public String strFilterDateField{set; get;}
    public Case objCase{set; get;}
    public String strHeaderObjectAPIName;
    public String strChildObjectAPIName;
    public String strDefaultSortingField;
    public String strHeaderEligibilityCriteriaID;
    public String strChildEligibilityCriteriaID;
    public transient String strFileContent{set; get;}
    public Integer size{get;set;}
    public String strNavigateType{set; get;}
    public Integer noOfRecords{get; set;}
    public boolean messageStatus = false;
    public boolean getmessageStatus(){
        return messageStatus;
    }
    public Boolean hasNext {
        get { return standardSetControllerForRecords.getHasNext();}
        set;
    }
    public Boolean hasPrevious {
        get {return standardSetControllerForRecords.getHasPrevious();}
        set;                            
    }
    public Integer pageNumber {
       get {return standardSetControllerForRecords.getPageNumber();}
       set;
    }
    public list<SelectOption> lstSize{
        get{
            list<SelectOption> options = new list<SelectOption>();
            options.add(new SelectOption('100','100'));
            options.add(new SelectOption('200','200'));
            options.add(new SelectOption('500','500'));
            return options;
        }
    }
    public String strFileName{
        get{
            String dt = System.now().format('MM/dd/YYYY');
            return getTAG016()+dt+'.iif';
        }
    }    
    private String strQuery{set; get;}
    private String strBaseQuery{set; get;}    
    private DateTime fromDT{set; get;}
    private DateTime toDT{set; get;}
    private Date fromDate{set; get;}
    private Date toDate{set; get;}
    private String strFilterDateFieldLabel {set; get;}
    private ApexPages.Standardsetcontroller standardSetControllerForRecords {
        get
        {
            if(standardSetControllerForRecords == null)             
            {
                String Temp = strQuery;
                if(strDefaultSortingField != null && strDefaultSortingField.length() > 0)
                    Temp = strQuery + ' Order By ' + strDefaultSortingField + ' Limit 10000';
                else
                    Temp = strQuery + ' Limit 10000';
                standardSetControllerForRecords= new ApexPages.StandardSetController(Database.getQueryLocator(Temp));
                standardSetControllerForRecords.setPageSize(size);
                standardSetControllerForRecords.setPageNumber(1);
                noOfRecords = standardSetControllerForRecords.getResultSize();
            }
            return standardSetControllerForRecords;
        }
        set;
    }

    
/*---------------Wrapper/definition/classes declaration------------------*/

    //Wrapper class to store JSON configuration Information
    public class JSONConfigWrapper{
        public String headerObjectAPIName;   
        public String childObjectAPIName;
        public String headerEligibilityCriteriaID;
        public String childEligibilityCriteriaID;
        public String filterDateField;
        public String defaultSortingField;
        public List<String> displayFields;
        public List<TransactionWrapper> TRNS;
        public List<TransactionWrapper> SPL;
        public List<SourceUpdateWrapper> sourceUpdate;
        
        public JSONConfigWrapper(String headerObjectAPIName, String childObjectAPIName, String headerEligibilityCriteriaID, String childEligibilityCriteriaID, String filterDateField, String defaultSortingField, List<String> displayFields, List<TransactionWrapper> TRNS, List<TransactionWrapper> SPL, List<SourceUpdateWrapper> sourceUpdate){
            this.headerObjectAPIName = headerObjectAPIName; 
            this.childObjectAPIName = childObjectAPIName; 
            this.headerEligibilityCriteriaID = headerEligibilityCriteriaID;
            this.childEligibilityCriteriaID = childEligibilityCriteriaID;
            this.filterDateField = filterDateField;
            this.defaultSortingField = defaultSortingField;
            this.displayFields = displayFields;
            this.TRNS = TRNS;
            this.SPL = SPL;
            this.sourceUpdate = sourceUpdate;
        }
   }
    
    //Wrapper class to store TRANS and SPL Information
    public class TransactionWrapper{
        public String label;
        public String fieldSeq;
        public String value;
        public String isNeg;
        public String valueType;
        public String dataType;
        
        public TransactionWrapper(String label, String fieldSeq, String value, String isNeg, String valueType, String dataType){
            this.label = label;
            this.fieldSeq = fieldSeq;
            this.value = value;
            this.isNeg = isNeg;
            this.valueType = valueType;
            this.dataType = dataType;
        }
    }
      
   //Wrapper class to store object records and corresponding boolean status (it is selected or not)
    public class sObjectWrapper{
        public boolean isSelect{set; get;}
        public sObject objSObject{set; get;}
        public sObjectWrapper(boolean isSelect, sObject objSObject){
            this.isSelect = isSelect;
            this.objSObject = objSObject;
        }
    }
    
    //Wrapper class to store Enging Response (Message and Success status)
    public class EngineResponse{
        public boolean isSucess;
        public String strMessage;
        public EngineResponse(){}
        public EngineResponse(boolean isSucess, String strMessage){
            this.isSucess = isSucess;
            this.strMessage = strMessage;
        }
    }
    
   // Wrapper class to store Engine Request
    public class EngineRequest{
        public List<String> lstHeaderIds;
        public List<DXT_Console.TransactionWrapper> lstTRANSWrapper;
        public List<DXT_Console.TransactionWrapper> lstSPLWrapper;
        public String strEmailId;
        public boolean isSendmail;
        public String strHeaderObjeName;
        public String strChildObjName;
        public String strChildCriteriaId;
        public List<SourceUpdateWrapper> lstSourceUpdate;
        public EngineRequest(List<String> lstHeaderIds, List<DXT_Console.TransactionWrapper> lstTRANSWrapper, List<DXT_Console.TransactionWrapper> lstSPLWrapper, String strEmailId, boolean isSendmail, String strHeaderObjeName, String strChildObjName, String strChildCriteriaId, List<SourceUpdateWrapper> lstSourceUpdate){
            this.lstHeaderIds = lstHeaderIds;
            this.lstTRANSWrapper = lstTRANSWrapper;
            this.lstSPLWrapper = lstSPLWrapper;
            this.strEmailId = strEmailId;
            this.isSendmail = isSendmail;
            this.strHeaderObjeName = strHeaderObjeName;
            this.strChildObjName = strChildObjName;
            this.strChildCriteriaId = strChildCriteriaId;
            this.lstSourceUpdate = lstSourceUpdate;
        }
    }
    
    //Wrapper class to store source update information
    public class SourceUpdateWrapper{
        public String field;
        public String operator;
        public String value;
        public SourceUpdateWrapper(String field, String operator, String value){
            this.field = field;
            this.operator = operator;
            this.value = value;
        }
    }
    
    //Wrapper class to maintain which is reference field and normal field
    public class DisplayFieldWrapper{
        public String strFieldName{set; get;}
        public Boolean isReference{set; get;}
        public DisplayFieldWrapper(String strFieldName, Boolean isReference){
            this.strFieldName = strFieldName;
            this.isReference = isReference;
        }
    }
    
/*-----------------------------------Wrapper classes End Here-----------------------------------------------------------------------------*/
   
/*-----------------------------------------------CONSTRUCTOR------------------------------------------------------------------------------*/   
    public DXT_Console(){        
        try{
            lstSObjectWrapper = new List<DXT_Console.sObjectWrapper>();
            strFilterDateFieldLabel = '';
            List<SVMXC__ServiceMax_Processes__c> lstProcess = [SELECT id, SVMXC__Export_Configuration__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Export Configuration' AND SVMXC__IsDefault__c = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstProcess.size() == 0){
                messageStatus = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG017(), ''));
            }
            else if(lstProcess.size() >= 2){
                messageStatus = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG018(), ''));
            }
            else if(lstProcess[0].SVMXC__Export_Configuration__c != null && lstProcess[0].SVMXC__Export_Configuration__c.length()>0){
                String JSONString = lstProcess[0].SVMXC__Export_Configuration__c;            
                size = 100;
                objCase = new Case();
                eMailId = UserInfo.getUserEmail();
                System.debug(logginglevel.WARN, 'List of Process : '+lstProcess);
                methodForDeserialize(JSONString);
            }
        }
        catch(Exception ex){            
            System.debug(logginglevel.WARN, 'Exception in Constructor : '+ex.getMessage());
        }
    }
    
    
/*--------------------------------------------Public methods-------------------------------------*/

    //method to export selected records as a IIF file
    public PageReference exportData(){
        try{
            messageStatus = true;
            setID = createSetOfId();
            if(setID.size() > 0){
                DXT_Utilities objClass = new DXT_Utilities();         
                EngineRequest objEngineRequest = new EngineRequest(createListOfId(), lstTRANSWrapper, lstSPLWrapper, eMailId, true, strHeaderObjectAPIName, strChildObjectAPIName, strChildEligibilityCriteriaID, lstSourceUpdate);
                EngineResponse objEngineResponse =  objClass.generateIIFFile(objEngineRequest);
                System.debug(logginglevel.WARN, 'obj Engine Response in exportData() method : '+objEngineResponse);
                if(objEngineResponse != null){
                    if(objEngineResponse.isSucess == false)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objEngineResponse.strMessage,''));
                    else{
                        setID.clear();
                        standardSetControllerForRecords = null;
                        queryExecuter();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,getTAG001(),''));
                    }
                }
            }
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG002(),''));
        }
        catch(Exception ex){            
            System.debug(logginglevel.WARN, 'Exception in exportData() method : '+ex.getMessage());
        }
        return null;
    }  
        
    
    //for saving file into the Disk    
    public PageReference saveIIFFile(){
        try{
            setID = createSetOfId();
            if(setID.size() > 0){
                DXT_Utilities objClass = new DXT_Utilities();
                EngineRequest objEngineRequest = new EngineRequest(createListOfId(), lstTRANSWrapper, lstSPLWrapper, eMailId, false, strHeaderObjectAPIName, strChildObjectAPIName, strChildEligibilityCriteriaID, lstSourceUpdate);          
                EngineResponse objEngineResponse =  objClass.generateIIFFile(objEngineRequest);   
                System.debug(logginglevel.WARN, 'obj Engine Response in saveIIFFile() method : '+objEngineResponse);
                if(objEngineResponse != null){
                    if(objEngineResponse.isSucess == true){
                        strFileContent = objEngineResponse.strMessage;
                        setID.clear();
                        standardSetControllerForRecords = null;
                        queryExecuter();
                        messageStatus = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,getTAG001(),''));
                    }
                    else{
                        messageStatus = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objEngineResponse.strMessage,''));
                    }
                }
            }
            else{
                strFileContent = '';
                messageStatus = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG002(),''));
            }
        }
        catch(Exception ex){            
            System.debug(logginglevel.WARN, 'Exception in saveIIFFile() method : '+ex.getMessage());
        }
        return null;
    }
    
    //method to filter records between two dates
    public PageReference filterRecordsBetweenDates(){
        try{
            if(objCase.SVMXC__BW_Date__c != null && objCase.SVMXC__Scheduled_Date__c != null){
                fromDate = objCase.SVMXC__BW_Date__c;
                toDate = objCase.SVMXC__Scheduled_Date__c;
                if(fromDate.daysBetween(toDate) >= 0){                    
                    toDate = toDate.addDays(1);
                    String strFieldDataType = getDataTypeOfField(strHeaderObjectAPIName, strFilterDateField);
                    if(strFieldDataType.equals('DATE')){
                        if(strBaseQuery.contains(strHeaderObjectAPIName+' WHERE'))
                            strQuery = strBaseQuery + ' AND '+strFilterDateField+' >=: fromDate AND '+strFilterDateField+' <: toDate';
                        else
                            strQuery = strBaseQuery + ' WHERE '+strFilterDateField+' >=: fromDate AND '+strFilterDateField+' <: toDate';
                    }
                    else if(strFieldDataType.equals('DATETIME')){
                        Time tm = Time.newInstance(0,0,0,0);
                        fromDT = Datetime.newInstance(fromDate, tm);
                        toDT = Datetime.newInstance(toDate, tm);
                        if(strBaseQuery.contains(strHeaderObjectAPIName+' WHERE'))
                            strQuery = strBaseQuery + ' AND '+strFilterDateField+' >=: fromDT AND '+strFilterDateField+' <: toDT';
                        else
                            strQuery = strBaseQuery + ' WHERE '+strFilterDateField+' >=: fromDT AND '+strFilterDateField+' <: toDT';
                    }
                    else{
                        messageStatus = true;
                        lstSObjectWrapper.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG015(),''));
                        return null;
                    }
                    System.debug(logginglevel.WARN, 'strQuery in  filterRecordsBetweenDates() method : '+strQuery);
                    standardSetControllerForRecords=null;
                    messageStatus = false;
                    setID.clear();
                    queryExecuter();
                }
                else{
                    messageStatus = true;
                    lstSObjectWrapper.clear();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG003(),''));
                }
            }
            else{
                strQuery = strBaseQuery;
                standardSetControllerForRecords=null;
                setID.clear();
                queryExecuter();
            }
        }
        catch(Exception ex){            
            System.debug(logginglevel.WARN, 'Exception in filterRecordsBetweenDates() method : '+ex.getMessage());
        }
        return null;
    }   
    
    //code for pagination
    public void Navigate(){
        setID = createSetOfId();
        if(strNavigateType.equals('first'))
            standardSetControllerForRecords.first();
        else if(strNavigateType.equals('previous'))
            standardSetControllerForRecords.previous();
        else if(strNavigateType.equals('next'))
            standardSetControllerForRecords.next();
        else if(strNavigateType.equals('last'))
            standardSetControllerForRecords.last();
        queryExecuter();
    }
    
    //method to show different number of records on basis of (Show) picklist value selected.
    public pageReference userSelectedNumber() {
        standardSetControllerForRecords=null;
        setID = createSetOfId();
        queryExecuter();   
        return null;
    }
/*--------------------------------------------Public methods Ends here------------------------------------*/



/*--------------------------------------------Private methods------------------------------------*/
    
    //creating Field API Label from Field API Name
    private List<String> convertAPINameToLabel(String strObjectAPIName, List<String> lstFieldAPIName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<String> lstLabelName = new List<String>();
        Map<String, String> mapFieldApiNameAndLabel = new Map<String, String>();
        
        Schema.SObjectType leadSchema = schemaMap.get(strObjectAPIName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();   
        for (String fieldName: fieldMap.keySet()){
            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
            mapFieldApiNameAndLabel.put(fieldResult.getName(), fieldResult.getLabel());
        }   
        for(String str : lstFieldAPIName)
            lstLabelName.add(mapFieldApiNameAndLabel.get(str));
        return lstLabelName;
    }
    
    //Method to Deserialize the JSON String
    private void methodForDeserialize(String JSONStr){
        try{
            DXT_Console.JSONConfigWrapper objConfigForDeSerial = (DXT_Console.JSONConfigWrapper)JSON.deserialize(JSONStr, DXT_Console.JSONConfigWrapper.class);
            System.debug(logginglevel.WARN, 'objConfigForDeSerial in  methodForDeserialize() method : '+objConfigForDeSerial);
            strHeaderObjectAPIName = objConfigForDeSerial.headerObjectAPIName;
            strChildObjectAPIName = objConfigForDeSerial.childObjectAPIName;
            strHeaderEligibilityCriteriaID = objConfigForDeSerial.headerEligibilityCriteriaID;
            strChildEligibilityCriteriaID = objConfigForDeSerial.childEligibilityCriteriaID;
            strFilterDateField = objConfigForDeSerial.filterDateField; 
            strDefaultSortingField = objConfigForDeSerial.defaultSortingField;          
            lstSourceUpdate = objConfigForDeSerial.sourceUpdate;            
            List<String> lstDisplayFields = objConfigForDeSerial.displayFields;
            lstTRANSWrapper = objConfigForDeSerial.TRNS;
            lstSPLWrapper = objConfigForDeSerial.SPL;
            lstDisplayFieldWrapper = new List<DisplayFieldWrapper>();           
            
            List<String> lstColumnApiName = new List<String>();
            for(String name : lstDisplayFields){        
                if(name.contains('.')){
                    String x= name.substringBefore('.');
                    x = x.substring(0,x.length()-1);
                    x = x+'c';
                    lstColumnApiName.add(x);
                    lstDisplayFieldWrapper.add(new DisplayFieldWrapper(name, true));
                }
                else{
                    lstColumnApiName.add(name);
                    lstDisplayFieldWrapper.add(new DisplayFieldWrapper(name, false));
                }
            }
            if((strHeaderObjectAPIName != null && strHeaderObjectAPIName.length() > 0) && (lstColumnApiName.size()>0))
                lstColumnLabel = convertAPINameToLabel(strHeaderObjectAPIName, lstColumnApiName);
            
            if((strHeaderObjectAPIName != null && strHeaderObjectAPIName.length() > 0) && strFilterDateField != null && strFilterDateField.length() > 0){
                List<String> lstFieldDateField = new List<String>();
                lstFieldDateField.add(strFilterDateField);
                List<String> lstTemp = convertAPINameToLabel(strHeaderObjectAPIName, lstFieldDateField);
                if(lstTemp.size() > 0)
                    strFilterDateFieldLabel = lstTemp[0];
            }
            
            //for fields list in query
            List<SVMXC__ServiceMax_Processes__c> lstSVMXRule = new List<SVMXC__ServiceMax_Processes__c>();
            if(strHeaderEligibilityCriteriaID != null && strHeaderEligibilityCriteriaID.length() > 0)
                lstSVMXRule =  [SELECT Id, SVMXC__Parent_Object_Criteria__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__Source_Object_Name__c =: strHeaderObjectAPIName AND SVMXC__ProcessID__c =: strHeaderEligibilityCriteriaID Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug(logginglevel.WARN, 'lstSVMXRule in  methodForDeserialize() method : '+lstSVMXRule);
            String strCriteria ='';
            if(lstSVMXRule.size() > 0)
                strCriteria = lstSVMXRule[0].SVMXC__Parent_Object_Criteria__c;
            
            String strFields = '';       
            for(String Field : lstDisplayFields){
                strFields += Field + ',';
            }
            strFields = strFields.substring(0, strFields.length()-1);
            
            strBaseQuery = strQuery = 'SELECT '+ strFields + ' FROM '+strHeaderObjectAPIName;
                
            if(strCriteria.length() > 0)
                strBaseQuery = strQuery = strQuery +' WHERE '+ strCriteria;
            
            System.debug(logginglevel.WARN, 'strBaseQuery and strQuery in  methodForDeserialize() method : '+strBaseQuery);
            queryExecuter();
        }
        catch(Exception ex){
            messageStatus = true;     
            System.debug(logginglevel.WARN, 'Exception in methodForDeserialize() method : '+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG005() +' '+ ex.getMessage(),''));
        }
    }
    
    //Method to refresh the record list
    private void queryExecuter(){
        try{
            boolean boolIsSelect =false;        
            List<sObject> lstSObject = (List<sObject>)standardSetControllerForRecords.getRecords();     
            System.debug(logginglevel.WARN, 'lstSObject in  queryExecuter() method : '+lstSObject);
            lstSObjectWrapper = new List<DXT_Console.sObjectWrapper>();
            for(sObject obj : lstSObject){
                if(setID.contains(String.valueOf(obj.get('Id'))))
                    boolIsSelect = true;
                else
                    boolIsSelect = false;
                DXT_Console.sObjectWrapper objWork = new DXT_Console.sObjectWrapper(boolIsSelect, obj);
                lstSObjectWrapper.add(objWork);
            }
            System.debug(logginglevel.WARN, 'lstSObjectWrapper in  queryExecuter() method : '+lstSObjectWrapper);
        }
        catch(Exception ex){
            messageStatus = true;           
            System.debug(logginglevel.WARN, 'Exception in queryExecuter() method : '+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG005() +' '+ ex.getMessage(),''));
        }
    }
    
    //convert list of id (coming from page) into set of String id
    private Set<String> createSetOfId(){
        Set<String> setOfID = new Set<String>();
        List<String> lstStringID = new List<String>();
        if(sObjectId != null && sObjectId.length() > 0)
            lstStringID = sObjectId.split(',');
        setOfID.addAll(lstStringID);
        System.debug(logginglevel.WARN, 'setOfID in  createSetOfId() method : '+setOfID);
        return setOfID;
    }
    
    //convert list of id (coming from page) into List of String id
    private List<String> createListOfId(){
        List<String> lstID = new List<String>();
        if(sObjectId != null && sObjectId.length() > 0)
            lstID = sObjectId.split(',');
        System.debug(logginglevel.WARN, 'lstID in  createListOfId() method : '+lstID);
        return lstID;
    }
    
    //method to get the datatype of field
    private String getDataTypeOfField(String objectAPIName, String fieldAPIName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectAPIName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult o = fieldMap.get(fieldName).getDescribe();
            if(o.getName().equals(fieldAPIName))
                return String.valueOf(o.getType());
        }
        return '';
    }
    
/*--------------------------------------------Private methods Ends here------------------------------------*/


/*--------------------------------------------Tags methods------------------------------------*/
    public String getTAG001(){return System.label.DXT001_TAG002;} //Data Exported Successfully.
    public String getTAG002(){return System.label.COMM001_TAG050;} //Please select at least one record to perform this action
    public String getTAG003(){return System.label.DXT001_TAG003;} //To Date should be greater than From Date.    
    public String getTAG004(){return System.label.DXT001_TAG015;} //There are no records to display.
    public String getTAG005(){return System.label.DXT001_TAG004;} //Invalid Configuration
    public String getTAG006(){return System.label.COMM001_TAG041;} //Processing...
    public String getTAG007(){return System.label.DXT001_TAG007;} //From:
    public String getTAG008(){return System.label.DXT001_TAG008;} //To:
    public String getTAG009(){return System.label.COMM001_TAG068;} //Go!
    public String getTAG010(){return System.label.DXT001_TAG010;} //Email As Attachment
    public String getTAG011(){return System.label.DXT001_TAG014;} //Export To File
    public String getTAG012(){return System.label.DXT001_TAG001;} //Export for QuickBooks
    public String getTAG013(){return System.label.DXT001_TAG006 +' '+ strFilterDateFieldLabel;} //Filter records by applying this date range (optional) on the configured date field:
    public String getTAG014(){
        if(lstSObjectWrapper.size() > 0)
            return System.label.DXT001_TAG009;
        else
            return '';
    } //Choose records from list below and click one of the buttons to export
    public String getTAG015(){return System.label.DXT001_TAG005;} //Datatype of field used for filter should be Date or Datetime. Please contact your ServiceMax Administrator.
    public String getTAG016(){return System.label.DXT001_TAG011;}//QB_Export_
    public String getTAG017(){return System.label.DXT001_TAG017;}//Unable to display data. Default Configuration for export is not available. Please contact your ServiceMax Administrator.
    public String getTAG018(){return System.label.DXT001_TAG016;}//Unable to display data. More than one active configuration detected. Please contact your ServiceMax Administrator.
    public String getTAG019(){return System.label.COMM001_TAG064;}//Help
    public String getTAG020(){return System.label.COMM001_TAG024;}//First
    public String getTAG021(){return System.label.COMM001_TAG025;}//Next
    public String getTAG022(){return System.label.COMM001_TAG026;}//Prev
    public String getTAG023(){return System.label.COMM001_TAG027;}//Last
    public String getTAG024(){return System.label.DXT001_TAG018;}//of
    public String getHLPURL(){return System.label.DXT001_HLPURL;}//Help URL is needed !!!
}