/* Security Scanned */
public with sharing class WORD_CancelWOReqRec{

    public string SVOId = System.currentPageReference().getParameters().get('SVOId');
    public string SVOLineId = System.currentPageReference().getParameters().get('SVOLId');
    public List<SVMXC__Service_Order__c> SvoQuery = new List<SVMXC__Service_Order__c>();
    public List<SVMXC__Service_Order_Line__c> SvoLineQuery = new List<SVMXC__Service_Order_Line__c>();
    public Boolean Invalid = false;
    public String ResultMsg;
    public Boolean DisplaySave = false;
    public Boolean updateRec = false;
    public Boolean getDisplaySave(){ return DisplaySave;}
    
    public WORD_CancelWOReqRec()
    {
        String Svo = 'SELECT SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id =:SVOId';
        SvoQuery = Database.query(Svo);
        if(SvoQuery.size()>0)
        {
            if(SvoQuery[0].SVMXC__Order_Status__c=='Closed')
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG004()));//'This Work Order has been closed already. Cannot cancel parts requests.';
                updateRec = false;
                DisplaySave = false;
            }
            else if(SvoQuery[0].SVMXC__Order_Status__c=='Canceled')
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG005()));//'This Work Order has been canceled already.';
                updateRec = false;
                DisplaySave = false;
            }
            else
                {
                    if(SVOLineId==NULL || SVOLineId=='')
                    ProcessResultAllWOLines();
                    else if((SVOLineId != NULL && SVOLineId != '') && (SVOId != NULL && SVOId != ''))
                    ProcessResultWOLine();
                }
        }
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG006(),''));//'Work Order record does not exist',''));
    }
    
    public void ProcessResultAllWOLines()
    {
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        Id svoRtypeid = SvoRtype.Id;
        String SvoLine = 'SELECT Id, SVMXC__Quantity_Shipment_Initiated2__c, SVMXC__Quantity_Shipped2__c, SVMXC__Received_Quantity2__c, SVMXC__Line_Status__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :SVOId AND RecordTypeId = :svoRtypeid';
        SvoLineQuery = Database.query(SvoLine);
        for(SVMXC__Service_Order_Line__c SvoLineRecord : SvoLineQuery)
        {
            if (SvoLineRecord.SVMXC__Line_Status__c == 'Completed' || SvoLineRecord.SVMXC__Line_Status__c == 'Canceled' || SvoLineRecord.SVMXC__Quantity_Shipment_Initiated2__c > 0 || SvoLineRecord.SVMXC__Received_Quantity2__c > 0 || SvoLineRecord.SVMXC__Quantity_Shipped2__c > 0)
            {
                Invalid = true;
                break;
            }
            else
            {
                SvoLineRecord.SVMXC__Line_Status__c = 'Canceled';
                SvoLineRecord.SVMXC__Canceled_On__c = system.now();
                SvoLineRecord.SVMXC__Canceled_By__c = UserInfo.getUserId();
                updateRec = true;
            }
        }
        if(Invalid)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007()));//'This part request has been processed partially. && Cannot cancel.';
            DisplaySave = false;
        }
        else
        {
            DisplaySave = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG008()));//'All Shipment Records will be updated '));
        }
    }
    
    public void ProcessResultWOLine()
    {
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        Id svoRtypeid = SvoRtype.Id;
        String SvoLine = 'SELECT Id, SVMXC__Quantity_Shipment_Initiated2__c, SVMXC__Quantity_Shipped2__c, SVMXC__Received_Quantity2__c, SVMXC__Line_Status__c FROM SVMXC__Service_Order_Line__c WHERE ID = :SVOLineId AND RecordTypeId = :svoRtypeid AND SVMXC__Service_Order__c =:SVOId';
        SvoLineQuery = Database.query(SvoLine);
        if(SvoLineQuery.size()==0 || SvoLineQuery.size()==null)
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG006(),''));//'Work detail record do not exist',''));
        else
        {
            if (SvoLineQuery[0].SVMXC__Line_Status__c == 'Completed' || SvoLineQuery[0].SVMXC__Line_Status__c == 'Canceled' || SvoLineQuery[0].SVMXC__Quantity_Shipment_Initiated2__c > 0 || SvoLineQuery[0].SVMXC__Received_Quantity2__c > 0 || SvoLineQuery[0].SVMXC__Quantity_Shipped2__c > 0)
            {
                Invalid = true;
            }
            else
            {
                SvoLineQuery[0].SVMXC__Line_Status__c = 'Canceled';
                SvoLineQuery[0].SVMXC__Canceled_On__c = system.now();
                SvoLineQuery[0].SVMXC__Canceled_By__c = UserInfo.getUserId();
                updateRec = true;
            }
            if(Invalid)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG009()));//'This part request has been processed partially. Cannot cancel.';   
                DisplaySave = false;
            }
            else
            {
                DisplaySave = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG010()));//'Click on Save to cancel the parts request.'));
            }
        }
    }
    
    public pagereference PerformUpdate(){
        if(updateRec)
        {
            try
            {
                //update SvoLineQuery;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SvoLineQuery, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    update SvoLineQuery;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getmessage(),'')); 
            }
        }
        PageReference newPage;
        
        if(SVOLineId==NULL || SVOLineId=='')
            newPage = new PageReference('/' + SVOId);
        else if((SVOLineId != NULL && SVOLineId != '') && (SVOId != NULL && SVOId != ''))
            newPage = new PageReference('/' + SVOLineId);

        return newPage;
    }

    public PageReference BackToRecord()
    {
        PageReference newPage;

        if(SVOLineId==NULL || SVOLineId=='')
            newPage = new PageReference('/' + SVOId);
        else if((SVOLineId != NULL && SVOLineId != '') && (SVOId != NULL && SVOId != ''))
            newPage = new PageReference('/' + SVOLineId);

        return newPage;
    }
    public String getTAG001(){ return system.label.WORD019_TAG001;}
    public String getTAG002(){ return system.label.WORD019_TAG002;}
    public String getTAG003(){ return system.label.WORD019_TAG003;}
    public String getTAG004(){ return system.label.WORD019_TAG004;}
    public String getTAG005(){ return system.label.WORD019_TAG005;}
    public String getTAG006(){ return system.label.WORD019_TAG006;}
    public String getTAG007(){ return system.label.WORD019_TAG007;}
    public String getTAG008(){ return system.label.WORD019_TAG008;}
    public String getTAG009(){ return system.label.WORD019_TAG009;}
    public String getTAG010(){ return system.label.WORD019_TAG010;}
}