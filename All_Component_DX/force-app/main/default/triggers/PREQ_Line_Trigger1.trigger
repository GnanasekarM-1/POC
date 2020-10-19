trigger PREQ_Line_Trigger1 on SVMXC__Parts_Request_Line__c (before insert,before update)
{
    //Added by Nidhi as part of BAC-5157, Disabling Trigger based on setting on Trigger Controls page.
    if(!CONF_TriggerControl.isTriggerEnabled('SVMXC__Parts_Request_Line__c',userInfo.getUserId(),userInfo.getProfileId())){
        System.debug(Logginglevel.WARN,'PREQ_Line_Trigger1 execution is skipped.');
        return;
    }
    public boolean RunTrigger = false;
    list<Id> ProdIds = new list<Id>();
    for(SVMXC__Parts_Request_Line__c R : Trigger.new)
    {
        if(R.SVMXC__Use_Price_From_Pricebook__c == true)
        {
            RunTrigger = true;
        }       
    }
    public boolean isMultiCurrency=userinfo.isMultiCurrencyOrganization();
    if(RunTrigger)
    { 
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        List<String> sets = new List<String>();
        List<SVMXC__Parts_Request__c> partReqLst = new List<SVMXC__Parts_Request__c>();
        List<Pricebook2> priceLst = new List<Pricebook2>();
        Pricebook2 pricebk = new Pricebook2();
        List<PricebookEntry> PriceBookEntryList = new List<PricebookEntry>();
        Map<String, Pricebook2> PriceBookMap =  new Map<String, Pricebook2>(); 
        Map<Id, String> CurrencyIsoCodeMap =  new Map<Id, String>();
        Set<Id> PRIdList = new Set<Id>();
        Set<Id> FinalProductId = new Set<Id>();
        Set<Id> FinalPricebookId = new Set<Id>();
        Set<String> FinalCurrencyCode = new Set<String>();
        Map<String, SVMXC__Parts_Request_Line__c> StringToPartReqMap =  new Map<String, SVMXC__Parts_Request_Line__c>();
        Map<String, String> StringToPriceMap =  new Map<String, String>();
        list<Id> priceLstIds = new list<Id>();
        sets.add('SET003');
        sets.add('SET004');
        Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('PREQ002', sets );
        String PRPriceBook = AllSubModuleSettings.get('SET003'); //setting to get Parts Request Price Book
        String PRPriceBookTrigger = AllSubModuleSettings.get('SET004'); //setting for Parts Request Price Book Trigger
        
        for(SVMXC__Parts_Request_Line__c R : Trigger.new)
        {
            PRIdList.add(R.SVMXC__Parts_Request__c);
            ProdIds.add(R.Id);  
        }
        if(PRPriceBook != null && PRPriceBookTrigger.toUpperCase() == 'TRUE')
        {
            if(isMultiCurrency)
            {
                string strpartReqLst='SELECT CurrencyIsoCode FROM SVMXC__Parts_Request__c where Id IN:PRIdList';
                partReqLst = database.query(strpartReqLst);
                for(SVMXC__Parts_Request__c p:partReqLst)
                {
                    CurrencyIsoCodeMap.put(p.Id,  string.valueOf(p.get('CurrencyIsoCode')));
                }
            }               
            priceLst = [SELECT Id,Name,IsActive FROM Pricebook2 where Name =:PRPriceBook];
            
            for(Pricebook2 p:priceLst)
            {
                if(p.IsActive==true)
                    PriceBookMap.put(p.Name,p);
            }
            for(SVMXC__Parts_Request_Line__c R : Trigger.new)
            { 
                if(isMultiCurrency)
                    R.put('CurrencyIsoCode' , string.valueOf(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c)));

                pricebk = PriceBookMap.get(PRPriceBook);
                if (pricebk != null)
                {
                    FinalProductId.add(R.SVMXC__Product__c);
                    FinalPricebookId.add(pricebk.Id);
                    if(isMultiCurrency)
                    {
                        FinalCurrencyCode.add(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c));
                        StringToPartReqMap.put(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id) + String.valueOf(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c)), R);
                    }
                    else
                        StringToPartReqMap.put(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id), R);
                }
            }
            string PriceBookEntryListQuery;
            if(isMultiCurrency)
                PriceBookEntryListQuery = 'SELECT Name,UnitPrice,IsActive,Pricebook2Id,CurrencyIsoCode,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN:FinalPricebookId AND CurrencyIsoCode IN :FinalCurrencyCode AND Product2Id IN :FinalProductId ';
            else
                PriceBookEntryListQuery = 'SELECT Name,UnitPrice,IsActive,Pricebook2Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN:FinalPricebookId AND Product2Id IN :FinalProductId ';
            
            PriceBookEntryList = database.query(PriceBookEntryListQuery);
            
            for(PricebookEntry p: PriceBookEntryList)
            {
                if(p.IsActive==true)
                {
                    if(isMultiCurrency)
                        StringToPriceMap.put(String.valueOf(p.Product2Id) + String.valueOf(p.Pricebook2Id) + String.valueOf(p.get('CurrencyIsoCode')), String.valueOf(p.UnitPrice));
                    else
                        StringToPriceMap.put(String.valueOf(p.Product2Id) + String.valueOf(p.Pricebook2Id), String.valueOf(p.UnitPrice));
                }
            }
            for(SVMXC__Parts_Request_Line__c R : Trigger.new)
            { 
                if(isMultiCurrency)
                {
                    R.put('CurrencyIsoCode' ,  string.valueOf(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c)));
                }
                pricebk = PriceBookMap.get(PRPriceBook);
                if(pricebk != null && R.SVMXC__Use_Price_From_Pricebook__c)
                {
                    if(isMultiCurrency)
                    {
                        if(StringToPartReqMap.get(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id) + String.valueOf(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c))) != NULL && StringToPriceMap.get(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id) + String.valueOf(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c))) != NULL)
                        {
                            R.SVMXC__Unit_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id) + String.valueOf(CurrencyIsoCodeMap.get(R.SVMXC__Parts_Request__c))));
                        }
                    }
                    else
                    {
                        if(StringToPartReqMap.get(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id)) != NULL && StringToPriceMap.get(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id)) != NULL)
                        {
                            R.SVMXC__Unit_Price2__c = decimal.valueOf(StringToPriceMap.get(String.valueOf(R.SVMXC__Product__c) + String.valueOf(pricebk.Id)));
                        }
                    }
                }
            } 
        }           
    }       
}