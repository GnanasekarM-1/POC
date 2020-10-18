public with sharing class CONF_SetupLocations
{
    public List<SVMXC__Site__c> lstLocation = new List<SVMXC__Site__c>();
    public List<SVMXC__Site__c> lstParentLocation = new List<SVMXC__Site__c>();
    public List<SVMXC__Site__c> lstChildLocation = new List<SVMXC__Site__c>();
    public List<SVMXC__Site__c> lstDipotChildLoc = new List<SVMXC__Site__c>();
    public integer delIndex{get; set;}
    public List<depotChildLocWrapper> LstDepotChildLocWrap = new List<depotChildLocWrapper>();
    public List<depotChildLocWrapper> getLstDepotChildLocWrap(){return this.LstDepotChildLocWrap;}
    public void setLstDepotChildLocWrap(List<depotChildLocWrapper> xwrap){this.LstDepotChildLocWrap = xwrap;}
    
    public List<SVMXC__Site__c> lstDipotChildLocToDisplay = new List<SVMXC__Site__c>();
    public List<SVMXC__Site__c> getlstDipotChildLocToDisplay(){return this.lstDipotChildLocToDisplay;}
    public void setlstDipotChildLocToDisplay(List<SVMXC__Site__c> lst){ this.lstDipotChildLocToDisplay = lst;}
    
    public List<SVMXC__Site__c> lstLocToDelete = new List<SVMXC__Site__c>();
    
    public List<selectOption> lstLocType = new List<selectOption>();
    public List<selectOption> getlstLocType(){return this.lstLocType;}
    public List<selectOption> lstFunction = new List<selectOption>();
    public List<selectOption> getlstFunction(){return this.lstFunction;}
    
    public integer lstDipotChildLocSize{get;set;}
    public Map<String, String> mapLocToParentLoc = new Map<String, String>();
    public string JSONString{get;set;}
    public string locID{get;set;}
    public string locNameToDisplay{get;set;}
    public string selectedNodeForTree{get;set;}
    public string selectedFunc{get;set;}
    public SVMXC__Site__c locToDisplay{get; set;}
    public SVMXC__Site__c newLocToAdd{get; set;}
    public SVMXC__Site__c newDepot{get; set;}
    public boolean renderDetail{get; set;}
    public boolean renderDepotChild{get; set;}
    public boolean renderOutboundBtn{get; set;}
    public boolean renderCancelBtn{get; set;}
    public boolean renderDepotParentBtns{get; set;}
    public boolean renderAccountLookup{get; set;}
    RecordType RTDepotParent;
    RecordType RTDepot;
    RecordType RTDepotChild;
    integer i = 0;
    boolean validate;
    string tagToDisplay;
    
    public CONF_SetupLocations()
    {
        lstDipotChildLocSize = 0;
        renderDetail = false;
        renderDepotChild = false;
        renderOutboundBtn = false;
        renderDepotParentBtns = false;
        renderAccountLookup = false;
        renderCancelBtn = false;
        locNameToDisplay='';
        lstLocType.clear();
        //Neeraj(April-16th-2012): Commented the hard coded picklist values, displaying values by getPicklistValues() methods.
        /*
        lstLocType.add(new selectOption(getTAG027(), getTAG027()));
        lstLocType.add(new selectOption('Internal', getTAG028()));
        lstLocType.add(new selectOption('Customer', getTAG029()));
        lstLocType.add(new selectOption('Supplier', getTAG030()));
        */
        Schema.DescribeFieldResult locationTypeDescReslt = SVMXC__Site__c.SVMXC__Location_Type__c.getDescribe();
        List<Schema.PicklistEntry> locationType = locationTypeDescReslt.getPicklistValues();
        for(Schema.PicklistEntry currentLocationType: locationType)
        {
            lstLocType.add(new selectOption(currentLocationType.getValue(),currentLocationType.getLabel()));
        }               
        
        lstFunction.clear();
        lstFunction.add(new selectOption('--None--', getTAG027()));
        lstFunction.add(new selectOption('Is Default Delivery', getTAG032()));
        lstFunction.add(new selectOption('Is Delivery Location', getTAG033()));
        //lstFunction.add(new selectOption('Is Partner Record', getTAG034()));
        lstFunction.add(new selectOption('Is Receiving Location', getTAG035()));
        lstFunction.add(new selectOption('Is Staging Location', getTAG036()));
        //lstFunction.add(new selectOption('Is Stocking Location', getTAG037()));
        
        RTDepotParent = [select id, Name from RecordType where Name = 'Depot Parent'and SobjectType='SVMXC__Site__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RTDepot = [select id, Name from RecordType where Name = 'Depot'and SobjectType='SVMXC__Site__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RTDepotChild = [select id, Name from RecordType where Name = 'Depot Child'and SobjectType='SVMXC__Site__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        paintingTree();
    }
    
    public void paintingTree()
    {
        lstLocation.clear();
        lstLocation = [select Id, Name, RecordTypeId, SVMXC__Account__c, SVMXC__Parent__c , SVMXC__Location_Type__c from SVMXC__Site__c where (RecordType.Name = 'Depot Parent' OR RecordType.Name = 'Depot') order by Name];
        system.debug('lstLocation: ' + lstLocation);
        lstParentLocation.clear();
        lstChildLocation.clear();
        mapLocToParentLoc.clear();
        if(lstLocation != null && lstLocation.size() >0)
        {
            for(SVMXC__Site__c loc : lstLocation)
            {
                if(loc.RecordTypeId == RTDepotParent.Id && loc.SVMXC__Parent__c == null)
                    lstParentLocation.add(loc);
                else if(loc.SVMXC__Parent__c != null)
                {
                    lstChildLocation.add(loc);
                    mapLocToParentLoc.put(loc.Id, loc.SVMXC__Parent__c);
                }
            }
        }
        
        if(lstParentLocation != null && lstParentLocation.size() >0)
            createJSONString(lstParentLocation);
        system.debug('JSON String: ' + JSONString);
    }
    
    public void createJSONString(List<SVMXC__Site__c> lstParentLocation)
    {
        integer j = 0;
        JSONString = '';
        JSONString = '[';
        for(SVMXC__Site__c loc : lstParentLocation)
        {
            if(j == 0)
                JSONString += '{"title": "';
            else
                JSONString += ',{"title": "';
            JSONString += loc.Name.escapeHtml4() + '", "ID": "' + loc.Id + '"';
            i = 0;
            addChilds(loc);
            JSONString += '}';
            j++;
        }
        JSONString += ']';
    }
    
    public void addChilds(SVMXC__Site__c loc)
    {
        for(SVMXC__Site__c locChild : lstChildLocation)
        {
            if(locChild.SVMXC__Parent__c == loc.Id)
            {
                if(i == 0)
                    JSONString += ', "children" : [ { "title": "' + locChild.Name.escapeHtml4() + '", "ID": "' + locChild.Id + '"';
                else
                    JSONString += ',{ "title": "' + locChild.Name.escapeHtml4() + '", "ID": "' + locChild.Id + '"';
                if(locChild.RecordTypeId == RTDepot.Id)
                {
                    JSONString += ', "isFolder": "true"';
                }
                if(locChild.RecordTypeId == RTDepotParent.Id)
                {
                    i = 0;
                    addChilds(locChild);
                }
                JSONString += '}';
                i++;
            }
        }
        if(i > 0)
            JSONString += ']';
    }
    
    public void QuerySelLoc()
    {
        renderDetail = true;
        if(locID != null && locID.length() != 0)
        {
          locToDisplay = [select Id, Name, RecordTypeId, SVMXC__Account__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Parent__c , SVMXC__Location_Type__c from SVMXC__Site__c where Id =: locID];
          locNameToDisplay = locToDisplay.Name;
          tagToDisplay = getTAG005() + ' ' + locNameToDisplay;
          
          if(locToDisplay.RecordTypeId == RTDepot.Id)
          {
              renderDepotChild = true;
              renderOutboundBtn = true;
              renderDepotParentBtns = false;
              renderCancelBtn = false;
              if(locToDisplay.SVMXC__Location_Type__c == 'Supplier' || locToDisplay.SVMXC__Location_Type__c == 'Customer')
                  renderAccountLookup = true;
              else
                  renderAccountLookup = false;
              queryLstDepotChild();
          }
          else if(locToDisplay.RecordTypeId == RTDepotParent.Id)
          {
              renderDepotParentBtns = true;
              renderDepotChild = false;
              renderOutboundBtn = false;
              renderAccountLookup = false;
              renderCancelBtn = false;
          }
        }
        else
        {
          renderDetail = false;
          renderCancelBtn = false;
        }
    }
    
    public void onChngLocType()
    {
        if(locToDisplay.SVMXC__Location_Type__c == 'Supplier' || locToDisplay.SVMXC__Location_Type__c == 'Customer')
            renderAccountLookup = true;
        else
            renderAccountLookup = false;
    }
    //Neeraj(March-14th): Added new method to enable/disable Is Good loaction checkbox.
    public integer LstIndex {get;set;}
    public void IsGoodLocAction()
    {
        try
        {
            if(LstDepotChildLocWrap[LstIndex-1].selFunction != 'Is Delivery Location' || LstDepotChildLocWrap[LstIndex-1].selFunction != 'Is Default Delivery')
                LstDepotChildLocWrap[LstIndex-1].IsGoodLoc = false;
        }
        catch(exception ex){}//Handling not reqired.
        
    }
    
    public void queryLstDepotChild()
    {
        lstDipotChildLoc.clear();
        lstDipotChildLoc = [select Id, Name, RecordTypeId, SVMXC__IsDelivery_Location__c, SVMXC__IsDefault_Delivery__c , SVMXC__IsGood_Stock__c, SVMXC__IsStaging_Location__c, SVMXC__Parent__c, SVMXC__IsPartnerRecord__c, SVMXC__Stocking_Location__c, SVMXC__IsReceiving_Location__c , SVMXC__Location_Type__c from SVMXC__Site__c where RecordType.Name = 'Depot Child' and SVMXC__Parent__c =: locID];
        
        LstDepotChildLocWrap.clear();
        if(lstDipotChildLoc != null && lstDipotChildLoc.size() > 0)
        {
            for(integer l=1; l<=lstDipotChildLoc.size(); l++)
            {
                depotChildLocWrapper depotChild = new depotChildLocWrapper(lstDipotChildLoc[l-1], l);
                LstDepotChildLocWrap.add(depotChild);
            }
        }
        lstDipotChildLocSize = LstDepotChildLocWrap.size();
        if(lstDipotChildLocSize == 0)
            addDepotChild();
    }
    
    public void addTopLevel()
    {
        renderDepotParentBtns = false;
        renderDetail = true;
        renderDepotChild = false;
        renderOutboundBtn = false;
        renderAccountLookup = false;
        renderCancelBtn = true;
        //locNameToDisplay = getTAG038();
        locToDisplay = new SVMXC__Site__c();
        locToDisplay.RecordTypeId = RTDepotParent.Id;
        locToDisplay.SVMXC__Parent__c = null;
        tagToDisplay = getTAG052();
    }
    
    //------------------------------------------- Method To Cancel --------------------------------------------------------------  
    public pageReference cancel()
    {
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        //pageReference pageref1 = Page.CONF_SetupHome;
        PageReference pageref1 = new PageReference(url);
        return pageref1;
    }
    
    //----------------------------------- Method To Save and Close ---------------------------------------------------
    public pageReference saveClose()
    {
        validate = true;
        save();
        if(validate == true)
        {
            pageReference pageref1 = Page.CONF_SetupHome ;
            return pageref1;
        }
        else
            return null;
    }

    //------------------------------------------- Method To Quick Save ------------------------------------------- 
    public pageReference quickSave()
    {
        validate = true;
        save();
        if(validate == true)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG023(),''));
            selectedNodeForTree = locToDisplay.Id;
            //System.currentPageReference().getParameters().put('?SVMX_SelectedNode=', selectedNodeForTree);
            paintingTree();
            return null;
        }
        else
            return null;
    }
    
    //------------------------------------------- Method To Save actually ------------------------------------------- 
    public void save()
    {
        renderCancelBtn = false;
        validation();
        lstDipotChildLocToDisplay.clear();
        if(validate == true)
        {
            if(lstLocToDelete != null && lstLocToDelete.size() >0){
                if(!COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Site__c' ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                delete lstLocToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                lstLocToDelete.clear();
            }
            
            if(locToDisplay != null)
            {
                //upsert locToDisplay;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(locToDisplay, COMM_SecurityUtils.Access.Upsertable)){
                    upsert locToDisplay; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                if(LstDepotChildLocWrap != null && LstDepotChildLocWrap.size() >0)
                {
                    for(depotChildLocWrapper tempWrap : LstDepotChildLocWrap)
                    {
                        if(tempWrap.Loc != null && tempWrap.Loc.Name != null && tempWrap.Loc.Name != '')
                        {
                            SVMXC__Site__c tempLoc = new SVMXC__Site__c();
                            tempLoc = tempWrap.Loc;
                            //if(tempWrap.IsGoodLoc == true) // Neeraj(Jan-31st-2012): Changed if condition to handle the defect 003478.
                            if(tempWrap.IsGoodLoc == true)
                            {
                                tempLoc.SVMXC__IsGood_Stock__c = true;
                                tempWrap.IsGoodLoc = true;
                            }
                            else
                            {
                                tempLoc.SVMXC__IsGood_Stock__c = false;
                                tempWrap.IsGoodLoc = false;
                            }
                            if(tempWrap.selFunction == 'Is Default Delivery')
                            {
                                tempLoc.SVMXC__IsDelivery_Location__c = true;
                                tempLoc.SVMXC__IsDefault_Delivery__c = true;
                                tempLoc.SVMXC__IsStaging_Location__c = false;
                                tempLoc.SVMXC__IsReceiving_Location__c = false;
                            }
                            else if(tempWrap.selFunction == 'Is Delivery Location')
                            {
                                tempLoc.SVMXC__IsDelivery_Location__c = true;
                                tempLoc.SVMXC__IsDefault_Delivery__c = false;
                                tempLoc.SVMXC__IsStaging_Location__c = false;
                                tempLoc.SVMXC__IsReceiving_Location__c = false;
                            }
                            else if(tempWrap.selFunction == 'Is Staging Location')
                            {
                                tempLoc.SVMXC__IsStaging_Location__c = true;
                                tempLoc.SVMXC__IsDelivery_Location__c = false;
                                tempLoc.SVMXC__IsDefault_Delivery__c = false;
                                tempLoc.SVMXC__IsReceiving_Location__c = false;
                            }
                            /* else if(tempWrap.selFunction == 'Is Partner Record')
                                tempLoc.SVMXC__IsPartnerRecord__c = true; */
                            else if(tempWrap.selFunction == 'Is Receiving Location')
                            {
                                tempLoc.SVMXC__IsReceiving_Location__c = true;
                                tempLoc.SVMXC__IsDelivery_Location__c = false;
                                tempLoc.SVMXC__IsDefault_Delivery__c = false;
                                tempLoc.SVMXC__IsStaging_Location__c = false;
                            }
                            //else if(tempWrap.selFunction == 'Is Stocking Location') 
                            
                            tempLoc.SVMXC__Stocking_Location__c = true;
                            tempLoc.SVMXC__Parent__c = locToDisplay.Id;
                            lstDipotChildLocToDisplay.add(tempLoc);
                        }
                    }
                }
                if(locToDisplay.RecordTypeId == RTDepot.Id && lstDipotChildLocToDisplay != null && lstDipotChildLocToDisplay.size() >0){
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(lstDipotChildLocToDisplay, COMM_SecurityUtils.Access.Upsertable)){
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                    upsert lstDipotChildLocToDisplay; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
            }
        }
    }
    
    public void validation()
    {
        integer noOfDefaultLoc = 0;
        if(locToDisplay != null && (locToDisplay.Name == '' || locToDisplay.Name == null))
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG043(),''));
        }
        
        if(LstDepotChildLocWrap != null && LstDepotChildLocWrap.size() >0)
        {
            for(depotChildLocWrapper tempWrap : LstDepotChildLocWrap)
            {
                if(tempWrap.Loc != null && (tempWrap.Loc.Name == null || tempWrap.Loc.Name == ''))
                {
                    validate = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG043(),''));
                    //tempWrap.Loc.addError('Enter Location Name');
                }
                if(tempWrap.selFunction == 'Is Default Delivery')
                {
                    noOfDefaultLoc++;
                    /* if(noOfDefaultLoc > 1)
                    {
                        tempWrap.Loc.addError('Edit this location');
                    } */
                }
                if(tempWrap.selFunction == '--None--')
                {
                    validate = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG048(),''));
                }
            }
            if(noOfDefaultLoc > 1)
            {
                validate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG047(),''));
            }
        }
    }
    
    public void deleteDepotChild()
    {
        List<depotChildLocWrapper> tempLstDipotChildLocToDisplay = new List<depotChildLocWrapper>();
        for(depotChildLocWrapper tempChild : LstDepotChildLocWrap)
        {
            if(tempChild.index != integer.valueOf(delIndex))
                tempLstDipotChildLocToDisplay.add(tempChild);
            else
            {
                SVMXC__Site__c tempLoc = new SVMXC__Site__c();
                tempLoc = tempChild.Loc;
                if(tempLoc.Id != null)
                    lstLocToDelete.add(tempLoc);
            }
        }
        LstDepotChildLocWrap.clear();
        LstDepotChildLocWrap.addAll(tempLstDipotChildLocToDisplay);
        for(integer l=1; l<=LstDepotChildLocWrap.size() ; l++)
            LstDepotChildLocWrap[l-1].index = l;
        lstDipotChildLocSize = LstDepotChildLocWrap.size(); 
    }
    
    public void addDepotChild()
    {
        SVMXC__Site__c newDepotChild = new SVMXC__Site__c();
        newDepotChild.RecordTypeId = RTDepotChild.Id;
        newDepotChild.SVMXC__City__c = locToDisplay.SVMXC__City__c;
        newDepotChild.SVMXC__Country__c = locToDisplay.SVMXC__Country__c;
        newDepotChild.SVMXC__State__c = locToDisplay.SVMXC__State__c;
        newDepotChild.SVMXC__Street__c = locToDisplay.SVMXC__Street__c;
        newDepotChild.SVMXC__Zip__c = locToDisplay.SVMXC__Zip__c;
        newDepotChild.SVMXC__Latitude__c = locToDisplay.SVMXC__Latitude__c;
        newDepotChild.SVMXC__Longitude__c = locToDisplay.SVMXC__Longitude__c;
        newDepotChild.SVMXC__Location_Type__c = locToDisplay.SVMXC__Location_Type__c;
        newDepotChild.SVMXC__Account__c = locToDisplay.SVMXC__Account__c;
        integer index = lstDipotChildLocSize + 1;
        depotChildLocWrapper tempWrap = new depotChildLocWrapper(newDepotChild,index);
        LstDepotChildLocWrap.add(tempWrap);
        lstDipotChildLocSize = LstDepotChildLocWrap.size();
    }
    
    public void addLevel()
    {
        renderDepotParentBtns = false;
        renderCancelBtn = true;
        renderDepotChild = false;
        renderAccountLookup = false;
        renderOutboundBtn = false;
        //locNameToDisplay = getTAG039();
        newLocToAdd = new SVMXC__Site__c();
        newLocToAdd = locToDisplay;
        locToDisplay = new SVMXC__Site__c();
        locToDisplay.RecordTypeId = RTDepotParent.Id;
        locToDisplay.SVMXC__Parent__c = newLocToAdd.Id;
        LstDepotChildLocWrap = new List<depotChildLocWrapper>();
        lstDipotChildLocToDisplay = new List<SVMXC__Site__c>();
        lstDipotChildLocSize = LstDepotChildLocWrap.size();
        tagToDisplay = getTAG050() + ' ' + locNameToDisplay;
    }
    
    public void addDepot()
    {
        renderDepotChild = true;
        renderDepotParentBtns = false;
        renderOutboundBtn = false;
        renderCancelBtn = true;
        //locNameToDisplay = getTAG040();
        newLocToAdd = new SVMXC__Site__c();
        newLocToAdd = locToDisplay;
        locToDisplay = new SVMXC__Site__c();
        locToDisplay.RecordTypeId = RTDepot.Id;
        locToDisplay.SVMXC__Parent__c = newLocToAdd.Id;
        LstDepotChildLocWrap = new List<depotChildLocWrapper>();
        lstDipotChildLocToDisplay = new List<SVMXC__Site__c>();
        lstDipotChildLocSize = LstDepotChildLocWrap.size();
        addDepotChild();
        tagToDisplay = getTAG051() + ' ' + locNameToDisplay;
    }
    
    public String getValidateAddress()
    {
        String url;
        url = '/apex/COMM_ValidateAddress?objID=' + locToDisplay.Id + '&objName=SVMXC__Site__c&street=SVMXC__Street__c&city=SVMXC__City__c&state=SVMXC__State__c&country=SVMXC__Country__c&zip=SVMXC__Zip__c&latitude=SVMXC__Latitude__c&longitude=SVMXC__Longitude__c&returnUrl=/apex/CONF_InventoryOrg';
        return url;
    }
    
    public pageReference outboundRouting()
    {
        string SVMX_RecordId = locToDisplay.Id;
        String loc = '/apex/Conf_ManageOutboundRouting?SVMX_RecordId='+SVMX_RecordId +'&SVMX_RetURL=/apex/CONF_SetupLocations';
        PageReference pr = new PageReference(loc);
        return pr;
    }
    
    public pageReference deliveryRule()
    {
      string SVMX_RecordId = locToDisplay.Id;
        String loc = '/apex/Conf_ManageDeliveryRules?SVMX_RecordId='+SVMX_RecordId +'&SVMX_RetURL=/apex/CONF_SetupLocations';
        PageReference pr = new PageReference(loc);
        return pr;
    }
    
    public class depotChildLocWrapper
    {
        public SVMXC__Site__c Loc = new SVMXC__Site__c();
        public SVMXC__Site__c getLoc(){return this.Loc;}
        public void setLoc(SVMXC__Site__c L){this.Loc = L;}
        public string selFunction{get; set;}
        public integer index{get; set;}
        public boolean IsGoodLoc{get; set;}
        
        public depotChildLocWrapper()
        {}
        
        public depotChildLocWrapper(SVMXC__Site__c selLoc, integer seq)
        {
            this.Loc = selLoc;
            this.index = seq;
            
            if(selLoc.IsGood_Stock__c == true)
                this.IsGoodLoc = true;
            
            if(selLoc.SVMXC__IsDefault_Delivery__c == true)
                this.selFunction = 'Is Default Delivery';
            else if(selLoc.SVMXC__IsDelivery_Location__c == true && selLoc.SVMXC__IsDefault_Delivery__c == false)
                this.selFunction = 'Is Delivery Location';
            /* else if(selLoc.SVMXC__IsPartnerRecord__c == true)
                this.selFunction = 'Is Partner Record'; */
            else if(selLoc.SVMXC__IsReceiving_Location__c == true)
                this.selFunction = 'Is Receiving Location';
            else if(selLoc.SVMXC__IsStaging_Location__c == true)
                this.selFunction = 'Is Staging Location';
            /* else if(selLoc.SVMXC__Stocking_Location__c == true)
                this.selFunction = 'Is Stocking Location'; */
            else
                this.selFunction = '--None--';
        }
    }
    
    public void deleteLoc()
    {
        List<SVMXC__Site__c> tempLocLst = [select id, Name from SVMXC__Site__c where SVMXC__Parent__c =: locToDisplay.Id];
        if(tempLocLst == null || tempLocLst.size() == 0)
        {
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Site__c' ) ) {
                
                delete locToDisplay; //SDL-SVMX-DELETE-FLS-ENFORCED
                renderDetail = false;
                renderDepotChild = false;
                renderDepotParentBtns = false;
                renderAccountLookup = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG045(),''));
                paintingTree();
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG046(),''));
        }
    }
    
    public void cancelToNew()
    {
        QuerySelLoc();
    }
    
    //--------------------------------------------- Getter for custom Labels ------------------------------------------------------
    public String getTAG001() {return system.label.CONF027_TAG001;}//'Configure ServiceMax Locations'
    public String getTAG002() {return system.label.CONF027_TAG002;}//'Quick Save'
    public String getTAG003() {return system.label.CONF027_TAG003;}//'Save and Close'
    public String getTAG004() {return system.label.CONF027_TAG004;}//'Cancel'
    public String getTAG005() {return system.label.CONF027_TAG006;}//
    
    public String getTAG007() {return system.label.CONF027_TAG007;}//'Location/Level Name'
    public String getTAG008() {return system.label.CONF027_TAG008;}//'Location Type'
    public String getTAG009() {return system.label.CONF027_TAG009;}//'Account'
    public String getTAG010() {return system.label.CONF027_TAG041;}//'Are you sure? Deleting a depot location removes location references and impacts APL processes. This change is not recoverable.'
    public String getTAG011() {return system.label.CONF027_TAG010;}//'Street'
    public String getTAG012() {return system.label.CONF027_TAG011;}//'Zip'
    public String getTAG013() {return system.label.CONF027_TAG012;}//'Country'
    public String getTAG014() {return system.label.CONF027_TAG013;}//'City'
    public String getTAG015() {return system.label.CONF027_TAG014;}//'Latitude'
    public String getTAG016() {return system.label.CONF027_TAG015;}//'State'
    public String getTAG017() {return system.label.CONF027_TAG016;}//'Longitude'
    public String getTAG018() {return system.label.CONF027_TAG017 + ' ' + locNameToDisplay;}//'Locations In '
    public String getTAG019() {return system.label.CONF027_TAG018;}//'Location Name'
    public String getTAG020() {return system.label.CONF027_TAG019;}//'Processing...'
    public String getTAG021() {return system.label.CONF027_TAG020;}//'Function'
    public String getTAG022() {return system.label.CONF027_TAG021;}//'Good Stock Location'
    public String getTAG023() {return system.label.CONF027_TAG022;}//'Saved successfully'
    public String getTAG024() {return system.label.CONF027_TAG023;}//'Add Level'
    public String getTAG025() {return system.label.CONF027_TAG024;}//'Add Depot'
    public String getTAG026() {return system.label.CONF027_TAG025;}//'Outbound Routing'
    public String getTAG027() {return system.label.CONF027_TAG026;}//'--None--'
    public String getTAG028() {return system.label.CONF027_TAG027;}//'Internal'
    public String getTAG029() {return system.label.CONF027_TAG028;}//'Customer'
    public String getTAG030() {return system.label.CONF027_TAG029;}//'Supplier'
    public String getTAG031() {return system.label.CONF027_TAG030;}//'Add Top Level'
    public String getTAG032() {return system.label.CONF027_TAG031;}//'Default Delivery'
    public String getTAG033() {return system.label.CONF027_TAG032;}//'Delivery Location'
    public String getTAG034() {return system.label.CONF027_TAG037;}//'Back To Setup Home'
    public String getTAG035() {return system.label.CONF027_TAG033;}//'Receiving Location'
    public String getTAG036() {return system.label.CONF027_TAG034;}//'Staging Location'
    //public String getTAG037() {return 'Stocking Location';}//system.label.
    //public String getTAG038() {return 'New Top Level';}//system.label.
    //public String getTAG039() {return 'New Level';}//system.label.
    //public String getTAG040() {return 'New Depot';}//system.label.
    public String getTAG041() {return system.label.CONF027_TAG038;}//'Validate Address'
    public String getTAG042() {return system.label.CONF027_TAG039;}//'Delete This Location'
    public String getTAG043() {return system.label.CONF027_TAG040;}//'Please Enter Valid Location Name.'
    //public String getTAG044() {return system.label.CONF027_TAG043;}
    public String getTAG045() {return system.label.CONF027_TAG042;}//'Location deleted successfully.'
    public String getTAG046() {return system.label.CONF027_TAG043;}//'Location having Child Locations and hence can not be deleted. Please delete childs first in case to delete this location.'
    public String getTAG047() {return system.label.CONF027_TAG022;}//'Only one location can be a default location.'
    public String getTAG048() {return system.label.CONF027_TAG045;}//'Please select a Function for the location.'
    
    public String getTAG006() {return tagToDisplay;}//system.label. locNameToDisplay
    //public string getTAG049() {return 'Attributes of ';}
    public string getTAG050() {return system.label.CONF027_TAG005;} // 'Adding a Level to '
    public string getTAG051() {return system.label.CONF027_TAG035;} // 'Adding Depot in '
    public string getTAG052() {return system.label.CONF027_TAG036;} // 'Adding Top Level Location'
    public string getTAG053() {return system.label.CONF027_TAG044;} // 'Delivery Rule'
    public string getTAG054() {return system.label.COMM002_TAG032;} // 'Add'
    public string getTAG055() {return system.label.COMM002_TAG033;} // 'Delete'
    public string getHLPURL() {return system.label.CONF027_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}