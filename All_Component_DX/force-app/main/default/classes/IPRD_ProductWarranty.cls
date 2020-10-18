public with Sharing class IPRD_ProductWarranty {
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

//======================================== Simple Display Utility ===================================================//
    //COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD002');
    COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('IPRD002');
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();

    
    public String getTAG001() {return System.Label.IPRD002_TAG001;} //Create Product Warranty for<IP Name>
    public String getTAG002() {return System.Label.IPRD002_TAG002;} //Product Warranty Help
    public String getTAG003() {return System.Label.IPRD002_TAG003;} //Create Warranty
    public String getTAG004() {return System.Label.IPRD002_TAG004;} //Cancel
    public String getTAG005() {return System.Label.IPRD002_TAG005;} //Select
    public String getTAG006() {return System.Label.IPRD002_TAG006;} //Product is not available with the selected Install Product
    //public String getTAG007() {return System.Label.IPRD002_TAG007;}
    public String getTAG008() {return System.Label.IPRD002_TAG008;} //Install date cannot be earlier than Order date..
    public String getTAG009() {return System.Label.IPRD002_TAG009;} //Ship date cannot be earlier than Order date.
    public String getTAG010() {return System.Label.IPRD002_TAG010;} //Install date cannot be earlier than Ship date.
    public String getTAG011() {return System.Label.IPRD002_TAG011;} //Please enter a valid date for Date Ordered.
    public String getTAG012() {return System.Label.IPRD002_TAG012;} //Please enter a valid date for Date Shipped.
    public String getTAG013() {return System.Label.IPRD002_TAG013;} //Please enter a valid date for Last Date Shipped.
    public String getTAG014() {return System.Label.IPRD002_TAG014;} //Please enter a valid date for Date Installed.
    public String getTAG015() {return System.Label.IPRD002_TAG015;} //Applicable Warranty Terms
    public String getTAG016() {return System.Label.IPRD002_TAG016;} //Other Warranty Terms
    public String getTAG017() {return System.Label.IPRD002_TAG017;} //No records to display
    public String getTAG018() {return System.Label.IPRD002_TAG018;} //Installed Product or Warranty Term doesnot have suffecient information to create warranty
    //public String getTAG019() {return System.Label.IPRD002_TAG019;} //Unable to proceed. No installed product record ID is available in the URL
    public String getTAG026() {return System.Label.IPRD002_TAG026;} //Insufficient number of parameters provided for this screen. Please contact your ServiceMax administrator to resolve this.
    public String getTAG028() {return System.Label.IPRD002_TAG028;} //Please select one of the warranty terms first
    public String getTAG029() {return System.Label.IPRD002_TAG029;} //No warranty terms found
    public String getTAG030() {return System.Label.IPRD002_TAG030;} //Loading...
    public String getTAG031() {return System.Label.IPRD002_TAG031;} //This functionality can be launched only from Installed Product screen
    public String getTAG032() {return System.Label.IPRD002_TAG032;} //FIELD NOT AVAILABLE
    //public String getTAG033() {return System.Label.IPRD002_TAG033;} //FIELD NOT CONFIGURED
    public String getTAG034() {return System.Label.IPRD002_TAG034;} //Template Name
    public String getTAG035() {return System.Label.IPRD002_TAG035;} //Coverage Effective From
    public String getTAG043() {return System.Label.IPRD002_TAG043;} //Coverage start date has not been configured for any warranty terms
    public String getTAG036() {return System.Label.IPRD002_TAG036;} //'Material % Covered'
    public String getTAG037() {return System.Label.IPRD002_TAG037;} //'Labor % Covered'
    public String getTAG045() {return System.Label.IPRD002_TAG045;} //'Expenses % Covered'
    
    public String getHLPURL() {return System.Label.IPRD002_HLPURL;}//HLPURL 
   
//========================================= Variables =============================================//
    String PId= System.currentPageReference().getParameters().get('PId');
    list<SVMXC__Service_Template__c> CoveredwarrantyTerm = new list<SVMXC__Service_Template__c>();
    list<SVMXC__Service_Template__c> OtherwarrantyTerm = new list<SVMXC__Service_Template__c>();
    Installed_Product__c IProduct = new Installed_Product__c();
    public boolean IsWCreatable=true;
    integer CoveredCount=0;
    integer OtherCount=0;
    String WarrantyName;
    Boolean IsValid = true;
    public Boolean getIsValid(){   return this.IsValid; } 
    boolean isSetToday=false; 
    public List<warrantyWrapper> CwarrantyList {get; set;}
    public List<warrantyWrapper> OwarrantyList {get; set;}
    public string selectedId='';
    public string getselectedId() {return selectedId;  }
    public void setselectedId(string ids){this.selectedId=ids;}
    SVMXC.IPRD_Utils IPRD_Utils = new SVMXC.IPRD_Utils(); 
    public Map<String, Schema.SObjectType> allObjs; 
    String KeyPrefix;  

//======================================== Constructure call ===================================================//  
    public IPRD_ProductWarranty(ApexPages.StandardController controller) {
        Schema.DescribeSObjectResult SXferLine = SVMXC__Installed_Product__c.SObjectType.getDescribe();
        KeyPrefix=SXferLine.getKeyPrefix();
        if(PId!='' && PId!=NULL){
        String KPrefix=PID.substring(0, 3);
        if(KPrefix.equals(KeyPrefix))
        OnLoad();
        else{
            IsValid = false;
            SVMXERR_addMessage(getTAG031(),true);
        }
        }
        else{
            IsValid = false;
            SVMXERR_addMessage(getTAG026(),true);
        }
    }
    public void OnLoad(){
        Boolean IsWarrantyAvailable=false;
        try{        
         Schema.DescribeSObjectResult souObj = SVMXC__Installed_Product__c.sObjectType.getDescribe();
         Map<String, SObjectField> MapAllIBFields = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
          /***************duplicate Check******************************/
         COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
         MapAllIBFields = objCommUtilV2.removeDuplicateFields(MapAllIBFields);
         /************************************************************/
         String GetAllIBFields;
         List<String> ListAllIBFields = utils.SVMX_getFieldList(MapAllIBFields,true); 
         GetAllIBFields = utils.SVMX_getFieldNamesFromList(ListAllIBFields);
         IProduct =Database.query('SELECT ' + GetAllIBFields +' FROM SVMXC__Installed_Product__c WHERE Id =:PId');//\''+PId+'\'(commented by amar on 18/2/10 3:38 pm becasue of Security Review)
         
         system.debug('TESTPB-1:'+IProduct+GetAllIBFields);
         system.debug('TESTPB-2:'+IProduct.SVMXC__Last_Date_Shipped__c);
         WarrantyName = IProduct.Name;
         //IProduct = [SELECT Name,SVMXC__Product__c,SVMXC__Serial_Lot_Number__c,SVMXC__Date_Installed__c,SVMXC__Date_Shipped__c,SVMXC__Date_Ordered__c,SVMXC__Last_Date_Shipped__c from SVMXC__Installed_Product__c where Id=:PId]; 
        }
        catch (Exception ex){
            //SVMXERR_addMessage(ex.getMessage());
        }
        if(IProduct.Product__c==NULL){
            SVMXERR_addMessage(getTAG006(),true);
        }
        else{
            integer numberDays;
            set<Id> CoveredIds = new set<Id>();
            Product2 IP_Product = [SELECT Tracking__c,Product_Line__c,Family FROM Product2 where Id=:IProduct.Product__c];
            /*
            if((IP_Product.Tracking__c=='Serialized' || IP_Product.Tracking__c=='Lot/Batch Tracked') && IProduct.Serial_Lot_Number__c==''){
                SVMXERR_addMessage(getTAG007(),true);
            }
            */
            /*
            if(IProduct.SVMXC__Date_Ordered__c==NULL)SVMXERR_addMessage(getTAG011(),true);
            if(IProduct.SVMXC__Date_Shipped__c==NULL)SVMXERR_addMessage(getTAG012(),true);
            if(IProduct.SVMXC__Last_Date_Shipped__c==NULL)SVMXERR_addMessage(getTAG013(),true);
            if(IProduct.SVMXC__Date_Installed__c==NULL)SVMXERR_addMessage(getTAG014(),true);
            */
            /* Date Validations
            if(IProduct.SVMXC__Date_Installed__c!=NULL && IProduct.SVMXC__Date_Ordered__c!=NULL){
                numberDays= IProduct.SVMXC__Date_Ordered__c.daysBetween(IProduct.SVMXC__Date_Installed__c);
                if(numberDays<0)
                SVMXERR_addMessage(getTAG008(),true);
            }
            if(IProduct.SVMXC__Date_Shipped__c!=NULL && IProduct.SVMXC__Date_Ordered__c!=NULL){
                numberDays= IProduct.SVMXC__Date_Ordered__c.daysBetween(IProduct.SVMXC__Date_Shipped__c);
                if(numberDays<0)
                SVMXERR_addMessage(getTAG009(),true);
            }
            if(IProduct.SVMXC__Date_Shipped__c!=NULL && IProduct.SVMXC__Date_Installed__c!=NULL){
                numberDays= IProduct.SVMXC__Date_Shipped__c.daysBetween(IProduct.SVMXC__Date_Installed__c);
                if(numberDays<0)
                SVMXERR_addMessage(getTAG010(),true);
            }
            */
            CoveredIds=IPRD_Utils.SVMXC_Get_CoveredProducts(IProduct);
            system.debug('TESTPB:'+CoveredIds);
/*
            for (SVMXC__Service_Template_Products__c stprod : [SELECT SVMXC__Service_Template__c 
                                            FROM SVMXC__Service_Template_Products__c 
                                            WHERE SVMXC__Product__c = :IProduct.Product__c
                                            OR SVMXC__Product_Family__c = :IP_Product.Family
                                            OR SVMXC__Product_Line__c = :IP_Product.Product_Line__c]){
                                                CoveredIds.add(stprod.SVMXC__Service_Template__c);
                                            }
*/  
        if(svmxSettingList.containsKey('SET008') == true)
        isSetToday = svmxSettingList.get('SET008').equalsIgnoreCase('true');                        
                
        if(isSetToday==true){
                    CoveredwarrantyTerm = [SELECT Id,Name, SVMXC__Coverage_Effective_From2__c, SVMXC__Material_Covered__c, SVMXC__Time_Covered__c, SVMXC__Expenses_Covered__c From SVMXC__Service_Template__c where Id IN :CoveredIds order by Name];
                    OtherwarrantyTerm = [SELECT Id,Name, SVMXC__Coverage_Effective_From2__c,SVMXC__Material_Covered__c, SVMXC__Time_Covered__c, SVMXC__Expenses_Covered__c From SVMXC__Service_Template__c where Id NOT IN :CoveredIds order by Name];
        }
        else{
                    CoveredwarrantyTerm = [SELECT Id,Name, SVMXC__Coverage_Effective_From2__c,SVMXC__Material_Covered__c, SVMXC__Time_Covered__c, SVMXC__Expenses_Covered__c From SVMXC__Service_Template__c where SVMXC__Coverage_Effective_From2__c!=NULL and Id IN :CoveredIds order by Name];
                    OtherwarrantyTerm = [SELECT Id,Name, SVMXC__Coverage_Effective_From2__c,SVMXC__Material_Covered__c, SVMXC__Time_Covered__c, SVMXC__Expenses_Covered__c From SVMXC__Service_Template__c where SVMXC__Coverage_Effective_From2__c!=NULL and Id NOT IN :CoveredIds order by Name];
        }

        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        Map<String,String> LabelFromName = new Map<String,String>();
        allObjs = Schema.getGlobalDescribe();
        //Schema.SObjectType objT = allObjs.get('installed_Product__c') ;
        //Changed the above line with fully qualified object name
        Schema.SObjectType objT = allObjs.get('SVMXC__Installed_Product__c') ;
        objfieldMap = objT.getDescribe().fields.getMap();
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            LabelFromName.put(f.getName(),f.getLabel());
        }

        
        for(integer a=0;a<CoveredwarrantyTerm.size();a++)
        {
            if(LabelFromName.get(CoveredwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c)!=null)
            CoveredwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c = LabelFromName.get(CoveredwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c);   
            else{
                if(CoveredwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c==null)
                CoveredwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c=getTAG032();
                else
                CoveredwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c=getTAG032();
            }
        }
        for(integer a=0;a<OtherwarrantyTerm.size();a++)
        {
            if(LabelFromName.get(OtherwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c)!=null)
            OtherwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c = LabelFromName.get(OtherwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c);   
            else{
                if(OtherwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c==null)
                OtherwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c=getTAG032();
                else
                OtherwarrantyTerm[a].SVMXC__Coverage_Effective_From2__c=getTAG032();
            }
        }
            CoveredCount=CoveredwarrantyTerm.size();
            OtherCount=OtherwarrantyTerm.size();
            if(CoveredwarrantyTerm.size()==0 && OtherwarrantyTerm.size()==0){
                //Check Whether any warranty exist
                List<SVMXC__Service_Template__c> warCount = new List<SVMXC__Service_Template__c>();
                warCount = [SELECT Id From SVMXC__Service_Template__c where Id != null];// 06/01/2011 // Defect #001688
                if(warCount.size()>0)
                SVMXERR_addMessage(getTAG043(),true);
                else
                SVMXERR_addMessage(getTAG029(),true);
            }
                if(OwarrantyList == null)
                OwarrantyList = new List<warrantyWrapper>();
                for(SVMXC__Service_Template__c O : OtherwarrantyTerm){
                    if(o.SVMXC__Coverage_Effective_From2__c==getTAG032())
                    OwarrantyList.add(new warrantyWrapper(O,false));
                    else
                    OwarrantyList.add(new warrantyWrapper(O,true));
                }
                if(CwarrantyList == null)
                CwarrantyList = new List<warrantyWrapper>();
                for(SVMXC__Service_Template__c O : CoveredwarrantyTerm){
                    if(o.SVMXC__Coverage_Effective_From2__c==getTAG032())
                    CwarrantyList.add(new warrantyWrapper(O,false));
                    else
                    CwarrantyList.add(new warrantyWrapper(O,true));
                }               
        }
        system.debug('TESTPB:1'+CwarrantyList+OwarrantyList);
    }
    public list<warrantyWrapper> getOtherwarrantyTerm(){
        return OwarrantyList;
    }
    public list<warrantyWrapper> getCoveredwarrantyTerm(){
        return CwarrantyList;
    }
    public Installed_Product__c getIProduct(){
        return IProduct;
    }
    public boolean getIsWCreatable(){
        return IsWCreatable;
    }
    public integer getCoveredCount(){
        return CoveredCount;
    }
    public integer getOtherCount(){
        return OtherCount;
    }
    public String getWarrantyName(){
        if(WarrantyName!=NULL)
        return getTAG001()+' '+WarrantyName;
        else
        return '';
    }
