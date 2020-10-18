/* Security Scanned */
public  with Sharing class WORD_CreateQuote 
{
    // ------------------------NPS Related changes  ---------
    public string getUserLocaleKey()
    {
        return UserInfo.getLanguage();
    }
    public string getUserID()
    {
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID()
    {
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    
    // -------------------------------
    //======================================================= URL Peremeters ===============================================
    
    public String WOId = System.currentPageReference().getParameters().get('cid'); 
    public String QOId = System.currentPageReference().getParameters().get('id'); 
    
    //======================================================= ServiceMax Tags & Settings ================================================
    
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD002');
    
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD002');
    
    public String WO2QuoteMap = AllSubModuleSettings.get('SET001');                       //Setting for Mapping of Work Order to Quote
    public String QuoteSaveStatus = AllSubModuleSettings.get('SET002');                      //Allow Quote Save Without Lines
    public String EstLineToQuoteLineMap = AllSubModuleSettings.get('SET003');           //Setting for Mapping Work Order Lins to Quote Lines 
    
    
    //======================================================= Globle Variable Declaration ================================================
    public SVMXC__Quote__c QuoteHeader = new SVMXC__Quote__c();
    public String EstLineSobjectType = 'SVMXC__Service_Order_Line__c';
    public String Est = 'Estimate';
    public Id EstRecType = getEstRecordTypes().Id;
    public Boolean CheckAllLines = false;
    public String whrClouse ='  SVMXC__Service_Order__r.Id=\''+WOId+'\'';
    public List<SVMXC__Quote_Line__c> QuoteLines = new List<SVMXC__Quote_Line__c>();
    public List<SVMXC__Quote_Line__c> QuoteLinesToDlt = new List<SVMXC__Quote_Line__c>();
    public SVMXC__Service_Order__c WOHeader = new SVMXC__Service_Order__c(); 
    public List<SVMXC__Service_Order_Line__c> EstLineDetailArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> (); 
    
    public Integer QlineSize = 0;
    Decimal QuoteAmount = 0;
    Decimal QuoteLinePrice = 0;
    String DefaultStatus='';
    String DefaultLineType='';
    String DefaultLineDiscountType='';
    String DefaultHdrDiscountType='';
    public Boolean IsWarn=false; 
    Boolean IsSettingWarn=false;
    public Boolean getIsWarn(){ if(QuoteSaveStatus.toUpperCase()=='WARN' && IsWarn==true)return true;else return false; }  
    //***************************************** Delcaration for getting the map form target obj****************************************//
    public List<Sobject> listso;
    public Sobject so;
    public Boolean bo;
    public String str;
    
    SVMXC.COMM_Utils_TargetObjectTest targetutil = new SVMXC.COMM_Utils_TargetObjectTest(); // Creating the instance of the TargetObject utility
    SVMXC.COMM_Utils_TargetObjectTest.TargetObjectResultTest ResultObject = new SVMXC.COMM_Utils_TargetObjectTest.TargetObjectResultTest(so,bo,str);//Creating the instance of the TargetObject utility's inner class
    SVMXC.COMM_Utils_TargetObjectTest.TargetObjectResultTest ListResultObject = new SVMXC.COMM_Utils_TargetObjectTest.TargetObjectResultTest(listso,bo,str);//Creating the instance of the TargetObject utility's inner class
    //********************************************************************************************************************************///
    
    // Constructor
    
    public WORD_CreateQuote() 
    {
        if(WOId!=NULL || QOId!=NULL){
            DefaultStatus = utils.SVMX_getDefaultPicklistValue('SVMXC__Quote__c', 'SVMXC__Status__c');
            DefaultLineType = utils.SVMX_getDefaultPicklistValue('SVMXC__Quote_Line__c', 'SVMXC__Line_Type__c');
            DefaultLineDiscountType = utils.SVMX_getDefaultPicklistValue('SVMXC__Quote_Line__c', 'SVMXC__Discount_Type__c');
            DefaultHdrDiscountType = utils.SVMX_getDefaultPicklistValue('SVMXC__Quote__c', 'SVMXC__Discount_Type__c');
            system.debug('HeaderDiscountType'+DefaultHdrDiscountType);
            if(DefaultLineDiscountType==null)
                DefaultLineDiscountType = 'Amount';
            if(DefaultHdrDiscountType==null)
                DefaultHdrDiscountType = 'Amount';
            /*

List<String> lstPickListFldsQuote = new List<String>();
lstPickListFldsQuote.add('SVMXC__Status__c');
lstPickListFldsQuote.add('SVMXC__Discount_Type__c');
Map<String,String> defPickListValQuote = utils.SVMX_getDefaultPicklistValue('SVMXC__Quote__c', lstPickListFldsQuote);
if(defPickListValQuote.containsKey('SVMXC__Status__c') ==  true)
DefaultStatus =   defPickListValQuote.get('SVMXC__Status__c'); //  utils.SVMX_getDefaultPicklistValue('SVMXC__Quote__c', 'SVMXC__Status__c');
if(defPickListValQuote.containsKey('SVMXC__Discount_Type__c') ==  true)
DefaultHdrDiscountType =   defPickListValQuote.get('SVMXC__Discount_Type__c'); //  utils.SVMX_getDefaultPicklistValue('SVMXC__Quote__c', 'SVMXC__Status__c');

List<String> lstPickListFldsQuoteLine = new List<String>();
lstPickListFldsQuoteLine.add('SVMXC__Quote_Line__c');
lstPickListFldsQuoteLine.add('SVMXC__Discount_Type__c');
Map<String,String> defPickListValQuoteLine = utils.SVMX_getDefaultPicklistValue('SVMXC__Quote_Line__c', lstPickListFldsQuoteLine);
if(defPickListValQuoteLine.containsKey('SVMXC__Quote_Line__c') ==  true)
DefaultLineType =   defPickListValQuoteLine.get('SVMXC__Quote_Line__c'); //  utils.SVMX_getDefaultPicklistValue('SVMXC__Quote_Line__c', 'SVMXC__Quote_Line__c');
if(defPickListValQuoteLine.containsKey('SVMXC__Discount_Type__c') ==  true)
DefaultLineDiscountType =   defPickListValQuoteLine.get('SVMXC__Discount_Type__c'); //  utils.SVMX_getDefaultPicklistValue('SVMXC__Quote_Line__c', 'SVMXC__Discount_Type__c');

*/
            if(WOId != null){
                whrClouse +=' '+'and'+' ';
                whrClouse += 'RecordType.id=\''+EstRecType+'\'';
                ResultObject = targetutil.getTargerRecord(WO2QuoteMap,WOId); 
                Sobject resultobj = ResultObject.resultObj;
                QuoteHeader = (SVMXC__Quote__c)resultobj;  
                QuoteHeader.SVMXC__Status__c = DefaultStatus; 
                QuoteHeader.SVMXC__Discount_Type__c = DefaultHdrDiscountType;
                ListResultObject = targetutil.getTargerRecordlist(EstLineToQuoteLineMap,whrClouse,QuoteLines); 
                List<Sobject> listrecord = ListResultObject.listresultObj;
                QuoteLines = (List<SVMXC__Quote_Line__c>)listrecord;  
                //Setting the Default vaule if type is none
                for(SVMXC__Quote_Line__c Q:QuoteLines){
                    if(Q.SVMXC__Discount_Type__c==null)
                        Q.SVMXC__Discount_Type__c = 'Amount';
                }
                OnChangeItems();   
                OnChangeHeader();
            }
            if(QOId != null)
            {
                try
                {
                    
                    String fieldNames;
                    String SOQLDetail;
                    
                    Schema.DescribeSObjectResult dsoResult = SVMXC__Quote__c.sObjectType.getDescribe();
                    Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Quote__c.fields.getMap();
                    
                    //build a list of all fieldnames for the object
                    List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
                    fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);     
                    SOQLDetail = '  SELECT '+fieldNames+' FROM SVMXC__Quote__c where Id=\''+QOId+'\'';
                    QuoteHeader = Database.query(SOQLDetail);
                    QuoteHeader.SVMXC__Discount_Type__c = DefaultHdrDiscountType;
                    
                    String fieldNamesforlines;
                    String SOQLDetailforlines;
                    
                    Schema.DescribeSObjectResult dsoResultforlines = SVMXC__Quote_Line__c.sObjectType.getDescribe();
                    Map<String, SObjectField> fieldMapforlines = Schema.SObjectType.SVMXC__Quote_Line__c.fields.getMap();
                    
                    //build a list of all fieldnames for the object
                    List<String> fieldListforlines = utils.SVMX_getFieldList(fieldMapforlines,true);      
                    fieldNamesforlines = utils.SVMX_getFieldNamesFromList(fieldListforlines);      
                    SOQLDetailforlines = '  SELECT '+fieldNamesforlines+' FROM SVMXC__Quote_Line__c where SVMXC__Quote__c=\''+QOId+'\'';
                    QuoteLines = Database.query(SOQLDetailforlines);
                    //Setting the Default vaule if type is none
                    for(SVMXC__Quote_Line__c Q:QuoteLines){
                        if(Q.SVMXC__Discount_Type__c==null)
                            Q.SVMXC__Discount_Type__c = 'Amount';
                    }
                }
                catch(Exception e){}  
            }
            if(QuoteLines.size()==0)IsWarn=true;
            OnChangeLineItems();
        }
        else{
            Quote_DisplayBlockLevelMessage2=true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG047()));
        }
    }
    
    //=============================== Retriving Estimate Record Type Id ===================================//
    public RecordType getEstRecordTypes()
    {
        RecordType erTypes;
        try
        {
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+EstLineSobjectType+'\' and Name=\''+Est+'\' ';
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA           
            erTypes = Database.query(SOQL);
        } 
        catch (Exception e){}
        return erTypes;
    }
    
    
    //Getter Setter For Tags...
    public String getTAG001(){ return system.label.WORD002_TAG001;} //Service Quote
    public String getTAG002(){ return system.label.WORD002_TAG002;}//Service Quote Help'
    public String getTAG003(){ return system.label.WORD002_TAG003;}//'Save '
    public String getTAG004(){ return system.label.WORD002_TAG004;}//'Cancel'
    public String getTAG005(){ return system.label.WORD002_TAG005;}//'Service Quote Lines'
    public String getTAG006(){ return system.label.WORD002_TAG006;}//'AddLines'
    public String getTAG007(){ return system.label.WORD002_TAG007;}//'DeleteLines'
    public String getTAG008(){ return system.label.WORD002_TAG008;}//'Save Quote Lines'
    public String getTAG009(){ return system.label.WORD002_TAG009;}//'No Record Selected to Delete'
    //(Tag removed from Translations)public String getTAG010(){ return system.label.WORD002_TAG010')?svmxTagList.get('TAG010') : ''; }//'You can not save QuoteLines without saving QuoteHeader' 
    public String getTAG011(){ return system.label.WORD002_TAG011;}//'You must select a Work Order';
    public String getTAG012(){ return system.label.WORD002_TAG012;}//'You must select a Account';
    public String getTAG013(){ return system.label.WORD002_TAG013; }//'You must select a Contact'
    public String getTAG014(){ return system.label.WORD002_TAG014; }//'You must select a Status'
    public String getTAG015(){ return system.label.WORD002_TAG015; }//'Invalid Data'
    public String getTAG016(){ return system.label.WORD002_TAG016; }//'Quote Amount must not be zero or Less then zore'
    public String getTAG017(){ return system.label.WORD002_TAG017; }//'Discount should not be more than 100%'
    public String getTAG018(){ return system.label.WORD002_TAG018; }//'Date should not be less than today's date'
    public String getTAG019(){ return system.label.WORD002_TAG019; }//'You must select a Date'
    public String getTAG020(){ return system.label.WORD002_TAG020; }//'There are no quote lines. Do you wish to proceed?'
    public String getTAG021(){ return system.label.WORD002_TAG021; }//'Your configuration settings do not allow saving a Quote without Quote Lines'
    public String getTAG022(){ return system.label.WORD002_TAG022; }//'You must select a Product'
    public String getTAG023(){ return system.label.WORD002_TAG023; }//'You must enter a Quantity'
    public String getTAG024(){ return system.label.WORD002_TAG024; }//'You must enter a Unit Price'
    public String getTAG025(){ return system.label.WORD002_TAG025; }// 'Loading...'
    public String getTAG026(){ return system.label.WORD002_TAG026;}// 'Records Deleted Sucessfully'
    public String getTAG027(){ return system.label.WORD002_TAG027;}// 'Line Price must be greater then Discount'
    public String getTAG028(){ return system.label.WORD002_TAG028;}// 'Total Line Price must be greater then Discount'
    public String getTAG029(){ return system.label.WORD002_TAG029;}// 'Discount Value must not be negative'
    public String getTAG030(){ return system.label.WORD002_TAG030;}// 'Quantity  must not be negative'
    public String getTAG031(){ return system.label.WORD002_TAG031;}// 'Unit Price  must not be negative'
    public String getTAG032(){ return system.label.WORD002_TAG032;}// 'You Canot set Discount Value  Descount Type is --None--'
    public String getTAG033(){ return system.label.WORD002_TAG033;}// 'Quote Amount'
    public String getTAG034(){ return system.label.WORD002_TAG034;}// 'Valid Until'
    public String getTAG035(){ return system.label.WORD002_TAG035;}// 'Status'
    public String getTAG036(){ return system.label.WORD002_TAG036;}// 'Work Order'
    public String getTAG037(){ return system.label.WORD002_TAG037;}// 'Account'
    public String getTAG038(){ return system.label.WORD002_TAG038;}// 'Total Line Price'
    public String getTAG039(){ return system.label.WORD002_TAG039;}// 'Discount Type'
    public String getTAG040(){ return system.label.WORD002_TAG040;}// 'Discount'
    public String getTAG041(){ return system.label.WORD002_TAG041;}// 'Line Type'
    public String getTAG042(){ return system.label.WORD002_TAG042;}// 'Product'
    public String getTAG043(){ return system.label.WORD002_TAG043;}// 'Line Description'
    public String getTAG044(){ return system.label.WORD002_TAG044;}// 'Oty'
    public String getTAG045(){ return system.label.WORD002_TAG045;}// 'Unit Price'
    public String getTAG046(){ return system.label.WORD002_TAG046;}// 'Line Price'
    public String getTAG047(){ return system.label.WORD002_TAG047;}// 'Unable to proceed. Required number of parameters not available in the URL.'
    
    
    public String getHLPURL(){ return system.label.WORD002_HLPURL;}
    
    public Boolean getCheckAllLines(){return CheckAllLines;}
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    public SVMXC__Quote__c getQuoteHeader(){QuoteHeader.Total_Line_Price2__c=QuoteLinePrice;QuoteHeader.Quote_Amount2__c=QuoteAmount;return QuoteHeader; }
    public List<SVMXC__Quote_Line__c> getPrintQlines(){return QuoteLines;}
    
    //PageReference Method for Quote Header
    public pageReference QuoteSave()
    {
        
        Quote_DisplayBlockLevelMessage=false;
        QuoteLine_DisplayBlockLevelMessage=false;
        
        if(isValidQuote()==true)
        {
            //upsert QuoteHeader;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( QuoteHeader, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert QuoteHeader;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
            if(QuoteHeader.id != null)
            {
                for(SVMXC__Quote_Line__c o : QuoteLines)
                {
                    if(o.SVMXC__Quote__c == null)
                        o.SVMXC__Quote__c = QuoteHeader.id ; 
                }
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Quote_Line__c' ) ) {
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete QuoteLinesToDlt;
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(QuoteLines, COMM_SecurityUtils.Access.Upsertable)){
                     //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert QuoteLines;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                
                PageReference QuotePage = new PageReference('/' + QuoteHeader.Id);
                QuotePage.setRedirect(true);
                
                return QuotePage; 
            }
            /* This is not a valid error message (Tag removed from transaltions)
else
{
ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG010()));
}
*/
        }
        else
        {
            Quote_DisplayBlockLevelMessage=true;
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG015()));
        }
        
        return null;
    }
    
    public pageReference cancel()
    {
        if(WOId != null && QOId == null)
        {
            PageReference ReturnToWO = new PageReference('/' + WOId);
            ReturnToWO.setRedirect(true);
            return ReturnToWO;
        }
        else if(QOId != null && WOId == null )
        {
            PageReference ReturnToQO = new PageReference('/' + QOId);
            ReturnToQO.setRedirect(true);
            return ReturnToQO;
        }
        else{
            Schema.DescribeSObjectResult SXferLine = SVMXC__Installed_Product__c.SObjectType.getDescribe();
            PageReference ReturnToOO = new PageReference('/' + SXferLine.getKeyPrefix());
            ReturnToOO.setRedirect(true);
            return ReturnToOO;
        }
    }
    
    
    //PageReference Method for Quote Lines
    public pageReference AddLines()
    {
        Quote_DisplayBlockLevelMessage=false;
        QuoteLine_DisplayBlockLevelMessage=false;
        SVMXC__Quote_Line__c newLines = new SVMXC__Quote_Line__c(SVMXC__Line_Type__c=DefaultLineType,SVMXC__Discount_Type__c=DefaultLineDiscountType);
        if(userinfo.isMultiCurrencyOrganization() && QuoteHeader.get('CurrencyIsoCode') != null)//added 2 lines below by hh for defect closure #1630 on 13/01/2011
            newLines.put('CurrencyIsoCode',QuoteHeader.get('CurrencyIsoCode'));
        //SVMXC__Quote_Line__c newLines = new SVMXC__Quote_Line__c();
        QuoteLines.add(newLines);
        IsWarn=false;
        return null;
    }
    public pageReference DeleteLines()
    {
        Integer i;
        Quote_DisplayBlockLevelMessage=false;
        QuoteLine_DisplayBlockLevelMessage=false;
        List<Integer> selectedLines = new List<Integer>();
        
        for (i=0;i<QuoteLines.size();i++){
            if(QuoteLines.get(i).SVMXC__Select__c==true)
            {          
                selectedLines.add(i);
                if(QuoteLines.get(i).Id!=NULL)
                    QuoteLinesToDlt.add(QuoteLines.get(i));
            }
        }
        for (i=selectedLines.size()-1;i>=0;i--){
            QuoteLines.remove(selectedLines.get(i));
        }
        QlineSize=QuoteLines.size();
        if(selectedLines.size()==0){
            QuoteLine_DisplayBlockLevelMessage=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',getTAG009()));
        }
        else{
            QuoteLine_DisplayBlockLevelMessage=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,'',getTAG026()));
        }
        OnChangeLineItems();
        if(QlineSize==0)IsWarn=true;
        return null;
    }
    
    public Boolean isValidQuote(){
        Boolean Isvalid = true;
        
        //Validate Quote Header
        
        if(QuoteHeader.SVMXC__Discount__c < 0)
        {
            Isvalid= false;
            QuoteHeader.SVMXC__Discount__c.addError(getTAG029());
        }
        if(QuoteHeader.SVMXC__Service_Order__c == NULL || QuoteHeader.SVMXC__Company__c == NULL || QuoteHeader.SVMXC__Contact__c == NULL || QuoteHeader.SVMXC__Status__c == null)
        {
            Isvalid= false;
            if(QuoteHeader.SVMXC__Service_Order__c == NULL)
                QuoteHeader.SVMXC__Service_Order__c.addError(getTAG011());
            if(QuoteHeader.SVMXC__Company__c == NULL)
                QuoteHeader.SVMXC__Company__c.addError(getTAG012());
            if(QuoteHeader.SVMXC__Contact__c == NULL)
                QuoteHeader.SVMXC__Contact__c.addError(getTAG013());
            if(QuoteHeader.SVMXC__Status__c == null)
                QuoteHeader.SVMXC__Status__c.addError(getTAG014());
        }
        
        if(QuoteHeader.SVMXC__Quote_Amount2__c == NULL ||QuoteHeader.SVMXC__Quote_Amount2__c == 0 ||QuoteHeader.SVMXC__Quote_Amount2__c < 0 )
        {
            Isvalid= false;
            QuoteHeader.SVMXC__Quote_Amount2__c.addError(getTAG016());
        }
        
        if(QuoteHeader.SVMXC__Discount_Type__c=='Percent' && QuoteHeader.SVMXC__Discount__c > 100)
        {
            Isvalid= false;
            QuoteHeader.SVMXC__Discount__c.addError(getTAG017());
        }
        
        if(QuoteHeader.SVMXC__Valid_Until__c!=NULL)
        {
            integer numberDaysDue = QuoteHeader.SVMXC__Valid_Until__c.daysBetween(date.today());
            if(numberDaysDue>0)
            {
                Isvalid= false;
                QuoteHeader.SVMXC__Valid_Until__c.addError(getTAG018());
            }
        }
        else
        {
            Isvalid= false;
            QuoteHeader.SVMXC__Valid_Until__c.addError(getTAG019());
        }
        
        if(QuoteSaveStatus.toUpperCase()=='DISALLOW' && QuoteLines.size()==0){
            
            Isvalid= false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));             
        }
        if(QuoteHeader.SVMXC__Total_Line_Price2__c != null || QuoteHeader.SVMXC__Discount__c != null)
        {
            if(QuoteHeader.SVMXC__Discount_Type__c == 'Amount' && QuoteHeader.SVMXC__Total_Line_Price2__c <= QuoteHeader.SVMXC__Discount__c)
            {
                Isvalid= false;
                QuoteHeader.SVMXC__Discount__c.addError(getTAG028());
            }
        }
        if(QuoteHeader.SVMXC__Discount_Type__c == null && QuoteHeader.SVMXC__Discount__c != null)
        {
            Isvalid= false;
            QuoteHeader.SVMXC__Discount_Type__c.AddError(getTAG032());
        }       
        
        
        //Validate Quote Lines
        for(SVMXC__Quote_Line__c q:QuoteLines)
        {
            if(q.SVMXC__Discount__c < 0)
            {
                Isvalid= false;
                q.SVMXC__Discount__c.addError(getTAG029());
            }
            if(q.SVMXC__Quantity2__c < 0)
            {
                Isvalid= false;
                q.SVMXC__Quantity2__c.addError(getTAG030());
            }
            if(q.SVMXC__Unit_Price2__c < 0)
            {
                Isvalid= false;
                q.SVMXC__Unit_Price2__c.addError(getTAG031());
            }
            if(q.SVMXC__Line_Type__c=='Parts' && q.SVMXC__Product__c == NULL)
            {
                Isvalid= false;
                q.SVMXC__Product__c.addError(getTAG022());
            }
            if(q.SVMXC__Discount_Type__c=='Percent' && q.SVMXC__Discount__c > 100)
            {
                Isvalid= false;
                q.SVMXC__Discount__c.addError(getTAG017());     
            }
            
            if(q.SVMXC__Quantity2__c == NULL || q.SVMXC__Quantity2__c == 0)
            {
                Isvalid= false;
                q.SVMXC__Quantity2__c.addError(getTAG023());    
            }
            if(q.SVMXC__Unit_Price2__c == NULL || q.SVMXC__Unit_Price2__c == 0)
            {
                Isvalid= false;
                q.SVMXC__Unit_Price2__c.addError(getTAG024());  
            }
            if(q.SVMXC__Unit_Price2__c != null && q.SVMXC__Quantity2__c != null && q.SVMXC__Discount__c != null)
            {
                if( q.SVMXC__Discount_Type__c == 'Amount' && q.SVMXC__Unit_Price2__c *q.SVMXC__Quantity2__c  < q.SVMXC__Discount__c)
                {
                    Isvalid= false;
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG027()));  
                }
            }
            system.debug('asdf'+q.SVMXC__Discount_Type__c );
            if(q.SVMXC__Discount_Type__c == null && q.SVMXC__Discount__c != null)
            {
                Isvalid= false;
                q.SVMXC__Discount_Type__c.AddError(getTAG032());
            }
        }
        return Isvalid;
    }     
    
    //======================================== Onchange Activities ===================================================//
    public pageReference OnChangeLineItems()
    {
        OnChangeItems();
        OnChangeHeader();
        return null;
    }
    
    public pageReference OnChangeHeaderItems()
    {               
        /*if(QuoteHeader.SVMXC__Total_Line_Price2__c != null || QuoteHeader.SVMXC__Discount__c != null)
{
if(QuoteHeader.SVMXC__Discount_Type__c == 'Amount' && QuoteHeader.SVMXC__Total_Line_Price2__c < QuoteHeader.SVMXC__Discount__c)
{
QuoteHeader.SVMXC__Total_Line_Price2__c.addErorr(getTAG028());
}
}*/
        if(QuoteHeader.Total_Line_Price2__c != null)
            QuoteLinePrice = QuoteHeader.Total_Line_Price2__c;
        OnChangeHeader();
        return null;
    }
    
    public void OnChangeItems()
    {
        QuoteAmount=0;
        QuoteLinePrice=0;
        
        Decimal UnitLinePrice;
        Decimal UnitLineDiscount;
        
        for(SVMXC__Quote_Line__c q:QuoteLines)
        {
            UnitLineDiscount=0;
            if(q.SVMXC__Discount__c < 0)
            {
                q.SVMXC__Discount__c.addError(getTAG029());
                
            }
            else if(q.SVMXC__Quantity2__c < 0)
            {
                q.SVMXC__Quantity2__c.addError(getTAG030());
            }
            else if(q.SVMXC__Unit_Price2__c < 0)
            {
                q.SVMXC__Unit_Price2__c.addError(getTAG031());
            }
            else
            {
                if(q.SVMXC__Discount_Type__c=='Percent')
                {
                    //q.SVMXC__Discount__c= ((q.SVMXC__Quantity2__c * q.SVMXC__Unit_Price2__c) * (q.SVMXC__Discount__c/100));
                    if(q.SVMXC__Discount__c!=NULL && q.SVMXC__Unit_Price2__c!=NULL && q.SVMXC__Quantity2__c!=NULL)
                        UnitLineDiscount= (q.SVMXC__Quantity2__c * q.SVMXC__Unit_Price2__c) * (q.SVMXC__Discount__c/100);
                }
                else if(q.SVMXC__Discount_Type__c=='Amount')
                {
                    //q.SVMXC__Discount__c = q.SVMXC__Discount__c;
                    if(q.SVMXC__Discount__c!=NULL)
                        UnitLineDiscount = q.SVMXC__Discount__c;
                }
                else if(q.SVMXC__Discount_Type__c=='--None--')
                {
                    //q.SVMXC__Discount__c = 0;
                    UnitLineDiscount = 0;
                }
                
                if(UnitLineDiscount==NULL)
                    UnitLineDiscount=0;
                if(q.SVMXC__Unit_Price2__c!=NULL && q.SVMXC__Quantity2__c!=NULL)
                    UnitLinePrice = (q.SVMXC__Quantity2__c * q.SVMXC__Unit_Price2__c) - UnitLineDiscount;
                else
                    UnitLinePrice=0;
                q.SVMXC__Line_Price2__c = UnitLinePrice;
                QuoteLinePrice = QuoteLinePrice + q.SVMXC__Line_Price2__c;
            }
        }
    }
    public void OnchangeHeader()
    {
        Decimal UnitLineDiscount=0;
        if(QuoteHeader.SVMXC__Discount__c < 0)
        {
            QuoteHeader.SVMXC__Discount__c.addError(getTAG029());
        } 
        //if(QuoteHeader.SVMXC__Discount__c)
        if(QuoteHeader.SVMXC__Discount_Type__c=='Percent')
        {
            if(QuoteHeader.SVMXC__Discount__c!=NULL && QuoteHeader.Total_Line_Price2__c!=NULL)
                UnitLineDiscount= (QuoteHeader.Total_Line_Price2__c) * (QuoteHeader.SVMXC__Discount__c/100);
        }
        else if(QuoteHeader.SVMXC__Discount_Type__c=='Amount')
        {
            if(QuoteHeader.SVMXC__Discount__c!=NULL)
                UnitLineDiscount= QuoteHeader.SVMXC__Discount__c;
        }
        else if(QuoteHeader.SVMXC__Discount_Type__c==NULL)
        {
            UnitLineDiscount= 0;
        }
        QuoteAmount = QuoteLinePrice - UnitLineDiscount;
        
    }
    //======================================== Set true to display blocklevel messge ===================================================//
    public Boolean Quote_DisplayBlockLevelMessage = false;
    public Boolean getQuote_DisplayBlockLevelMessage(){ return Quote_DisplayBlockLevelMessage; }   
    public Boolean Quote_DisplayBlockLevelMessage2 = false;
    public Boolean getQuote_DisplayBlockLevelMessage2(){ return Quote_DisplayBlockLevelMessage2; }   
    public Boolean QuoteLine_DisplayBlockLevelMessage = false;
    public Boolean getQuoteLine_DisplayBlockLevelMessage(){ return QuoteLine_DisplayBlockLevelMessage; }      
}