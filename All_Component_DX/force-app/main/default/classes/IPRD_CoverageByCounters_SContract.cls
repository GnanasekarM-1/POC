/* Security Scanned */
public with sharing class IPRD_CoverageByCounters_SContract {
    
    /****************************** Code Block Starts *************************************/
    
    /****************************** Wrapper Class Starts *********************************/
        public class WrapCovrgCounter{
            public SVMXC__Counter_Details__c Counter = new SVMXC__Counter_Details__c();
            public string ProdName; 
            public string RuleName;            
            public SVMXC__Service_Contract_Products__c appProd = new SVMXC__Service_Contract_Products__c();
            public WrapCovrgCounter(SVMXC__Counter_Details__c C,SVMXC__Service_Contract_Products__c p,String prdctName){
                Counter = C;
                ProdName = prdctName;                       
                appProd = p;
            }
            public SVMXC__Service_Contract_Products__c getappProd(){
                return appProd;
            }
            
            public SVMXC__Counter_Details__c getCounter(){
                return Counter;
            }
            public string getProdName(){
                return ProdName;
            } 
            public void setProdName(string R){
                this.ProdName = R;
            }
            public string getRuleName(){
                return RuleName;
            } 
            public void setRuleName(string R){
                this.RuleName = R;
            }                   
        }
    /****************************** Wrapper Class Ends **********************************/
        
    /****************************** Variable Declaration *******************************/
    //public COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD008');  
    
    public List<SVMXC__ServiceMax_Processes__c> CounterRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> TempCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__Counter_Details__c> CounterRecList = new List<SVMXC__Counter_Details__c>();
    public List<SVMXC__Counter_Details__c> CounterDefinationList = new List<SVMXC__Counter_Details__c>();
    public List<SVMXC__Counter_Details__c> CounterCvrgList = new List<SVMXC__Counter_Details__c>();
    public List<SVMXC__Service_Contract_Products__c> AplcbleProdLst = new List<SVMXC__Service_Contract_Products__c>();
    public boolean DisbleSaveBttn = false;
    public string TId;
    public List<WrapCovrgCounter> WrapCounterList = new List<WrapCovrgCounter>();
    public List<sObject> ProdLst;
    public String IBFields;
    public SVMXC__Service_Contract__c SrvcContract = new SVMXC__Service_Contract__c();
    public SVMXC__Installed_Product__c IBProd = new SVMXC__Installed_Product__c();
    public COMM_Utils ComUtil = new COMM_Utils();
    public COMM_Utils.COMM_ExpressionParsing ComUtilExp = new COMM_Utils.COMM_ExpressionParsing();
    public Map<String,list<SVMXC__ServiceMax_Config_Data__c>> ExpressionMap = new Map<String,list<SVMXC__ServiceMax_Config_Data__c>>();    
    public Map<Id,Boolean> ValidExpMap = new Map<Id,Boolean>();
    public Map<String, String> ValidMap = new Map<String, String>();
    List<Id> TempProcessIds = new List<Id>();
    public Boolean ShowPanel=true;
    /********************************* Translations ************************************/
        
    public String getTAG001() {return System.Label.IPRD008_TAG001;}
    public String getTAG002() {return System.Label.IPRD008_TAG002;}
    public String getTAG003() {return System.Label.IPRD008_TAG003;}
    public String getTAG004() {return System.Label.IPRD008_TAG004;}
    public String getTAG005() {return System.Label.IPRD008_TAG005;}
    public String getTAG006() {return System.Label.IPRD008_TAG006;}
    public String getTAG007() {return System.Label.IPRD008_TAG007;}
    public String getTAG008() {return System.Label.IPRD008_TAG008;}
    public String getTAG009() {return System.Label.IPRD008_TAG009;}
    public String getTAG010() {return System.Label.IPRD008_TAG010;}
    public String getTAG011() {return System.Label.IPRD008_TAG011;}
    public String getTAG012() {return System.Label.IPRD008_TAG012;}
    public String getTAG013() {return System.Label.IPRD008_TAG013;}
    public String getTAG014() {return System.Label.IPRD008_TAG014;}
    public String getTAG015() {return System.Label.IPRD008_TAG015;}
    public String getTAG016() {return System.Label.IPRD008_TAG016;}
    public String getTAG017() {return System.Label.IPRD008_TAG017;}
    public String getTAG018() {return System.Label.IPRD008_TAG018;}
    public String getTAG019() {return System.Label.IPRD008_TAG019;}
    public String getTAG020() {return System.Label.IPRD008_TAG020;}
    public String getTAG021() {return System.Label.IPRD008_TAG021;}
        public String getHLPURL() {return System.Label.IPRD008_HLPURL;}
        
    /****************************** Constructor Defined ************************************/
    
    public IPRD_CoverageByCounters_SContract(){       
        TId= system.currentPageReference().getParameters().get('PId');
        list<SVMXC__ServiceMax_Config_Data__c> TempConfigList = new list<SVMXC__ServiceMax_Config_Data__c>();
        List<Id> Idlst = new List<Id>();
        List<Id> ProdIdlst = new List<Id>();
        List<Id> AppPrdIdlst = new List<Id>();
        List<Id> ValidRuleIds = new List<Id>();
        
        string recTyp='Coverage';
        string SQLHdr;
        ProdLst = new List<Product2>();
        Map<String,string> TypeMap = new Map<String,string>();
        Map<Id,SVMXC__ServiceMax_Processes__c> RuleMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> ConfigMap = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        Map<string,sObject> ValidProdMap;
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType CountRecType = [select Id from RecordType where Name=:'Coverage' and SobjectType=:'SVMXC__Counter_Details__c'];
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        CounterRuleList=[select Id,Name,SVMXC__Advance_Expression__c,SVMXC__Sequence__c,SVMXC__Description__c,SVMXC__Name__c,SVMXC__Select__c from SVMXC__ServiceMax_Processes__c where RecordType.Name='SVMX Rule' and SVMXC__Rule_Type__c='Counters'  order by SVMXC__Sequence__c];
        system.debug('ZcounterRulelistZ'+CounterRuleList);
        SrvcContract = [select Id,Name from SVMXC__Service_Contract__c where Id=:TId];                  
        if(TId!=null){          
            if(CounterRuleList.size()>0){
                for(SVMXC__ServiceMax_Processes__c c:CounterRuleList){
                    Idlst.add(c.Id);
                    RuleMap.put(c.Id,c);
                    ConfigMap.put(c.Id,new list<SVMXC__ServiceMax_Config_Data__c>());
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                TempCnfiglst = [Select SVMXC__Sequence__c, SVMXC__Operator__c,SVMXC__Display_Type__c ,SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst and SVMXC__Expression_Type__c='IPRD_Counters' and RecordType.Name='Expressions'];
                if(TempCnfiglst.size()>0){
                    for(SVMXC__ServiceMax_Config_Data__c c:TempCnfiglst){
                        ConfigMap.get(c.SVMXC__Expression_Rule__c).add(c);
                    }
                }
            }           
            
            AplcbleProdLst = [Select SVMXC__Installed_Product__c,SVMXC__Installed_Product__r.Name,SVMXC__Installed_Product__r.SVMXC__Product__c,SVMXC__Product__c,SVMXC__Product__r.Id,SVMXC__Product__r.Name ,Name, Id From SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c=:TId];            
            
            if(AplcbleProdLst.size()>0){
                for(SVMXC__Service_Contract_Products__c p :AplcbleProdLst){
                    ProdIdlst.add(p.SVMXC__Installed_Product__r.SVMXC__Product__c);
                    AppPrdIdlst.add(p.Id);  
                }               
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
                SQLHdr = 'Select '+IBFields+' from Product2 where Id IN:ProdIdlst';
                ProdLst = database.query(SQLHdr);           
                CounterRecList = database.Query('Select Id,SVMXC__Installed_Product__c,SVMXC__Service_Maintenance_Contract__c,SVMXC__Covered_Products__c,SVMXC__Product__c,SVMXC__Counter_Name__c,SVMXC__Coverage_Limit__c,SVMXC__Coverage_Starts_At__c,SVMXC__Counters_Covered__c,SVMXC__Counter_Definition__c,SVMXC__Counter_Reading__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Rule__r.SVMXC__Name__c from SVMXC__Counter_Details__c where SVMXC__Covered_Products__c IN:AppPrdIdlst and RecordType.Name=:recTyp');            
                system.debug('CounterRecList' + CounterRecList.size());
            }
            else {
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, getTAG014()));
                DisbleSaveBttn = true;  
            }
            if((CounterRecList.size()<=0 && CounterRuleList.size()<=0)||(CounterRecList==null && CounterRuleList==null)){
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG015()));
                    DisbleSaveBttn = true;
            }
            else {
                if(ProdLst.size()>0){                   
                    ValidProdMap = new Map<string,Product2>();
                        for(integer i=0;i<ProdLst.size();i++){
                            ValidProdMap.put(ProdLst[i].Id,ProdLst[i]);
                    }
                    ValidMap = ComUtilExp.SVMX_ExpressionParsing(ValidProdMap,ConfigMap,RuleMap);                   
                    system.debug('ValidMap '+ ValidMap);
                    for(SVMXC__ServiceMax_Processes__c c:CounterRuleList){
                        for(SVMXC__Service_Contract_Products__c prod : AplcbleProdLst){
                            if(ValidMap.get(prod.SVMXC__Installed_Product__r.SVMXC__Product__c) == c.Id)
                                ValidRuleIds.add(c.Id);
                        }
                    }
                    /*for(SVMXC__Counter_Details__c c : CounterRecList){          
                        CounterCvrgList.add(c);                     
                    }*/
                    system.debug('CounterCvrgList' + CounterCvrgList.size());
                    CounterDefinationList = [Select Id,SVMXC__Installed_Product__c,SVMXC__Product__c,SVMXC__Counter_Name__c,SVMXC__Coverage_Limit__c,SVMXC__Counter_Rule__r.SVMXC__Name__c,SVMXC__Counter_Definition__c,SVMXC__Counter_Reading__c,SVMXC__Counter_Rule__c,SVMXC__Counter_Type__c,SVMXC__Grows_Reduces_By__c,SVMXC__Min_Value__c,SVMXC__Max_Value__c,SVMXC__Active__c,SVMXC__Select__c,SVMXC__Coverage_Starts_At__c,SVMXC__Counters_Covered__c,SVMXC__Service_Maintenance_Contract__c,SVMXC__Covered_Products__c from SVMXC__Counter_Details__c where SVMXC__Counter_Rule__c IN:ValidRuleIds and SVMXC__Active__c=:true and RecordType.Name=:'Definition'];           
                    Boolean IsExist = false;
                    map<Id,string> RuleNameMap = new map<Id,string>();
                    for(SVMXC__Service_Contract_Products__c prod : AplcbleProdLst){
                            if(ValidMap.containsKey(prod.SVMXC__Installed_Product__r.SVMXC__Product__c)){
                                    for(SVMXC__Counter_Details__c d: CounterDefinationList){
                                        if(ValidMap.get(prod.SVMXC__Installed_Product__r.SVMXC__Product__c) == d.SVMXC__Counter_Rule__c)
                                        {       
                                                IsExist = false;
                                                for(SVMXC__Counter_Details__c r : CounterRecList){
                                                    if(d.Id== r.SVMXC__Counter_Definition__c && prod.Id==r.SVMXC__Covered_Products__c){
                                                        RuleNameMap.put(r.SVMXC__Counter_Rule__c,r.SVMXC__Counter_Rule__r.SVMXC__Name__c);
                                                        r.SVMXC__Counter_Name__c = d.SVMXC__Counter_Name__c;
                                                        IsExist = true;
                                                        CounterCvrgList.add(r);      
                                                    }                                   
                                                }                              
                                                if(!IsExist){           
                                                    SVMXC__Counter_Details__c NewCovrg = new SVMXC__Counter_Details__c();
                                                    NewCovrg.RecordTypeId = CountRecType.Id;
                                                    NewCovrg.SVMXC__Counter_Name__c = d.SVMXC__Counter_Name__c;
                                                    NewCovrg.SVMXC__Covered_Products__c = prod.Id;
                                                    NewCovrg.SVMXC__Counter_Definition__c = d.Id;
                                                    NewCovrg.SVMXC__Coverage_Starts_At__c = 0;
                                                    NewCovrg.SVMXC__Counters_Covered__c = 0;                      
                                                    NewCovrg.SVMXC__Min_Value__c = d.SVMXC__Min_Value__c;
                                                    NewCovrg.SVMXC__Max_Value__c = d.SVMXC__Max_Value__c;
                                                    NewCovrg.SVMXC__Counter_Type__c =d.SVMXC__Counter_Type__c;
                                                    NewCovrg.SVMXC__Counter_Rule__c = d.SVMXC__Counter_Rule__c;                         
                                                    RuleNameMap.put(d.SVMXC__Counter_Rule__c,d.SVMXC__Counter_Rule__r.SVMXC__Name__c);
                                                    CounterCvrgList.add(NewCovrg);                            
                                                }
                                            }
                                    }
                            }
                    }
                    for(SVMXC__Service_Contract_Products__c prod : AplcbleProdLst){
                        for(SVMXC__Counter_Details__c r : CounterCvrgList){
                            //if(ValidMap.get(prod.SVMXC__Installed_Product__r.SVMXC__Product__c)==r.SVMXC__Counter_Rule__c){
                            if(prod.Id==r.SVMXC__Covered_Products__c){  
                                WrapCovrgCounter w = new WrapCovrgCounter(r,prod,prod.SVMXC__Installed_Product__r.Name);
                                w.RuleName = RuleNameMap.get(r.SVMXC__Counter_Rule__c);
                                WrapCounterList.add(w); 
                            }
                        }
                    }
                }                       
            }                               
        }       
    }
    
    public boolean getDisbleSaveBttn(){ return DisbleSaveBttn; }
    public void setDisbleSaveBttn(boolean b){ this.DisbleSaveBttn = b; }
    public boolean getShowPanel(){ return ShowPanel; }
    public void setShowPanel(boolean b){ this.ShowPanel = b; }
    
    public List<WrapCovrgCounter> getWrapCounterList(){
        return WrapCounterList;
    }
    
    public List<SVMXC__Counter_Details__c> getCounterRecList(){
        return CounterRecList;
    }
    public List<SVMXC__Counter_Details__c> getCounterCvrgList(){
        return CounterCvrgList;
    }
        
        
    public SVMXC__Service_Contract__c getSrvcContract(){
        return SrvcContract;
    }
    
    public PageReference SVMX_SaveCounters(){
        pageReference p;
        Boolean IsValid = true;
        integer UpsrtReading = 0;
        List<SVMXC__Counter_Details__c> SaveCountrList = new List<SVMXC__Counter_Details__c>();
        for(integer i=0;i<WrapCounterList.size();i++){
            if(WrapCounterList[i].Counter.SVMXC__Coverage_Starts_At__c ==null || WrapCounterList[i].Counter.SVMXC__Counters_Covered__c==null){
                IsValid = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG018()));
            }
            else {        
                if(WrapCounterList[i].Counter.SVMXC__Coverage_Starts_At__c < WrapCounterList[i].Counter.SVMXC__Min_Value__c || WrapCounterList[i].Counter.SVMXC__Coverage_Starts_At__c > WrapCounterList[i].Counter.SVMXC__Max_Value__c) {
                    IsValid = false;                
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG019()));  
                }
               double d = WrapCounterList[i].Counter.SVMXC__Coverage_Starts_At__c + WrapCounterList[i].Counter.SVMXC__Counters_Covered__c;
                if(WrapCounterList[i].Counter.SVMXC__Counter_Type__c=='Increasing'){
                    if(d!=null && d > WrapCounterList[i].Counter.SVMXC__Max_Value__c){
                        IsValid = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));  
                    }
                }
                else if(WrapCounterList[i].Counter.SVMXC__Counter_Type__c=='Decreasing'){
                    if(d!=null  && d< WrapCounterList[i].Counter.SVMXC__Min_Value__c){
                        IsValid = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));  
                    }
                }
                
                if(IsValid){                
                    WrapCounterList[i].Counter.SVMXC__Covered_Products__c = WrapCounterList[i].appProd.Id;
                    WrapCounterList[i].Counter.SVMXC__Installed_Product__c = WrapCounterList[i].appProd.SVMXC__Installed_Product__c;
                    WrapCounterList[i].Counter.SVMXC__Product__c = WrapCounterList[i].appProd.SVMXC__Installed_Product__r.SVMXC__Product__c;
                    WrapCounterList[i].Counter.SVMXC__Service_Maintenance_Contract__c = TId; 
                    WrapCounterList[i].Counter.SVMXC__Counter_Name__c='';               
                    if(WrapCounterList[i].Counter.SVMXC__Counter_Type__c=='Increasing'){
                        WrapCounterList[i].Counter.SVMXC__Coverage_Limit__c = WrapCounterList[i].Counter.SVMXC__Coverage_Starts_At__c + WrapCounterList[i].Counter.SVMXC__Counters_Covered__c;  
                    }
                    if(WrapCounterList[i].Counter.SVMXC__Counter_Type__c=='Decreasing'){
                        WrapCounterList[i].Counter.SVMXC__Coverage_Limit__c = WrapCounterList[i].Counter.SVMXC__Coverage_Starts_At__c - WrapCounterList[i].Counter.SVMXC__Counters_Covered__c;  
                    }
                    SaveCountrList.add(WrapCounterList[i].Counter);                
                    UpsrtReading = UpsrtReading+1;            
                }                        
            }
        }
        if(UpsrtReading==WrapCounterList.size()){           
            //upsert SaveCountrList;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SaveCountrList, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert SaveCountrList;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
          //  String url = '/'+TId;
           String url = '/'+SrvcContract.Id;
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
        if(TId!=null)
            //url = '/'+TId;
            url = '/'+SrvcContract.Id;
        else
            url = '/home/home.jsp';
        pageReference p=new pageReference(url);     
        p.setRedirect(true);
        return p;
    }
}