//========================================= Page References for Create Warranty =============================================//
    public PageReference GoCreateW(){
        SVMXC.IPRD_Utils.CreateWarrantyResult ResultSet;
        List<SVMXC__Installed_Product__c> IBList = new List<SVMXC__Installed_Product__c>();
        List<SVMXC__Service_Template__c> WarrantyList= new List<SVMXC__Service_Template__c>();
        Map<Id,list<SVMXC__Service_Template__c>> IBtoWarranty = new Map<Id,list<SVMXC__Service_Template__c>>();
        set<String> SelectedIdSet = new set<String>();
        //system.debug('TESTPB001:'+selectedId);
        if(selectedId!=NULL && selectedId!=''){
            SelectedIdSet.add(selectedId);
            IBList.add(IProduct); 
            WarrantyList= [SELECT Id,Name,SVMXC__Coverage_Effective_From2__c,SVMXC__Duration_of_Time_Coverage__c,SVMXC__Unit_of_Time__c,SVMXC__Duration_of_Material_Coverage__c,
            SVMXC__Unit_of_Time_Material__c,SVMXC__Duration_of_Expenses__c,SVMXC__Unit_of_Time_Expenses__c FROM SVMXC__Service_Template__c  WHERE Id IN :SelectedIdSet];
            IBtoWarranty.put(IProduct.Id, WarrantyList);
            //system.debug('TESTPB001:'+IBList+IBtoWarranty);
            ResultSet=IPRD_Utils.SVMXC_Set_CreateWarranty_IPW(IBList,IBtoWarranty);
            //system.debug('TESTPB001:'+ResultSet);
            if(ResultSet.Status=='SUCCESS' && ResultSet.RetURL!=NULL){ 
                return GoLoader(ResultSet.RetURL); 
            }
            else{
                SVMXERR_addMessage(ResultSet.Status,false);
            }
        }
        else{
            SVMXERR_addMessage(getTAG028(),false);
        }
        return null;
    }

