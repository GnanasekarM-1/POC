public with sharing class CONF_ManageProductReplacement 
{
    /************** All global variable with getter setter *******************/
    public String titleName = '';
    public String gettitleName(){return this.titleName;}
    public String ProdSelect;
    public String getProdSelect(){return this.ProdSelect;}
    public void setProdSelect(String index){this.ProdSelect = index;}
    public boolean IsRender = false;
    public boolean getIsRender(){return this.IsRender;}
    public boolean IsError = false;
    public boolean getIsError(){return this.IsError;}
    public boolean IsDetailError = false;
    public boolean getIsDetailError(){return this.IsDetailError;}
    public List<SelectOption> getPicklistOption()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('20','20'));
        options.add(new SelectOption('30','30'));
        options.add(new SelectOption('50','50'));
        return options;
    }
    
    public String pickValue = '';
    public String getpickValue(){return pickValue;}
    public void setpickValue(String pickValue){this.pickValue = pickValue;}
    public String pickValueForAvail = '';
    public String getpickValueForAvail(){return pickValueForAvail;}
    public void setpickValueForAvail(String strpickValue){this.pickValueForAvail = strpickValue;}
    public integer getProdLstSize(){return this.ProdLst.size();}
    public integer getAvailProdLstSize(){return this.AvailProdLst.size();}
    
    public String strSearchKeyword = null;
    public String getstrSearchKeyword(){return this.strSearchKeyword;}
    public void setstrSearchKeyword(String Keyword){this.strSearchKeyword = Keyword;}
    public String strSearchKeywordForAvail;
    public String getstrSearchKeywordForAvail(){return this.strSearchKeywordForAvail;}
    public void setstrSearchKeywordForAvail(String Keyword){this.strSearchKeywordForAvail = Keyword;}
    
    public list<Product2> ProdLst = new list<Product2>();
    public list<Product2> getProdLst(){return this.ProdLst;}
    public void setProdLst(list<Product2> ProdLst){this.ProdLst = ProdLst;}
    public list<Product2> AvailProdLst = new list<Product2>();
    public list<Product2> getAvailProdLst(){return this.AvailProdLst;}
    public void setAvailProdLst(list<Product2> ProdLst){this.AvailProdLst = ProdLst;}
    public list<Product2> TobeReplacProdLst = new list<Product2>();
    public list<Product2> getTobeReplacProdLst(){return this.TobeReplacProdLst;}
    public void setTobeReplacProdLst(list<Product2> ProdLst){this.TobeReplacProdLst = ProdLst;}
    public list<SVMXC__Product_Replacement__c> ReplacedProdLst = new list<SVMXC__Product_Replacement__c>();
    public list<SVMXC__Product_Replacement__c> getReplacedProdLst(){return this.ReplacedProdLst;}
    public void setReplacedProdLst(list<SVMXC__Product_Replacement__c> ProdLst){this.ReplacedProdLst = ProdLst;}
    public map<Id, Product2> MapIdProdAvail = new map<Id, Product2>();
    public List<Product2> ProductLst = new List<Product2>();
    public List<Product2> getProductLst(){return this.ProductLst;}
    
    public boolean IsListEmpty =false;
    public boolean getIsListEmpty()
    {
        if(TobeReplacProdLst.size() > 0)
            IsListEmpty = false;
        else
            IsListEmpty = true;
        return IsListEmpty;
    }
    
    /************** Constructor *******************/
    public CONF_ManageProductReplacement() {}
    
    /************** Search method for Product *******************/
    public PageReference ProdctSearch()
    {
        try
        {
            IsError = false;
            IsRender = false;
            String searchKeywordRefined = '';
            searchKeywordRefined = String.escapeSingleQuotes(strSearchKeyword);
            integer limitValue = integer.valueOf(pickValue);
            ProdLst = [Select SVMXC__Select__c, SVMXC__Replacement_Available__c, ProductCode, Name, IsActive, Description From Product2 where Name LIKE: '%' + searchKeywordRefined + '%' OR ProductCode LIKE: '%'+ searchKeywordRefined + '%'  Limit: limitValue];
            MapIdProdAvail.putAll(ProdLst);
            return null;
        }
        catch(exception ex)
        {
            IsError = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    /************** Search method for available replecement Product *******************/
    public PageReference AvailProdctSearch()
    {
        try
        {
            IsDetailError = false;
            integer limitValue = integer.valueOf(pickValueForAvail);
            list<Id> ProdIds = new list<Id>();
            ProdIds.add(ProdSelect);
            String searchKeywordRefined = '';
            searchKeywordRefined = String.escapeSingleQuotes(strSearchKeywordForAvail);
            ReplacedProdLst = [Select SVMXC__Base_Product__c, SVMXC__Order_Of_Preference__c, SVMXC__Replacement_Product__c From SVMXC__Product_Replacement__c where SVMXC__Base_Product__c =: ProdSelect order by SVMXC__Order_Of_Preference__c];
            
            for(SVMXC__Product_Replacement__c RProd : ReplacedProdLst)
                ProdIds.add(RProd.SVMXC__Replacement_Product__c);
            AvailProdLst.clear();
            AvailProdLst = [Select SVMXC__Select__c, SVMXC__Replacement_Available__c, ProductCode, Name, IsActive, Description From Product2 where Id NOT IN: ProdIds AND (Name LIKE: '%' + searchKeywordRefined + '%' OR ProductCode LIKE: '%'+ searchKeywordRefined + '%') Limit: limitValue ]; 
            MapIdProdAvail.putAll(AvailProdLst);
            return null;
        }
        catch(exception ex)
        {
            IsDetailError = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /************** Method to display list of avail & replaced product list *******************/
    public PageReference ProductReplacementAction()
    {
        IsRender = true;
        strSearchKeywordForAvail = null;
        Product2 TempProdObj = new Product2();
        TempProdObj = [Select ProductCode, Name From Product2 where Id =: ProdSelect];
        titleName =  getTag008() +' '+ TempProdObj.Name;
        
        ReplacedProdLst = [Select SVMXC__Base_Product__c, SVMXC__Order_Of_Preference__c, SVMXC__Replacement_Product__c, SVMXC__Replacement_Product__r.Name,SVMXC__Replacement_Product__r.ProductCode,SVMXC__Replacement_Product__r.SVMXC__Select__c From SVMXC__Product_Replacement__c where SVMXC__Base_Product__c =: ProdSelect order by SVMXC__Order_Of_Preference__c];
        
        list<Id> ProdIds = new list<Id>();
        for(SVMXC__Product_Replacement__c RProd : ReplacedProdLst)
        {
            ProdIds.add(RProd.SVMXC__Replacement_Product__c);
        }
        MapIdProdAvail.putAll([Select SVMXC__Select__c, ProductCode, Name, Id, IsActive From Product2 where Id IN: ProdIds]);
        AvailProdLst.clear();
        TobeReplacProdLst.clear();
        Product2 tempProd;
        for(SVMXC__Product_Replacement__c RProd : ReplacedProdLst)
        {
            tempProd = new Product2();
            tempProd = MapIdProdAvail.get(RProd.SVMXC__Replacement_Product__c);
            TobeReplacProdLst.add(tempProd); 
        }
        return null;
    }
    
    /************** Method to move product left *******************/
    public PageReference OnAddproduct()
    {
        try
        {
            IsDetailError = false;
            boolean IsSelected = false;
            if(AvailProdLst.size() > 0)
            {
                map<Id, Product2> TempMapAvail = new map<Id, Product2>();
                map<Id, Product2> TempMapReplaced = new map<Id, Product2>();
                for(Product2 TempProd : AvailProdLst)
                    TempMapAvail.put(TempProd.Id,TempProd);
                
                for(Product2 TempProd : TobeReplacProdLst)
                    TempMapReplaced.put(TempProd.Id,TempProd);
                
                for(Product2 TempProd : AvailProdLst)
                {
                    if(TempProd.SVMXC__Select__c)
                    {
                        IsSelected = true;
                        TempProd.SVMXC__Select__c = false;
                        TempMapReplaced.put(TempProd.Id,TempProd);
                        TempMapAvail.remove(TempProd.Id);
                    }
                }
                AvailProdLst.clear();
                TobeReplacProdLst.clear();
                AvailProdLst = TempMapAvail.values();
                TobeReplacProdLst = TempMapReplaced.values();
            }
            return null;
        }
        catch(exception e)
        {
            IsDetailError = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    /************** Method to move product right *******************/
    public PageReference OnRemProduct()
    {
        try
        {
            IsDetailError = false;
            boolean IsSelected = false;
            if(TobeReplacProdLst.size() > 0)
            {
                map<Id, Product2> TempMapAvail = new map<Id, Product2>();
                map<Id, Product2> TempMapReplaced = new map<Id, Product2>();
                for(Product2 TempProd : AvailProdLst)
                    TempMapAvail.put(TempProd.Id,TempProd);
                
                for(Product2 TempProd : TobeReplacProdLst)
                    TempMapReplaced.put(TempProd.Id,TempProd);
                
                for(Product2 TempProd : TobeReplacProdLst)
                {
                    if(TempProd.SVMXC__Select__c)
                    {
                        IsSelected = true;
                        TempProd.SVMXC__Select__c = false;
                        TempMapAvail.put(TempProd.Id,TempProd);
                        TempMapReplaced.remove(TempProd.Id);
                    }
                }
                AvailProdLst.clear();
                TobeReplacProdLst.clear();
                AvailProdLst = TempMapAvail.values();
                TobeReplacProdLst = TempMapReplaced.values();
            }
            return null;
        }
        catch(exception e)
        {
            IsDetailError = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    /************** Method to move product up *******************/
    public PageReference UpProduct()
    {
        try
        {
            IsDetailError = false;
            if(TobeReplacProdLst.size() > 1)
            {
                Product2 tempProd;
                boolean IsSelected = false;
                for(integer i=1; i<TobeReplacProdLst.size();i++)
                {
                    if(TobeReplacProdLst[i].SVMXC__Select__c)
                    {
                        IsSelected = true;
                        tempProd = new Product2();
                        tempProd = TobeReplacProdLst[i];
                        TobeReplacProdLst[i] = TobeReplacProdLst[i-1];
                        TobeReplacProdLst[i-1] = tempProd;
                    }
                }
            }
            else if(TobeReplacProdLst.size() > 0)
            {
                for(integer i=0; i<TobeReplacProdLst.size();i++)
                {
                    if(TobeReplacProdLst[i].SVMXC__Select__c)
                        TobeReplacProdLst[i].SVMXC__Select__c =false;
                }
            }
        }
        catch(exception e)
        {
            //IsDetailError = true;
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('Error:'+e.getMessage());
        }
        return null;
    }
    
    /************** Method to move product dowm *******************/
    public PageReference DownProduct()
    {
        try
        {
            IsDetailError = false;
            if(TobeReplacProdLst.size() > 1)
            {
                Product2 tempProd;
                boolean IsSelected = false;
                for(integer i=TobeReplacProdLst.size()-2; i>=0;i--)
                {
                    if(TobeReplacProdLst[i].SVMXC__Select__c)
                    {
                        IsSelected = true;
                        tempProd = new Product2();
                        tempProd = TobeReplacProdLst[i+1];
                        TobeReplacProdLst[i+1] = TobeReplacProdLst[i];
                        TobeReplacProdLst[i] = tempProd;
                    }
                }
            }
            else if(TobeReplacProdLst.size() > 0)
            {
                for(integer i=0; i<TobeReplacProdLst.size();i++)
                {
                    if(TobeReplacProdLst[i].SVMXC__Select__c)
                        TobeReplacProdLst[i].SVMXC__Select__c = false;
                }
            }
        }
        catch(exception e)
        {
            //IsDetailError = true;
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('Error:'+e.getMessage());
        }
        return null;
    }
    
    /*********************** BackToSetupHome Method ***********************/
    public PageReference BackToSetupHome() 
    {
        //PageReference pRef = new PageReference('/apex/CONF_SetupHome');  
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/CONF_SetupHome';
        }
        PageReference pRef = new PageReference(url); 
        return pRef;
    }
    
    /************** Cancel Method *******************/
    public void CancelAction()
    {
        titleName = '';
        ProductReplacementAction();
        AvailProdLst.clear();
    }
    
    /************** Method to save Replacement prod for selected product *******************/
    list<SVMXC__Product_Replacement__c> lstReplacementObj;
    public PageReference ConformReplacement()
    {
        try
        {
            IsError = false;
            if(ProdSelect != null && ProdSelect.length() > 0)
            {
                if(ReplacedProdLst != null && ReplacedProdLst.size() > 0)
                {
                    //delete ReplacedProdLst;
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Product_Replacement__c')){
                        delete ReplacedProdLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        IsError = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                    ReplacedProdLst.clear();
                }
                if(ProdLst.size() > 0)
                {
                    for(Product2 ProdObj : ProdLst)
                    {
                        if(ProdObj.SVMXC__Select__c)
                            ProdObj.SVMXC__Select__c = false;
                    }
                }
                if(TobeReplacProdLst != null && TobeReplacProdLst.size() > 0)
                {
                    SVMXC__Product_Replacement__c TempReplacementObj;
                    lstReplacementObj = new list<SVMXC__Product_Replacement__c>();
                    for(integer i=0; i<TobeReplacProdLst.size(); i++)
                    {
                        TempReplacementObj = new SVMXC__Product_Replacement__c();
                        TempReplacementObj.SVMXC__Base_Product__c = ProdSelect;
                        TempReplacementObj.SVMXC__Replacement_Product__c = TobeReplacProdLst[i].Id;
                        TempReplacementObj.SVMXC__Order_Of_Preference__c = i+1;
                        lstReplacementObj.add(TempReplacementObj); 
                    }
                    //upsert lstReplacementObj;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstReplacementObj, COMM_SecurityUtils.Access.Upsertable)){
                        upsert lstReplacementObj; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        IsError = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                    
                    Product2 tempProd = MapIdProdAvail.get(ProdSelect);
                    tempProd.SVMXC__Replacement_Available__c = true;
                    //upsert tempProd;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(tempProd, COMM_SecurityUtils.Access.Upsertable)){
                        upsert tempProd; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        IsError = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                    IsRender = false;
                    IsError = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTag013()));
                }
                else
                {
                    Product2 tempProd = MapIdProdAvail.get(ProdSelect);
                    tempProd.SVMXC__Replacement_Available__c = false;
                    //upsert tempProd;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(tempProd, COMM_SecurityUtils.Access.Upsertable)){
                        upsert tempProd; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        IsError = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                    IsRender = false;
                }
            }
            else
            {
                IsError = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag014()));
            }
            return null;
        }
        catch(exception e)
        {
            IsError = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    /************** Custom tags *******************/
    public String getTag001(){return System.Label.CONF029_TAG001;}                          //{ return 'Processing...' ;}
    public String getTag002(){return System.Label.CONF029_TAG002;}                          //{ return 'Product Subsitutes';}
    public String getTag003(){return System.Label.CONF029_TAG003;}                          //{ return 'Save' ;}
    public String getTag004(){return System.Label.CONF029_TAG004;}                          //{ return 'Cancel' ;}
    public String getTag005(){return System.Label.CONF029_TAG005;}                          //{ return 'Product Name';}
    public String getTag006(){return System.Label.CONF029_TAG006;}                          //{ return 'Product Code';}
    public String getTag007(){return System.Label.CONF029_TAG007;}                          //{ return 'Replacement Available';}
    public String getTag008(){return System.Label.CONF029_TAG008;}                          //{ return 'Define Replacements for: ';}
    public String getTag009(){return System.Label.CONF029_TAG009;}                          //{ return 'Available Product(s)';} 
    public String getTag010(){return System.Label.CONF029_TAG010;}                          //{ return 'No Replacement available';}
    public String getTag011(){ return System.Label.CONF029_TAG011;}                         //{ return 'Please select product';}
    public String getTag012(){return System.Label.CONF029_TAG012;}                          //{ return 'No product available' ;}
    public String getTag013(){return System.Label.CONF029_TAG013;}                          //{ return 'Replacement Done' ;}
    public String getTag014(){ return System.Label.CONF029_TAG014;}                          //{return 'Please select product first.';}
    public String getTag015(){return System.Label.CONF029_TAG015;}                          //{ return 'Replacement Product(s)' ;}
    public String getTag016(){return System.Label.CONF029_TAG016;}                          //{ return 'Go!';}
    public String getTag017(){ return System.Label.CONF029_TAG017;}                          //{return 'Back To Setup Home';} 
    public String getTag018(){ return System.Label.CONF029_TAG018;}                          //{return 'Show';} 
    public String getTag019(){ return System.Label.CONF029_TAG019;}                         //{return 'Edit' ;}
    public String getTag020(){ return System.Label.COMM001_TAG036;}                         //{retrun 'Add';}
    public String getTag021(){ return System.Label.COMM001_TAG037;}                         //{retrun 'Remove';}
    public String getTag022(){ return System.Label.COMM001_TAG061;}                         //{retrun 'Up';}
    public String getTag023(){ return System.Label.COMM001_TAG062;}                         //{retrun 'Down';}
    public string getHLPURL() {return system.label.CONF029_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    
}