/* Security Scanned */
public with sharing class PREQ_CancelPartsRequest {
    
    Public string PrId = System.currentPageReference().getParameters().get('PrId');
    public SVMXC__Parts_Request__c PrQuery = new SVMXC__Parts_Request__c();
    public List<SVMXC__Parts_Request_Line__c> PrLineQuery = new List<SVMXC__Parts_Request_Line__c>();
    public Boolean Invalid = false;
    public String ResultMsg;
    public Boolean DisplaySave = true;
    public Boolean updateRec = false;
    public Boolean getDisplaySave(){ return DisplaySave;}
    public PREQ_CancelPartsRequest()
    {
        String PRsoql = 'SELECT SVMXC__Status__c FROM SVMXC__Parts_Request__c WHERE Id = :PrId';
        system.debug('PRID'+PrId);
        PrQuery = Database.query(PRsoql);
        if(PrQuery.SVMXC__Status__c=='Completed')
        {
            //ResultMsg = getTAG004();//'This Shipment Order has been Completed already';
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG004()));
            updateRec = false;
            DisplaySave = false;
            //setResultMsg(ResultMsg);
            DisplayMessage();
        }
        else if(PrQuery.SVMXC__Status__c=='Canceled')
        {
            //ResultMsg = getTAG005();//'This Shipment Order has been Canceled already';
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG005()));
            updateRec = false;
            DisplaySave = false;
            //setResultMsg(ResultMsg);
            DisplayMessage();
        }
        else
            ProcessResult();
    }
    
    public void ProcessResult()
    {
    String PrSoql1 = 'SELECT Id, SVMXC__Quantity_Shipment_Initiated2__c, SVMXC__Quantity_Shipped2__c,SVMXC__Quantity_Received2__c, SVMXC__Line_Status__c FROM SVMXC__Parts_Request_Line__c WHERE SVMXC__Parts_Request__c = :PrId';
    PrLineQuery = Database.query(PrSoql1);
    for(SVMXC__Parts_Request_Line__c PrRecord : PrLineQuery)
    {
        if (PrRecord.SVMXC__Line_Status__c == 'Completed' || PrRecord.SVMXC__Quantity_Shipment_Initiated2__c > 0 || PrRecord.SVMXC__Quantity_Received2__c > 0 || PrRecord.SVMXC__Quantity_Shipped2__c > 0 )
        {
            Invalid = true;
            break;
        }
        else
        {
            PrRecord.SVMXC__Line_Status__c = 'Canceled';
            PrRecord.SVMXC__Canceled_On__c = system.now();
            PrRecord.SVMXC__Canceled_By__c = UserInfo.getUserId();
            updateRec = true;
        } 
    }
    if(Invalid)
    {
        //ResultMsg = getTAG006();//'Please open the pending shipment lines to cancel individually.';
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG006()));
        //setResultMsg(ResultMsg);
        DisplaySave = false;
        DisplayMessage();
    }
    else
    {
        DisplaySave = true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG007()));//'All Parts Request Lines will be updated '));
        PrQuery.SVMXC__Status__c = 'Canceled';
        PrQuery.SVMXC__Canceled_On__c = system.now();
        PrQuery.SVMXC__Canceled_By__c = UserInfo.getUserId();
        //ResultMsg = 'All parts request cancelled successfully';
        setResultMsg(ResultMsg);
    }
    
    }
    public String getResultMessage(){
        return ResultMsg;
    }
    public void setResultMsg(String val){
    ResultMsg = val;
    }
    public Pagereference PerformUpdate(){
        if(updateRec)
        {
            try
            {
                //update PrQuery;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(PrQuery, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update PrQuery;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getmessage(),'')); 
            }
            try
            {
                //update PrLineQuery;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(PrLineQuery, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update PrLineQuery;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getmessage(),''));
            }
        }
        PageReference newPage = new PageReference('/' + PrId);
        return newPage;
    }
    public PageReference BackToRecord()
    {
        PageReference newPage = new PageReference('/' + PrId);
        return newPage;
    }
    
    public void DisplayMessage()
    {
    if(getResultMessage()!=null && getResultMessage()!='')
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Info,getResultMessage(),'')); 
    }
    
    public String getTAG001(){ return system.label.PREQ006_TAG001;}
    public String getTAG002(){ return system.label.PREQ006_TAG002;}
    public String getTAG003(){ return system.label.PREQ006_TAG003;}
    public String getTAG004(){ return system.label.PREQ006_TAG004;}
    public String getTAG005(){ return system.label.PREQ006_TAG005;}
    public String getTAG006(){ return system.label.PREQ006_TAG006;}
    public String getTAG007(){ return system.label.PREQ006_TAG007;}
    public String getTAG008(){ return system.label.PREQ006_TAG008;}
    public String getHLPURL(){ return system.label.PREQ006_HLPURL;}
}