//========================================= Page References for OnCancel =============================================//
    public PageReference GoBack(){
        if(PId!=NULL && PID!='')
        return GoLoader(IProduct.Id);
       // return GoLoader(PId);
        else
        return GoLoader(KeyPrefix);
    }
//========================================= Page References for OnCancel =============================================//
    public PageReference GoLoader(String URLId){
        String strRetURL = '/';
        //if(svmxSettingList.containsKey('SET002') == true) strRetURL =svmxSettingList.get('SET002');
        strRetURL='/'+URLId;
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes
        //PageReference LoadPage = new PageReference(strRetURL); //Commented for the Security fixes
        PageReference LoadPage = new PageReference(baseURL + strRetURL);
        LoadPage.setRedirect(true);
        return LoadPage; 
    }
//========================================= PageLevel Error Messages =============================================//
    public void SVMXERR_addMessage(String Err,boolean Isdisable){
        if(IsWCreatable==true && Isdisable==true)IsWCreatable=false;
        ProfDisplayBlockLevelMessage=true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',Err)); 
    }
//======================================== Set true to display blocklevel messge ===================================================// 
    public Boolean ProfDisplayBlockLevelMessage = false;
    public Boolean getProfDisplayBlockLevelMessage(){ return ProfDisplayBlockLevelMessage; }   

    public class warrantyWrapper{
        public SVMXC__Service_Template__c war {get; set;}
        public String ButtonStyle {get; set;}
        public String RowStyle {get; set;}
        
        /*This is the contructor method. When we create a new wrapper object we pass a 
        warranty that is set to the war property. We also set the selected value to false*/
        public warrantyWrapper(SVMXC__Service_Template__c w, Boolean Valid){
            war = w;
            if(Valid==false){
                RowStyle='background-color: #FFBCBC;';
                ButtonStyle = 'display:none';
            }
            else{
                RowStyle='';
                ButtonStyle = '';
            }
        }
    }
}