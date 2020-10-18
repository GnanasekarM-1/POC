global with sharing class COMM_PriceClass{
    public static RecordType rt;
    public static List<RecordType> rtL;
    public static Pricebook2 pbk;
    public static PricebookEntry pbe;
    public static String GenErrMsg;
    private static String ErrorText;
    private static boolean ErrorFlag;
    public static Product2 product;
    
    //Naveen:Removing CURECYISOCODE
    public static Boolean isMultiCurrency ;
    public COMM_PriceClass()
    {
        isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        system.debug('amar'+UserInfo.isMultiCurrencyOrganization());
        system.debug('amar'+isMultiCurrency);
    }
    
    //New Method
    public static void SVMXC_SetSVOLinePriceLst(List<SVMXC__Service_Order_Line__c> svol){ ////Prefixed lst in method name to avoid security conflicts as method was overloaded.// Gm Aug11-2011
        isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        List<PricebookEntry> PriceBookList;
        String rType;
        Set<String> PriceBookName = new Set<String>();
        Set<Id> ProductIdList = new Set<Id>();
        Set<Id> SOIdList = new Set<Id>();
        Set<Id> FinalProductId = new Set<Id>();
        Set<Id> FinalPricebookId = new Set<Id>();
        Set<String> FinalCurrencyCode = new Set<String>();
        Map<String, Pricebook2> NameToPriceBook2Map =  new Map<String, Pricebook2> {};
        Map<Id, String> IdToCurrencyIsoCodeMap =  new Map<Id, String> {};
        Map<Id, String> IdToRTNameMap =  new Map<Id, String> {};
        Map<String, SVMXC__Service_Order_Line__c> StringToSOMap =  new Map<String, SVMXC__Service_Order_Line__c> {};
        Map<String, String> StringToPriceMap =  new Map<String, String> {};
        
        SVMXC.COMM_Utils_ManageSettings svosettings = new SVMXC.COMM_Utils_ManageSettings();
        List<String> setLst = new List<String>();
        setLst.add('SET004');
        setLst.add('SET006');
        setLst.add('SET008');
        setLst.add('SET009');
        setLst.add('SET010');
        setLst.add('SET011');
        setLst.add('SET013');
        Map<String, String> SVOSubModuleSettings = svosettings.SVMX_getSettingList('WORD005', setLst);
        
        String UsagePriceBook = SVOSubModuleSettings.get('SET004'); //setting for default Usage Price Book
        String EstPriceBook = SVOSubModuleSettings.get('SET006'); //setting for default Esimate Price Book
        String ReqPriceBook = SVOSubModuleSettings.get('SET008'); //setting for default Req/Rec Price Book
        String UsagePriceBookTrigger = SVOSubModuleSettings.get('SET009'); //setting for Usage Price Book for trigger
        String EstimatePriceBookTrigger = SVOSubModuleSettings.get('SET010'); //setting for Estimate Price Book for trigger
        String ReqPriceBookTrigger = SVOSubModuleSettings.get('SET011'); //setting for Req/Rec Price Book for trigger
        String RunTrigger = SVOSubModuleSettings.get('SET013');
        system.debug('UsagePriceBookTrigger'+UsagePriceBookTrigger);
        Double UnitPrice=0.0;
        Integer SettingCount=0; 
        String ErrMsg='';
        rtL = new List<RecordType>();
        pbk = new Pricebook2();
        pbe = new PricebookEntry(); 
        PriceBookList = new List<PricebookEntry>();
        GenErrMsg ='<br> This is a setup issue. Please report this error to your ServiceMax Administrator.';
        //Set the Service Order List and Product List
        
        system.debug('RunTrigger '+ RunTrigger);
        if(String.isNotBlank(RunTrigger) && RunTrigger.toUpperCase() == 'TRUE')
        {
            list<SVMXC__Service_Order_Line__c> LinesTobeUpdated = new list<SVMXC__Service_Order_Line__c>();
            system.debug('We are in First Loop');
            for(SVMXC__Service_Order_Line__c s:svol)
            {
                if(s.SVMXC__Use_Price_From_Pricebook__c==true && s.SVMXC__Product__c!=NULL)
                {
                    SOIdList.add(s.SVMXC__Service_Order__c);
                    ProductIdList.add(s.SVMXC__PRODUCT__C);
                    LinesTobeUpdated.add(s);
                }
            }       
            if((UsagePriceBookTrigger.toUpperCase() == 'TRUE' || EstimatePriceBookTrigger.toUpperCase() == 'TRUE' || ReqPriceBookTrigger.toUpperCase() == 'TRUE'))
            {
                system.debug('Entered..');
                //List of Currency ISO Codes 
                //Naveen:21/05
                List<SVMXC__Service_Order__c> svo; 
                if(isMultiCurrency)
                {
                    string svoQuery = 'SELECT CurrencyIsoCode FROM SVMXC__Service_Order__c WHERE Id IN :SOIdList';
                    svo = database.query(svoQuery);
            
                }
            
                system.debug('svo '+ svo);
                system.debug('ProductIdList.. '+ ProductIdList);
                if(svo!=NULL)
                {
                    for(SVMXC__Service_Order__c s:svo){
                        IdToCurrencyIsoCodeMap.put(s.Id,string.valueOf(s.get('CurrencyIsoCode')));
                    }
                }
                //Price book
                PriceBookName.add(UsagePriceBook);
                PriceBookName.add(EstPriceBook);
                PriceBookName.add(ReqPriceBook);     
                List<String> queryFields = new List<String> {'Id', 'IsActive', 'Name'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Pricebook2', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }           
                List<Pricebook2> pbkTemp = [SELECT Id,IsActive,Name FROM Pricebook2 WHERE Name IN :PriceBookName AND IsActive = true]; //SDL-SVMX-READ-FLS-ENFORCED
                system.debug('pbkTemp' + pbkTemp);
                for(Pricebook2 p:pbkTemp){
                    if(p.IsActive==true)
                        NameToPriceBook2Map.put(p.Name, p);
                }               
                //Retrieve Record Type for SVO Line Object 
                list<string> lstRecordTypeName = new list<string>();
                lstRecordTypeName.add('Usage/Consumption');
                lstRecordTypeName.add('Estimate');
                lstRecordTypeName.add('Request/Receipt');
                rtL = [SELECT Name,Id FROM RecordType where Name IN :lstRecordTypeName];
                
                for(RecordType r: rtL){
                    IdToRTNameMap.put(r.Id, r.Name);
                }
                if(LinesTobeUpdated.size() > 0)
                {
                    for(SVMXC__Service_Order_Line__c s:LinesTobeUpdated)
                    {   //Loop Begins
                        rType = IdToRTNameMap.get(s.RecordTypeId);
                        if (rType == 'Usage/Consumption' && UsagePriceBookTrigger.toUpperCase() == 'TRUE')
                        {
                            pbk = NameToPriceBook2Map.get(UsagePriceBook);
                            System.debug('-----one----'+pbk);
                        }
                        else if (rType == 'Estimate' && EstimatePriceBookTrigger.toUpperCase() == 'TRUE')
                        {
                            pbk = NameToPriceBook2Map.get(EstPriceBook);
                            System.debug('-----Two----'+pbk);
                        }
                        else
                        {
                            if(ReqPriceBookTrigger.toUpperCase() == 'TRUE')
                            {
                                pbk = NameToPriceBook2Map.get(ReqPriceBook);
                                system.debug('Wrong Value');
                            }
                        }
                        system.debug('pbk~~~~' + pbk);
                        if (pbk != null)
                        {
                            FinalProductId.add(s.SVMXC__Product__c);
                            FinalPricebookId.add(pbk.Id);
                            //Naveen:21/05
                            if(IdToCurrencyIsoCodeMap!=null && IdToCurrencyIsoCodeMap.size()>0)
                            {
                                FinalCurrencyCode.add(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c));
                                StringToSOMap.put(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c)), s);
                            }
                            else
                                StringToSOMap.put(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id), s);
                        }
                    }//Loop Ends
                }
                if(LinesTobeUpdated.size() > 0)
                {
                    //Naveen:21/05
                    string PriceBookListQuery;
                    if(isMultiCurrency)
                        PriceBookListQuery = 'SELECT Name,UnitPrice,IsActive,Pricebook2Id,CurrencyIsoCode,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN : FinalPricebookId AND CurrencyIsoCode IN :FinalCurrencyCode AND Product2Id IN :FinalProductId AND IsActive = true'; 
                    else
                        PriceBookListQuery = 'SELECT Name,UnitPrice,IsActive,Pricebook2Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN : FinalPricebookId AND Product2Id IN :FinalProductId AND IsActive = true';
                
                    PriceBookList = database.query(PriceBookListQuery);
                    system.debug('PriceBookListQuery~~~~' + PriceBookList);
                    for(PricebookEntry p: PriceBookList)
                    {
                        if(p.IsActive==true)
                        {
                            //Naveen:21/05
                            if(isMultiCurrency)
                            {
                                StringToPriceMap.put(String.valueOf(p.Product2Id)+String.valueOf(p.Pricebook2Id)+String.valueOf(p.get('CurrencyIsoCode')), String.valueOf(p.UnitPrice));
                            }   
                            else
                            {
                                StringToPriceMap.put(String.valueOf(p.Product2Id)+String.valueOf(p.Pricebook2Id), String.valueOf(p.UnitPrice));
                            }                       
                        }
                    }
                    system.debug('StringToPriceMap~~~~' + StringToPriceMap.size());
                    system.debug('StringToPriceMap~~~~' + StringToPriceMap);
                    for(SVMXC__Service_Order_Line__c s:LinesTobeUpdated)
                    {   
                        //Loop Begins (Updates the value)
                        boolean UsageTrue = false;
                        boolean EstTrue = false;
                        rType = IdToRTNameMap.get(s.RecordTypeId);
                        if (rType == 'Usage/Consumption' && UsagePriceBookTrigger.toUpperCase() == 'TRUE')
                        {
                            pbk = NameToPriceBook2Map.get(UsagePriceBook);
                            UsageTrue = true;                       
                        }
                        else
                        {
                            if(ReqPriceBookTrigger.toUpperCase() == 'TRUE' && !UsageTrue)
                            {
                                pbk = NameToPriceBook2Map.get(ReqPriceBook);                            
                            }
                        }
                        if (rType == 'Estimate' && EstimatePriceBookTrigger.toUpperCase() == 'TRUE')
                        {
                            pbk = NameToPriceBook2Map.get(EstPriceBook);
                            EstTrue = true;
                        }
                        else
                        {
                            if(ReqPriceBookTrigger.toUpperCase() == 'TRUE' && !EstTrue && !UsageTrue){
                                pbk = NameToPriceBook2Map.get(ReqPriceBook);                            
                            }   
                        }
                        if(pbk!=NULL)
                        {
                            String PId = String.valueOf(s.SVMXC__Product__c);
                            String PbId = String.valueOf(pbk.Id);
                            String SoMapId = PId + PbId ;
                            if(IdToCurrencyIsoCodeMap!=null && IdToCurrencyIsoCodeMap.size()>0)
                            {
                                String Cod = String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c));
                                SoMapId +=  Cod;    
                            }
                            //Naveen:21/05
                            if(isMultiCurrency)
                            {                   
                                if(StringToSOMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c)))!=NULL && StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c)))!=NULL)
                                {                           
                                    rType = IdToRTNameMap.get(s.RecordTypeId);
                                    if (rType == 'Usage/Consumption' || rType == 'Request/Receipt')
                                    {
                                        system.debug('Unit Price  ' +decimal.valueOf(StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c)))));
                                        s.SVMXC__Actual_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c))));
                                    }
                                    else
                                        s.SVMXC__Estimated_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(s.SVMXC__Service_Order__c))));
                                }
                            }
                            else
                            {
                                if(StringToSOMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id))!=NULL && StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id))!=NULL)
                                {                        
                                    rType = IdToRTNameMap.get(s.RecordTypeId);
                                    if (rType == 'Usage/Consumption' || rType == 'Request/Receipt')
                                    {
                                        system.debug('Unit Price  ' +decimal.valueOf(StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id))));
                                        s.SVMXC__Actual_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)));
                                    }
                                    else
                                        s.SVMXC__Estimated_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(s.SVMXC__Product__c)+String.valueOf(pbk.Id)));
                                }
                            }
                        }
                        system.debug('Actual Price ' + s.SVMXC__Actual_Price2__c);//Loop Ends
                    }
                
                }
            }
        
        }
    }   
    
    
    
    public static void SVMXC_SetRMA_ShipmentLinePriceLst(List<SVMXC__RMA_Shipment_Line__c> rmasl){
        SVMXC.COMM_PriceClass.SVMXC_SetRMA_ShipmentLinePrice(rmasl);
    }
    global static void SVMXC_SetRMA_ShipmentLinePrice(List<SVMXC__RMA_Shipment_Line__c> rmasl){
        system.debug('Entered List method');
        isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        SVMXC.COMM_Utils_ManageSettings posettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstPORD001SettingID = new list<string>();
        lstPORD001SettingID.add('SET011');
        lstPORD001SettingID.add('SET017');
        lstPORD001SettingID.add('SET022');
        
        list<string> lstPORD002SettingID = new list<string>();
        lstPORD002SettingID.add('SET011');
        lstPORD002SettingID.add('SET017');
        lstPORD002SettingID.add('SET022');
        
        Map<String, String> RMASubModuleSettings = posettings.SVMX_getSettingList('PORD001', lstPORD001SettingID);
        Map<String, String> ShipmentSubModuleSettings = posettings.SVMX_getSettingList('PORD002', lstPORD002SettingID);
        String RMAPriceBook = RMASubModuleSettings.get('SET011'); //setting for default RMA Price Book
        String ShipmentPriceBook = ShipmentSubModuleSettings.get('SET011'); //setting for default Shipment Price Book
        String RMAPriceBookTrigger = RMASubModuleSettings.get('SET017'); //setting for default RMA Price Book trigger
        String ShipmentPriceBookTrigger = ShipmentSubModuleSettings.get('SET017'); //setting for default Shipment Price Book trigger
        
        String RunTriggerRMA = RMASubModuleSettings.get('SET022');
        String RunTriggerShpmnt = ShipmentSubModuleSettings.get('SET022');
        Set<Id> ShipOrderId = new Set<Id>();
        list<string> RecType = new list<string>();
        RecType.add('RMA');
        RecType.add('Shipment');
        Set<Id> ProductIds = new Set<Id>();
        Set<String> PriceBookName = new Set<String>();
        Set<Id> FinalProductId = new Set<Id>();
        Set<Id> FinalPricebookId = new Set<Id>();
        Set<String> FinalCurrencyCode = new Set<String>();
        Map<Id, String> IdToCurrencyIsoCodeMap =  new Map<Id, String> {};
        Map<Id, String> IdToRTNameMap =  new Map<Id, String> {};
        Map<String, Pricebook2> NameToPriceBook2Map =  new Map<String, Pricebook2> {};
        Map<String, SVMXC__RMA_Shipment_Line__c> StringToRMASMap =  new Map<String, SVMXC__RMA_Shipment_Line__c> {};
        Map<String, String> StringToPriceMap =  new Map<String, String> {};
        
        Double UnitPrice=0.0;
        Integer SettingCount=0; 
        String rType;
        String ErrMsg='';
        GenErrMsg ='<br> This is a setup issue. Please report this error to ServiceMax Administrator.'; 
        
        List<PricebookEntry> PriceBookList = new List<PricebookEntry>();
        rtL = new List<RecordType>();
        pbk = new Pricebook2();
        pbe = new PricebookEntry();
        SVMXC_ReSetErrorFlag();
        system.debug('RMA1'+RunTriggerRMA.toUpperCase());
        system.debug('Shipment1'+RunTriggerShpmnt.toUpperCase());
        system.debug('RMA2'+RMAPriceBookTrigger.toUpperCase());
        system.debug('Shipment2'+ShipmentPriceBookTrigger.toUpperCase());
        if(RunTriggerRMA.toUpperCase() == 'TRUE' || RunTriggerShpmnt.toUpperCase() == 'TRUE'){
            if((RMAPriceBookTrigger.toUpperCase() =='TRUE') ||( ShipmentPriceBookTrigger.toUpperCase() =='TRUE')){
                //Set the Shipment Order List and Product List
                for(SVMXC__RMA_Shipment_Line__c r: rmasl){
                    ShipOrderId.add(r.SVMXC__RMA_Shipment_Order__c);
                    ProductIds.add(r.SVMXC__Product__c);
                }       
            
                //Getting all recordTypes
                //rtL = [SELECT Name,Id FROM RecordType where Name ='RMA'];
                rtL = [SELECT Name,Id FROM RecordType where Name IN :RecType];
                for(RecordType r: rtL){
                    IdToRTNameMap.put(r.Id, r.Name);
                }
        
                //Price book
                PriceBookName.add(RMAPriceBook);
                PriceBookName.add(ShipmentPriceBook);
            
                //Getting all pricebook
                List<String> queryFields = new List<String> {'Id', 'IsActive', 'Name'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Pricebook2', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                List<Pricebook2> pbkTemp = [SELECT Id,IsActive,Name FROM Pricebook2 WHERE Name IN :PriceBookName AND IsActive = true]; //SDL-SVMX-READ-FLS-ENFORCED
                for(Pricebook2 p:pbkTemp){
                    
                    if(p.IsActive==true)
                        NameToPriceBook2Map.put(p.Name, p);
                        
                }
                //set the currency of the line to the currency of the parent 
                
                //Naveen:21/05
                List<SVMXC__RMA_Shipment_Order__c> rso;
                if(isMultiCurrency)
                { 
                    
                    string rsoQuery ='SELECT CurrencyIsoCode FROM SVMXC__RMA_Shipment_Order__c WHERE Id IN :ShipOrderId'; 
                    rso = database.query(rsoQuery);
                    for(SVMXC__RMA_Shipment_Order__c r: rso)
                    {
                    IdToCurrencyIsoCodeMap.put(r.Id, string.valueOf(r.get('CurrencyIsoCode')));
                    
                }
                }

                for(SVMXC__RMA_Shipment_Line__c r: rmasl){//Loop Begins
                    rType = IdToRTNameMap.get(r.RecordTypeId);
            
                    if ((rType=='RMA') && (RMAPriceBookTrigger.toUpperCase() =='TRUE' && RunTriggerRMA.toUpperCase() == 'TRUE')){
                    //if ((rType=='RMA') && (RMAPriceBookTrigger.toUpperCase() =='TRUE')){ 
                        pbk = NameToPriceBook2Map.get(RMAPriceBook);
                    }
                    else{
                        if((rType=='Shipment') && (ShipmentPriceBookTrigger.toUpperCase() =='TRUE' && RunTriggerShpmnt.toUpperCase() == 'TRUE')) {
                        //if(ShipmentPriceBookTrigger.toUpperCase() =='TRUE') {
                            
                            pbk = NameToPriceBook2Map.get(ShipmentPriceBook);   
                                                    
                        }
                    }
                    if (pbk != null){
                        FinalProductId.add(r.SVMXC__Product__c);
                        FinalPricebookId.add(pbk.Id);
                        //Naveen:21/05
                        if(IdToCurrencyIsoCodeMap!=null && IdToCurrencyIsoCodeMap.size()>0)
                        {
                            FinalCurrencyCode.add(IdToCurrencyIsoCodeMap.get(r.SVMXC__RMA_Shipment_Order__c));
                            StringToRMASMap.put(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(r.SVMXC__RMA_Shipment_Order__c)), r);
                        }
                        else
                        {
                            StringToRMASMap.put(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id), r);
                        }
                        
                    }
                }//Loop Ends
                
                //Naveen:21/05
                string pblQuery;
                if(isMultiCurrency)
                {   
                    pblQuery = 'SELECT Name,UnitPrice,IsActive,Pricebook2Id,CurrencyIsoCode,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN : FinalPricebookId AND CurrencyIsoCode IN :FinalCurrencyCode AND Product2Id IN :FinalProductId AND IsActive = true';
                }else
                {
                    pblQuery = 'SELECT Name,UnitPrice,IsActive,Pricebook2Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN : FinalPricebookId  AND Product2Id IN :FinalProductId AND IsActive = true';                    
                }
                PriceBookList=database.query(pblQuery);
                
                for(PricebookEntry p: PriceBookList){
                    if(p.IsActive==true){
                        //Naveen:21/05
                        if(isMultiCurrency)
                            StringToPriceMap.put(String.valueOf(p.Product2Id)+String.valueOf(p.Pricebook2Id)+String.valueOf(p.get('CurrencyIsoCode')), String.valueOf(p.UnitPrice));
                        else
                            StringToPriceMap.put(String.valueOf(p.Product2Id)+String.valueOf(p.Pricebook2Id), String.valueOf(p.UnitPrice));
                    }
                }
                
                for(SVMXC__RMA_Shipment_Line__c r: rmasl){//Loop Begins (Updates the value)
                    rType = IdToRTNameMap.get(r.RecordTypeId);
    
                    if ((rType=='RMA') && (RMAPriceBookTrigger.toUpperCase() =='TRUE' && RunTriggerRMA.toUpperCase() == 'TRUE')){
                    //if ((rType=='RMA') && (RMAPriceBookTrigger.toUpperCase() =='TRUE')){ 
                        pbk = NameToPriceBook2Map.get(RMAPriceBook);
                    }
                    else{ 
                        if((rType=='Shipment') && (ShipmentPriceBookTrigger.toUpperCase() =='TRUE' && RunTriggerShpmnt.toUpperCase() == 'TRUE')) {
                        //if(ShipmentPriceBookTrigger.toUpperCase() =='TRUE') {
                            pbk = NameToPriceBook2Map.get(ShipmentPriceBook);
                            
                        }
                    }
                    
                    if (pbk != null && r.SVMXC__Use_Price_From_Pricebook__c){                       
                        if(isMultiCurrency)
                        {
                            
                            if(StringToRMASMap.get(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(r.SVMXC__RMA_Shipment_Order__c)))!=NULL && StringToPriceMap.get(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(r.SVMXC__RMA_Shipment_Order__c)))!=NULL)
                            {
                            r.SVMXC__Line_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id)+String.valueOf(IdToCurrencyIsoCodeMap.get(r.SVMXC__RMA_Shipment_Order__c))));
                            system.debug('SVMXC__Line_Price2__c'+r.SVMXC__Line_Price2__c);
                            }
                        }
                        else
                        {
                            if(StringToRMASMap.get(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id))!=NULL && StringToPriceMap.get(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id))!=NULL)
                            {
                            r.SVMXC__Line_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(r.SVMXC__Product__c)+String.valueOf(pbk.Id)));
                            system.debug('SVMXC__Line_Price2__csec'+r.SVMXC__Line_Price2__c);
                            }                       
                        }
                    }
                }//Loop Ends
            }
        }
    }

    global static void SVMXC_SetRMA_ShipmentLinePrice(SVMXC__RMA_Shipment_Line__c rmasl){
        isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        SVMXC.COMM_Utils_ManageSettings posettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstPORD001SettingID = new list<string>();
        lstPORD001SettingID.add('SET011');
        lstPORD001SettingID.add('SET017');
        
        list<string> lstPORD002SettingID = new list<string>();
        lstPORD002SettingID.add('SET011');
        lstPORD002SettingID.add('SET017');

        Map<String, String> RMASubModuleSettings = posettings.SVMX_getSettingList('PORD001', lstPORD001SettingID);
        Map<String, String> ShipmentSubModuleSettings = posettings.SVMX_getSettingList('PORD002', lstPORD002SettingID);
        String RMAPriceBook = RMASubModuleSettings.get('SET011'); //setting for default RMA Price Book
        String ShipmentPriceBook = ShipmentSubModuleSettings.get('SET011'); //setting for default Shipment Price Book
        String RMAPriceBookTrigger = RMASubModuleSettings.get('SET017'); //setting for default RMA Price Book trigger
        String ShipmentPriceBookTrigger = ShipmentSubModuleSettings.get('SET017'); //setting for default Shipment Price Book trigger
        Double UnitPrice=0.0;
        Integer SettingCount=0; 
        String ErrMsg='';
        rt = new RecordType();
        pbk = new Pricebook2();
        pbe = new PricebookEntry(); 
        GenErrMsg ='<br> This is a setup issue. Please report this error to ServiceMax Administrator.'; 
        SVMXC_ReSetErrorFlag();
        rt = SVMXC_GetRecordTypeFromId(rmasl.RecordTypeId);
        
        if (rt == null || rmasl.SVMXC__Product__c == null) { return; }
        
        if( (rmasl.SVMXC__Use_Price_From_Pricebook__c==true) && ( (RMAPriceBookTrigger.toUpperCase() =='TRUE') ||( ShipmentPriceBookTrigger.toUpperCase() =='TRUE'))){
            //set the currency of the line to the currency of the parent 
            SVMXC__RMA_Shipment_Order__c rso;
            if(isMultiCurrency)
            {
                string rsoQuery='SELECT CurrencyIsoCode FROM SVMXC__RMA_Shipment_Order__c WHERE Id =:rmasl.SVMXC__RMA_Shipment_Order__c';   
                rso = database.query(rsoQuery);
                rmasl.put('CurrencyIsoCode',rso.get('CurrencyIsoCode'));
            }
            product =[Select Id, Name from Product2 where Id=:rmasl.SVMXC__Product__c];
        
            if ( (rt.Name =='RMA') && (RMAPriceBookTrigger.toUpperCase() =='TRUE')){ 
                pbk = SVMXC_GetPricebook(RMAPriceBook);
                SVMXC_ValidateResult(rmasl);
            }
            else{
                if(ShipmentPriceBookTrigger.toUpperCase() =='TRUE'){
                    pbk = SVMXC_GetPricebook(ShipmentPriceBook);
                    SVMXC_ValidateResult(rmasl);
                }
            }
            
            if (pbk != null){
                try{
                    if(isMultiCurrency)
                    pbe = SVMXC_GetUnitPrice(pbk ,String.valueOf(rso.get('CurrencyIsoCode')),rmasl.SVMXC__Product__c );
                    else
                    pbe = SVMXC_GetUnitPrice(pbk ,Null,rmasl.SVMXC__Product__c );
                    SVMXC_ValidateResult(rmasl);
                    if (ErrorFlag == false){ 
                        rmasl.SVMXC__Line_Price2__c = pbe.UnitPrice;
                    }
                }
                catch(System.Exception qe ){
                    rmasl.addError(qe.getMessage()+GenErrMsg);
                }
            }
        }
    }

    global static PricebookEntry SVMXC_GetUnitPrice(Pricebook2 PriceBook , String CurrencyIsoCode, Id ProductId){ 
        isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        boolean IsActivePricebookEntry =false;
        String ErrMsg;
        CurrencyIsoCode = String.isNotBlank(CurrencyIsoCode) ? String.escapeSingleQuotes(CurrencyIsoCode) : CurrencyIsoCode; //#soqlInjectionFix
        try {
            List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
            String qry ;
            if(isMultiCurrency)
                qry = '  SELECT Name,UnitPrice,IsActive '+'  FROM PricebookEntry '+'  WHERE Pricebook2Id  =\''+PriceBook.Id+'\' '+'  AND CurrencyIsoCode =\''+CurrencyIsoCode+'\' '+'  AND Product2Id =\''+ProductId+'\' ';    
            else
                qry = '  SELECT Name,UnitPrice,IsActive '+'  FROM PricebookEntry '+'  WHERE Pricebook2Id  =\''+PriceBook.Id+'\' '+' AND Product2Id =\''+ProductId+'\' ';
            PricebookEntryList = Database.query(qry);
            if (PricebookEntryList.size()==0){
                if(isMultiCurrency)
                ErrMsg = ' No PriceBook Entry found for the Product '+product.Name+' and currency '+CurrencyIsoCode+'.';
                else
                ErrMsg = ' No PriceBook Entry found for the Product '+product.Name+'.';
                SVMXC_SetErrorText(ErrMsg); 
                return null;
            }           
            for ( PricebookEntry pbe2 :PricebookEntryList){ 
                if (pbe2.IsActive==true){ 
                    IsActivePricebookEntry =true;
                    return pbe2; 
                }
            } 
            if(IsActivePricebookEntry ==false){
                if(isMultiCurrency)
                ErrMsg = ' No Active PriceBook Entry found for the Product '+product.Name+' and currency '+CurrencyIsoCode+'.';
                else
                ErrMsg = ' No Active PriceBook Entry found for the Product '+product.Name+'.';
                SVMXC_SetErrorText(ErrMsg); 
            }
        }
        catch(System.Exception qe ){
            if(isMultiCurrency)
            ErrMsg = ' No PriceBook Entry found for the Product '+product.Name+' and currency '+CurrencyIsoCode+'.';
            else
            ErrMsg = ' No PriceBook Entry found for the Product '+product.Name+'.';
            SVMXC_SetErrorText(ErrMsg+'\n'+GenErrMsg); 
        }
        return null;
    }

    global static Pricebook2 SVMXC_GetPricebook(String PriceBookName){ 
        system.debug('PriceBookName'+PriceBookName);
        String ErrMsg='';
        boolean IsActivePriceBook =false;
        if (PriceBookName == null){
            ErrMsg = 'The default price book has not been configured.';
            SVMXC_SetErrorText(ErrMsg+GenErrMsg); 
            return null;
        } 
        try {
            for (Pricebook2 pbk2 : [SELECT Id,IsActive FROM Pricebook2 WHERE Name =:PriceBookName AND IsActive = true]){ 
                if (pbk2.IsActive==true){
                    IsActivePriceBook =true;
                    return pbk2; 
                }
            } 
            if (IsActivePriceBook ==false){
                ErrMsg = 'The default price book '+PriceBookName+' is not active.';
                SVMXC_SetErrorText(ErrMsg+GenErrMsg); 
            } 
        } 
        catch(System.Exception qe ){
            SVMXC_SetErrorText(ErrMsg+'<br>'+qe.getMessage()+GenErrMsg);
        }
        return null;
    }

    public static RecordType SVMXC_GetRecordTypeFromId(Id RecordTypeId){
        RecordType rt1;
        try {
            rt1 = [SELECT Name FROM RecordType WHERE Id = :RecordTypeId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        catch(System.Exception qe ){
            return null;
        }
        return rt1;
    } 

    public static String SVMXC_GetErrorText(){
        if (ErrorFlag)
            return ErrorText;
        else
            return '';
    }

    public static void SVMXC_SetErrorText(String Text){
        ErrorText =Text;
        ErrorFlag =true;
    }

    public static void SVMXC_ReSetErrorFlag(){
        ErrorFlag =false;
        ErrorText='';
    }

    public static void SVMXC_ValidateResult(SVMXC__Service_Order_Line__c svoline){ 
        if (ErrorFlag == true){
            //svoline.addError(SVMXC_GetErrorText());
            //System.debug(SVMXC_GetErrorText());
            //return false;
        }
        else{
        }
        //return true;
    } 

    public static void SVMXC_ValidateResult(SVMXC__RMA_Shipment_Line__c rmasline){
        if (ErrorFlag == true){
            //rmasline.addError(SVMXC_GetErrorText());
            //System.debug(SVMXC_GetErrorText());
            //return false;
        }
        else{
        }
        //return true;
    } 
    /*******************************************************************************************************************
                                            Method for retrieving Pricebook Entry
    *******************************************************************************************************************/
    global static PricebookEntry SVMXC_GetPricebookEntry(Pricebook2 PriceBook , String CurrencyIsoCode, Id ProductId){ 
        isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        if (  (PriceBook ==null)||  ( ProductId ==null)){return null;}
        PricebookEntry pbe2= new PricebookEntry();       
        
        try {
            string pbe2Query;
            string PBId = PriceBook.Id;
            if(isMultiCurrency)
                pbe2Query='SELECT Name,UnitPrice,IsActive,UseStandardPrice FROM PricebookEntry WHERE Pricebook2Id = :PBId AND CurrencyIsoCode = :CurrencyIsoCode AND Product2Id =:ProductId AND IsActive = true';
            else
                pbe2Query = 'SELECT Name,UnitPrice,IsActive,UseStandardPrice FROM PricebookEntry WHERE Pricebook2Id = :PBId AND Product2Id =:ProductId AND IsActive = true';
            
            pbe2 =database.query(pbe2Query);            
            if (pbe2!=null && pbe2.IsActive==true)
                return pbe2;
            else 
                return null;
            }
        catch(System.Exception qe ){
            return null;
        }
    }     
}