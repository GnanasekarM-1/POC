/* Security Scanned */
public with sharing class IPRD_CaptureCounterValues {    
/****************************** Code Block Starts *************************************/
/****************************** Wrapper Class Starts *********************************/
    public class WrapCounter{
        public SVMXC__Counter_Details__c Counter = new SVMXC__Counter_Details__c();
        public Double Reading;
        
       public WrapCounter(SVMXC__Counter_Details__c C, Double R){ 
            Counter = C;
            if(R==null)
                Reading = 0.00;                 
            else
                Reading = R;
        }
        public SVMXC__Counter_Details__c getCounter(){
            return Counter;
        }
        public Double getReading(){
            return Reading;
        }
        public void setReading(Double R){ 
            this.Reading = R;
        }
    }
/****************************** Variable Declaration *******************************/
    // public COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD006');
    public List<SVMXC__ServiceMax_Processes__c> CounterRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> TempCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__Counter_Details__c> CounterRecList = new List<SVMXC__Counter_Details__c>();
    public List<SVMXC__Counter_Details__c> CounterDefinationList = new List<SVMXC__Counter_Details__c>();
    public List<SVMXC__Counter_Details__c> CounterReadingList = new List<SVMXC__Counter_Details__c>();
    public boolean DisbleSaveBttn = false;
    public string IBId;
    public List<WrapCounter> WrapCounterList = new List<WrapCounter>();
    public sObject Prod;
    public String IBFields;
    public Boolean ShowPanel=true;
    SVMXC__Installed_Product__c IBProd = new SVMXC__Installed_Product__c();
    public COMM_Utils ComUtil = new COMM_Utils(); 
    public COMM_Utils.COMM_ExpressionParsing ComUtilExp = new COMM_Utils.COMM_ExpressionParsing(); 
    public Map<String,list<SVMXC__ServiceMax_Config_Data__c>> ExpressionMap = new Map<String,list<SVMXC__ServiceMax_Config_Data__c>>();    
    public Map<Id,Boolean> ValidExpMap = new Map<Id,Boolean>(); 
    public Map<String, String> ValidMap = new Map<String, String>();
    Map<Id,SVMXC__ServiceMax_Processes__c> RuleMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
    map<Id, list<SVMXC__ServiceMax_Config_Data__c>> ConfigMap = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    Map<string,sObject> ValidProdMap;
    public List<sObject> ProdLst;
    List<Id> TempProcessIds = new List<Id>();
    Map<Id, List<SVMXC__Counter_Details__c>> mapCounterDefinitionCounterDetails = new Map<Id, List<SVMXC__Counter_Details__c>>();
    Map<Id, SVMXC__Counter_Details__c> mapCounterDefinition = new Map<Id, SVMXC__Counter_Details__c>();
                    
                    
/********************************* Translations ************************************/
    public String getTAG001() {return System.Label.IPRD006_TAG001;}
    public String getTAG002() {return System.Label.IPRD006_TAG002;}
    public String getTAG003() {return System.Label.IPRD006_TAG003;}
    public String getTAG004() {return System.Label.IPRD006_TAG004;}
    public String getTAG005() {return System.Label.IPRD006_TAG005;}
    public String getTAG006() {return System.Label.IPRD006_TAG006;}
    public String getTAG007() {return System.Label.IPRD006_TAG007;}
    public String getTAG008() {return System.Label.IPRD006_TAG008;}
    public String getTAG009() {return System.Label.IPRD006_TAG009;}
    public String getTAG010() {return System.Label.IPRD006_TAG010;}
    public String getTAG011() {return System.Label.IPRD006_TAG011;}
    public String getTAG012() {return System.Label.IPRD006_TAG012;}
    public String getTAG013() {return System.Label.IPRD006_TAG013;}
    public String getTAG014() {return System.Label.IPRD006_TAG014;}
    public String getTAG015() {return System.Label.IPRD006_TAG015;}
    public String getTAG016() {return System.Label.IPRD006_TAG016;}
    public String getHLPURL() {return System.Label.IPRD006_HLPURL;}
/****************************** Constructor Defined ************************************/
        
    public IPRD_CaptureCounterValues(){     
        IBId= system.currentPageReference().getParameters().get('PId');
        mainMethod(); 
    }
    
    public string getIBId(){return IBId;}
    public void setIBId(string s){ this.IBId = s; }
    
    public void mainMethod(){
        list<SVMXC__ServiceMax_Config_Data__c> TempConfigList = new list<SVMXC__ServiceMax_Config_Data__c>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType CountRecType = [select Id from RecordType where Name=:'Reading' and SobjectType=:'SVMXC__Counter_Details__c'];
        List<Id> Idlst = new List<Id>();
        string recTyp='Reading';        
        string SQLHdr;      
        ProdLst = new List<Product2>();
        Map<String,string> TypeMap = new Map<String,string>();      
        List<Id> ValidRuleIds = new List<Id>(); 
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        CounterRuleList=[select Id,Name,SVMXC__Sequence__c,SVMXC__Advance_Expression__c,SVMXC__Description__c,SVMXC__Name__c,SVMXC__Select__c from SVMXC__ServiceMax_Processes__c where RecordType.Name='SVMX Rule' and SVMXC__Rule_Type__c='Counters' order by SVMXC__Sequence__c];
        if(CounterRuleList.size()>0){
            for(SVMXC__ServiceMax_Processes__c c:CounterRuleList){
                Idlst.add(c.Id);
                RuleMap.put(c.Id,c);
                ConfigMap.put(c.Id,new list<SVMXC__ServiceMax_Config_Data__c>());
            }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            TempCnfiglst = [Select SVMXC__Sequence__c, SVMXC__Display_Type__c,SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst and SVMXC__Expression_Type__c='IPRD_Counters' and RecordType.Name='Expressions'];
            if(TempCnfiglst.size()>0){
                for(SVMXC__ServiceMax_Config_Data__c c:TempCnfiglst){
                    ConfigMap.get(c.SVMXC__Expression_Rule__c).add(c);
                }
            }
        }
        if(IBId==null || IBId==''){
            ShowPanel = false;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG004()));
            DisbleSaveBttn = true;
        }
        else{           
            IBProd = [select SVMXC__Product__c, SVMXC__Product__r.Id,SVMXC__Serial_Lot_Number__c,SVMXC__Product__r.Name from SVMXC__Installed_Product__c where Id=:IBId];
            string ProdId = IBProd.SVMXC__Product__r.Id;
            Map<String, Schema.SObjectField> IBfieldMap = Schema.SObjectType.Product2.fields.getMap();
            /***************duplicate Check******************************/
               COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
              IBfieldMap = objCommUtilV2.removeDuplicateFields(IBfieldMap);
         /************************************************************/
            for(Schema.SObjectField lON : IBfieldMap.values()){
                Schema.DescribeFieldResult D = lON.getDescribe();
                TypeMap.put(D.getName(),D.getType().name());                
            }
            IBFields = ComUtil.SVMX_getFieldNamesFromList(ComUtil.SVMX_getFieldList(IBfieldMap,true));
            SQLHdr = 'Select '+IBFields+' from Product2 where Id=:ProdId';
            ProdLst = database.query(SQLHdr);
            CounterRecList = database.Query('Select Id,SVMXC__Is_Latest__c, SVMXC__Last_Reading__c ,SVMXC__Counter_Name__c,SVMXC__Counter_Definition__c, SVMXC__Reading_Date__c ,SVMXC__Counter_Reading__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Rule__r.Name from SVMXC__Counter_Details__c where SVMXC__Installed_Product__c=:IBId and RecordType.Name=:recTyp');           
            if((CounterRecList.size()<=0 && CounterRuleList.size()<=0)||(CounterRecList==null && CounterRuleList==null)){
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG005()));
                DisbleSaveBttn = true;
            }
            else{
                if(ProdLst.size()>0){                   
                    ValidProdMap = new Map<string,Product2>();
                    for(integer i=0;i<ProdLst.size();i++){
                        ValidProdMap.put(ProdLst[i].Id,ProdLst[i]);
                    }
                    
                    ValidMap = ComUtilExp.SVMX_ExpressionParsing(ValidProdMap,ConfigMap,RuleMap); 
                    system.debug(ValidMap);
                    for(SVMXC__ServiceMax_Processes__c c:CounterRuleList){
                        system.debug(ValidMap.get(IBProd.SVMXC__Product__r.Id));
                        if(ValidMap.get(IBProd.SVMXC__Product__r.Id) == c.Id)
                            ValidRuleIds.add(c.Id);             
                    }
                    
                    List<SVMXC__Counter_Details__c> listLatestRecords = new List<SVMXC__Counter_Details__c>();
                    
                    //Check if there is any counter reading where isLatest = true. If yes, only add the ones which have latest value.
                    for(SVMXC__Counter_Details__c c : CounterRecList){
                        //TODO: Reducing the lines of code
                        List<SVMXC__Counter_Details__c> listConterReading = new List<SVMXC__Counter_Details__c>();
                        if(mapCounterDefinitionCounterDetails != null && mapCounterDefinitionCounterDetails.get(c.SVMXC__Counter_Definition__c) != null){
                            listConterReading = mapCounterDefinitionCounterDetails.get(c.SVMXC__Counter_Definition__c);
                        }
                        listConterReading.add(c);
                        mapCounterDefinitionCounterDetails.put(c.SVMXC__Counter_Definition__c, listConterReading);
                        
                        
                        if(mapCounterDefinition != null && mapCounterDefinition.get(c.SVMXC__Counter_Definition__c) != null){
                            SVMXC__Counter_Details__c counterDetRec =  mapCounterDefinition.get(c.SVMXC__Counter_Definition__c);
                            if(!counterDetRec.SVMXC__Is_Latest__c)
                                mapCounterDefinition.put(c.SVMXC__Counter_Definition__c, c);
                        }
                        else{
                            mapCounterDefinition.put(c.SVMXC__Counter_Definition__c, c);
                        }
                    }  
                    
                    
                    for(Id counterDef : mapCounterDefinition.keyset()){
                        system.debug(mapCounterDefinition.get(counterDef));
                        listLatestRecords.add(mapCounterDefinition.get(counterDef).clone(true, true));
                    }
                    
                    CounterDefinationList = [Select Id,SVMXC__Counter_Name__c,SVMXC__Counter_Definition__c,SVMXC__Counter_Reading__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c from SVMXC__Counter_Details__c where SVMXC__Counter_Rule__c IN:ValidRuleIds and SVMXC__Active__c=:true and RecordType.Name=:'Definition'];
                    Boolean IsExist = false;
                    for(SVMXC__Counter_Details__c d : CounterDefinationList){
                        if(ValidMap.get(IBProd.SVMXC__Product__r.Id) == d.SVMXC__Counter_Rule__c){
                            IsExist = false;
                            for(SVMXC__Counter_Details__c r : listLatestRecords){
                                if(d.Id == r.SVMXC__Counter_Definition__c){
                                    r.SVMXC__Counter_Name__c = d.SVMXC__Counter_Name__c;
                                    //system.debug(r.SVMXC__Counter_Reading__c);
                                    //r.SVMXC__Last_Reading__c = r.SVMXC__Counter_Reading__c;
                                    IsExist = true;
                                    CounterReadingList.add(r);
                                }
                            }
                            if(!IsExist){           
                                SVMXC__Counter_Details__c NewReading = new SVMXC__Counter_Details__c();
                                NewReading.RecordTypeId = CountRecType.Id;
                                NewReading.SVMXC__Counter_Name__c = d.SVMXC__Counter_Name__c;
                                NewReading.SVMXC__Counter_Type__c = d.SVMXC__Counter_Type__c;
                                NewReading.SVMXC__Counter_Definition__c = d.Id;
                                NewReading.SVMXC__Counter_Reading__c = 0;
                                NewReading.SVMXC__Reading_Date__c = DateTime.now();
                                NewReading.SVMXC__Min_Value__c = d.SVMXC__Min_Value__c;
                                NewReading.SVMXC__Max_Value__c = d.SVMXC__Max_Value__c;
                                NewReading.SVMXC__Is_Latest__c = true;
                                CounterReadingList.add(NewReading); 
                            }  
                        }      
                    }
                    for(integer j=0;j<CounterReadingList.size();j++){
                           // modified the line while doing API upgrade to add .longvalue() to convert numnber to double
                            // Added Check to avoid null pointer Exception
                       // WrapCounter w = new WrapCounter(CounterReadingList[j], CounterReadingList[j].SVMXC__Counter_Reading__c.longvalue());
                       WrapCounter w;
                       if(CounterReadingList[j].SVMXC__Counter_Reading__c!=null)
                        {
                           w = new WrapCounter(CounterReadingList[j], CounterReadingList[j].SVMXC__Counter_Reading__c.longvalue());
                        }
                        else {
                        w = new WrapCounter(CounterReadingList[j],null );
                        }
                        WrapCounterList.add(w);   
                    }
                }
            }
        }
    }
     
    public boolean getDisbleSaveBttn(){ return DisbleSaveBttn; }
    public void setDisbleSaveBttn(boolean b){ this.DisbleSaveBttn = b; }
    public boolean getShowPanel(){ return ShowPanel; }
    public void setShowPanel(boolean b){ this.ShowPanel = b; }
    public List<WrapCounter> getWrapCounterList(){
        return WrapCounterList;
    }
    public List<SVMXC__Counter_Details__c> getCounterRecList(){
        return CounterRecList;
    }
    public List<SVMXC__Counter_Details__c> getCounterReadingList(){
        return CounterReadingList;
    }
    public SVMXC__Installed_Product__c getIBProd(){
        return IBProd;
    }
    public PageReference SVMX_SaveCounters(){
        pageReference p;
        Boolean IsValid = true;
        integer UpsrtReading = 0;
        List<SVMXC__Counter_Details__c> SaveCountrList = new List<SVMXC__Counter_Details__c>();
        for(integer i=0;i<WrapCounterList.size();i++){          
            if(WrapCounterList[i].Counter.SVMXC__Counter_Reading__c==null){
                IsValid = false;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG009()));
            }
            if(WrapCounterList[i].Counter.SVMXC__Counter_Reading__c < WrapCounterList[i].Counter.SVMXC__Min_Value__c || WrapCounterList[i].Counter.SVMXC__Counter_Reading__c > WrapCounterList[i].Counter.SVMXC__Max_Value__c) {
                IsValid = false;                
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR,getTAG010()+'('+WrapCounterList[i].Counter.SVMXC__Min_Value__c +')'+ getTAG011()+'('+WrapCounterList[i].Counter.SVMXC__Max_Value__c+')'+getTAG012()+'<'+WrapCounterList[i].Counter.SVMXC__Counter_Name__c+'>'));  
            }
            // As per PBXray requirement, we always need to create new record for reading where isLatest = true; 
            // Make isLatest = false, for all the existing records
            if(IsValid){
                SVMXC__Counter_Details__c createNewCounterReading = WrapCounterList[i].Counter.clone(false, true);
                createNewCounterReading.SVMXC__Installed_Product__c = IBId;
                createNewCounterReading.SVMXC__Product__c = ProdLst[0].id;
                createNewCounterReading.SVMXC__Reading_Date__c = DateTime.now();
                createNewCounterReading.SVMXC__Is_Latest__c = true; 
                List<SVMXC__Counter_Details__c> listCounterDetailsForCounterDefinition = mapCounterDefinitionCounterDetails.get(createNewCounterReading.SVMXC__Counter_Definition__c);
                if(listCounterDetailsForCounterDefinition != null && listCounterDetailsForCounterDefinition.size() > 0){
                    createNewCounterReading.SVMXC__Last_Reading__c = WrapCounterList[i].Reading; 
                    createNewCounterReading.SVMXC__Last_Reading_Date__c = WrapCounterList[i].Counter.SVMXC__Reading_Date__c; 
                }
                SaveCountrList.add(createNewCounterReading);
                
                if(CounterRecList != null && CounterRecList.size() > 0){
                    WrapCounterList[i].Counter.SVMXC__Is_Latest__c = false;
                    WrapCounterList[i].Counter.SVMXC__Counter_Reading__c = WrapCounterList[i].Reading;
                    if(mapCounterDefinition != null && mapCounterDefinition.get(WrapCounterList[i].Counter.SVMXC__Counter_Definition__c) != null )
                        WrapCounterList[i].Counter.SVMXC__Counter_Name__c = mapCounterDefinition.get(WrapCounterList[i].Counter.SVMXC__Counter_Definition__c).SVMXC__Counter_Name__c;
                    SaveCountrList.add(WrapCounterList[i].Counter);
                }
                
                /*WrapCounterList[i].Counter.SVMXC__Installed_Product__c = IBId;
                WrapCounterList[i].Counter.SVMXC__Product__c = ProdLst[0].id; 
                WrapCounterList[i].Counter.SVMXC__Is_Latest__c = false;*/
                //WrapCounterList[i].Counter.SVMXC__Counter_Name__c=''; 
                // 
                UpsrtReading = UpsrtReading+1;            
            }
        }       
        if(UpsrtReading==WrapCounterList.size()){
            system.debug(UpsrtReading);
            //upsert SaveCountrList;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveCountrList, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert SaveCountrList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            String url;
            if(IBProd.Id!=null)
                url = '/'+IBProd.Id;
            else
                url = '/home/home.jsp';
            p=new pageReference(url);
            p.setRedirect(true);            
        }
        else{           
            p=null;
        }
        return p;   
    }
    public PageReference SVMX_Cancel(){
        String url;
        if(IBProd.Id!=null)
            url = '/'+IBProd.Id;
        else
            url = '/home/home.jsp';
        pageReference p=new pageReference(url);     
        p.setRedirect(true);
    return p;
    }
}