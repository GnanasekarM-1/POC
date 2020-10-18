/* Security Scanned */
public with sharing class PORD_CancelShipmentOrder {
    
    Public string ShpId = System.currentPageReference().getParameters().get('ShpId');
    public List<SVMXC__RMA_Shipment_Order__c> ShpQuery = new List<SVMXC__RMA_Shipment_Order__c>();
    public List<SVMXC__RMA_Shipment_Line__c> ShpLineQuery = new List<SVMXC__RMA_Shipment_Line__c>();
    public Boolean Invalid = false;
    public String ResultMsg;
    public Boolean Displaysave = false;
    public Boolean updateRec = false;
    public Boolean getDisplaysave(){ return Displaysave;}
    public PORD_CancelShipmentOrder()
    {
        String Shp = 'SELECT SVMXC__Order_Status__c FROM SVMXC__RMA_Shipment_Order__c WHERE Id =:ShpId';
        ShpQuery = Database.query(Shp);
        if(ShpQuery.size()>0){
        if(ShpQuery[0].SVMXC__Order_Status__c=='Closed')
        {
            //ResultMsg = getTAG004();//'This Shipment Order has been Closed already';
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG004(),''));
            updateRec = false;
            //setResultMsg(ResultMsg);
            DisplaySave = false;
            DisplayMessage();
        }
        else if(ShpQuery[0].SVMXC__Order_Status__c=='Canceled')
        {
            //ResultMsg = getTAG005();//'This Shipment Order has been Canceled already';
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG005(),''));
            updateRec = false;
            //setResultMsg(ResultMsg);
            DisplaySave = false;
            DisplayMessage();
        }
        else
            ProcessResult();
        }
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG006(),''));//'Shipment records do not exist',''));
    }
    
    public void ProcessResult()
    {
    String ShpLine = 'SELECT Id, SVMXC__Line_Status__c, SVMXC__Actual_Quantity2__c FROM SVMXC__RMA_Shipment_Line__c WHERE SVMXC__RMA_Shipment_Order__c = :ShpId';
    ShpLineQuery = Database.query(ShpLine);
    for(SVMXC__RMA_Shipment_Line__c ShpLineRecord : ShpLineQuery)
    {
        if (ShpLineRecord.SVMXC__Line_Status__c == 'Completed' || ShpLineRecord.SVMXC__Line_Status__c == 'Canceled' || ShpLineRecord.SVMXC__Actual_Quantity2__c > 0)
        {
            Invalid = true;
            break;
        }
        else
        {
            ShpLineRecord.SVMXC__Line_Status__c = 'Canceled';
            ShpLineRecord.SVMXC__Canceled_On__c = system.now();
            ShpLineRecord.SVMXC__Canceled_By__c = UserInfo.getUserId();
            updateRec = true;
        }
    }
    if(Invalid)
    {
        //ResultMsg = getTAG007();//'Some items in this shipment order have been processed partially. && Please open the pending shipment lines to cancel individually.';
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),''));
        //setResultMsg(ResultMsg);
        DisplaySave = false;
        DisplayMessage();
    }
    else
    {
        DisplaySave = true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG008()));//'All Shipment Records will be updated '));
        ShpQuery[0].SVMXC__Order_Status__c = 'Canceled';
        ShpQuery[0].SVMXC__Canceled_On__c = system.now();
        ShpQuery[0].SVMXC__Canceled_By__c = UserInfo.getUserId();
        //ResultMsg = 'All Shipment Orders cancelled successfully';
        //setResultMsg(ResultMsg);
        
    }
    }
    public String getResultMessage(){
        return ResultMsg;
    }
    public void setResultMsg(String val){
    ResultMsg = val;
    }
    public pagereference PerformUpdate()
    {
        try{
            //update ShpQuery;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ShpQuery, COMM_SecurityUtils.Access.Updateable)){
                update ShpQuery; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;
            }
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getmessage(),'')); 
        }
        if(updateRec){            
            try{
                //update ShpLineQuery;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ShpLineQuery, COMM_SecurityUtils.Access.Updateable)){
                    update ShpLineQuery; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    return null;
                }
            }
            catch(exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getmessage(),'')); 
            }
        }
        PageReference newPage = new PageReference('/' + ShpId);
        return newPage;
    }
    public PageReference BackToRecord()
    {
        PageReference newPage = new PageReference('/' + ShpId);
        return newPage;
    }
     public void DisplayMessage()
    {
        if(getResultMessage()!=null && getResultMessage()!='')
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Info,getResultMessage(),''));
    }
    
    public String getTAG001(){ return system.label.PORD010_TAG001;}
    public String getTAG002(){ return system.label.PORD010_TAG002;}
    public String getTAG003(){ return system.label.PORD010_TAG003;}
    public String getTAG004(){ return system.label.PORD010_TAG004;}
    public String getTAG005(){ return system.label.PORD010_TAG005;}
    public String getTAG006(){ return system.label.PORD010_TAG006;}
    public String getTAG007(){ return system.label.PORD010_TAG007;}
    public String getTAG008(){ return system.label.PORD010_TAG008;}
}