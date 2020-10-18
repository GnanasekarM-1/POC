/* Security Scanned */
public with sharing class WORD_AutoReceiveWOReqRec {
    public String SVOId;
    public Boolean updateRec = false;
    public Boolean DisplaySave = false;
    public Boolean getDisplaySave(){ return DisplaySave;}
    public List<SVMXC__Service_Order_Line__c> SvoLineList = new List<SVMXC__Service_Order_Line__c>(); 
    public WORD_AutoReceiveWOReqRec()
    {
        SVOId = System.currentPageReference().getParameters().get('SVOId');
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType Rtypedef = [select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        Id RTypeId = Rtypedef.Id;
        String SvoLineSoql = 'SELECT Id, RecordTypeId, SVMXC__Requested_Quantity2__c, SVMXC__Requested_Street__c, SVMXC__Requested_City__c, SVMXC__Requested_State__c,SVMXC__Requested_Zip__c, SVMXC__Requested_Country__c, SVMXC__Received_Street__c,SVMXC__Received_City__c, SVMXC__Received_State__c,SVMXC__Received_Zip__c, SVMXC__Received_Country__c,SVMXC__Received_Quantity2__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :SVOId AND RecordTypeId = :RTypeId';
        SvoLineList = database.query(SvoLineSoql);
        if(SvoLineList.size() > 0 && SvoLineList != null)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Info,getTAG004(),''));//'Clicking on save will update the Work detail records ',''));
            for(SVMXC__Service_Order_Line__c SvoLineRec : SvoLineList)
            {
            SvoLineRec.SVMXC__Received_Quantity2__c = SvoLineRec.SVMXC__Requested_Quantity2__c;
            //SvoLineRec.SVMXC__Received_Location__c = SvoLineRec.SVMXC__Requested_Location__c;
            SvoLineRec.SVMXC__Received_Street__c = SvoLineRec.SVMXC__Requested_Street__c;
            SvoLineRec.SVMXC__Received_City__c = SvoLineRec.SVMXC__Requested_City__c;
            SvoLineRec.SVMXC__Received_State__c = SvoLineRec.SVMXC__Requested_State__c;
            SvoLineRec.SVMXC__Received_Zip__c = SvoLineRec.SVMXC__Requested_Zip__c;
            SvoLineRec.SVMXC__Received_Country__c = SvoLineRec.SVMXC__Requested_Country__c;
            SvoLineRec.SVMXC__Received_Quantity2__c = SvoLineRec.SVMXC__Requested_Quantity2__c;
            SvoLineRec.SVMXC__Date_Received__c = system.today();
            }
            DisplaySave = true;
            updateRec = true;
        }
        else 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG005(),''));//'There are no open parts request lines to process.','')); 
    }
    
    public pagereference PerformUpdate(){
        if(updateRec)
        {
             if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SvoLineList, COMM_SecurityUtils.Access.Updateable)){
                 //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                     update SvoLineList;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
           
        }
            PageReference newPage = new PageReference('/' + SVOId);
        return newPage;
    }
    public PageReference BackToRecord()
    {
        PageReference newPage = new PageReference('/' + SVOId);
        return newPage;
    }
    public String getTAG001(){ return system.label.WORD018_TAG001;}
    public String getTAG002(){ return system.label.WORD018_TAG002;}
    public String getTAG003(){ return system.label.WORD018_TAG003;}
    public String getTAG004(){ return system.label.WORD018_TAG004;}
    public String getTAG005(){ return system.label.WORD018_TAG005;}
}