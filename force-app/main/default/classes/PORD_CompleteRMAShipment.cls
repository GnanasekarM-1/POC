/* Security Scanned */
public with sharing class PORD_CompleteRMAShipment {
    
    SVMXC__RMA_Shipment_Order__c RMAShipRec = new SVMXC__RMA_Shipment_Order__c();
    SVMXC__RMA_Shipment_Order__c ShipmentRec = new SVMXC__RMA_Shipment_Order__c();
    list<SVMXC__RMA_Shipment_Line__c> ListShipmentLines = new list<SVMXC__RMA_Shipment_Line__c>();
    SVMXC__RMA_Shipment_Order__c RMARec = new SVMXC__RMA_Shipment_Order__c();
    list<SVMXC__RMA_Shipment_Line__c> ListRMALines = new list<SVMXC__RMA_Shipment_Line__c>();
    boolean DisableCommit = false;
    public boolean getDisableCommit() {return this.DisableCommit;}
    
    string displayImage = '';
    public string getdisplayImage() {return this.displayImage;}
    
    public PORD_CompleteRMAShipment(){      
        Id RecId = System.currentPageReference().getParameters().get('RecId');
        RMAShipRec = [select RecordTypeId from SVMXC__RMA_Shipment_Order__c where Id=:RecId];
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType RecTyp = [select Name, Id from RecordType where Id=:RMAShipRec.RecordTypeId];
         
        if(RecTyp.Name == 'RMA'){
            SVMXC_CompleteRMA(RecId);
        }
        else if(RecTyp.Name == 'Shipment'){
            SVMXC_CompleteShipment(RecId);
        }           
    }  
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
    public String getTAG001() {return system.label.PORD011_TAG001;}
    public String getTAG002() {return system.label.PORD011_TAG002;}
    public String getTAG003() {return system.label.PORD011_TAG003;}
    public String getTAG004() {return system.label.PORD011_TAG004;}
    public String getTAG005() {return system.label.PORD011_TAG005;}
    public String getTAG006() {return system.label.PORD011_TAG006;}
    public String getTAG007() {return system.label.PORD011_TAG007;}
    public String getTAG008() {return system.label.PORD011_TAG008;}
    public String getTAG009() {return system.label.PORD011_TAG009;}
    public String getTAG010() {return system.label.PORD011_TAG010;}
    public String getTAG011() {return system.label.PORD011_TAG011;}
    public String getTAG012() {return system.label.PORD011_TAG012;}
    public String getTAG013() {return system.label.PORD011_TAG013;}
    public String getTAG014() {return system.label.PORD011_TAG014;}
    //public String getTAG015() {return system.label.PORD011_TAG015;}
    public String getHLPURL() {return system.label.PORD011_HLPURL;}
    
    
    /*public SVMXC.COMM_Utils_ManageTags comTagUtils = new SVMXC.COMM_Utils_ManageTags();
    public Map<String, String> mapSVMXTags = comTagUtils.SVMX_getTagList('PORD012');
    
    public String getHLPURL() {return mapSVMXTags.containskey('HLPURL')?mapSVMXTags.get('HLPURL')+ 'PORD012':'' ;}
    public String getTAG010() {return mapSVMXTags.containsKey('TAG010')?mapSVMXTags.get('TAG010') : 'Complete RMA Shipment Help';}
    public String getTAG001() {return mapSVMXTags.containsKey('TAG001')?mapSVMXTags.get('TAG001') : 'Cancel';}
    public String getTAG002() {return mapSVMXTags.containsKey('TAG002')?mapSVMXTags.get('TAG002') : 'This RMA is Closed.';}
    public String getTAG003() {return mapSVMXTags.containsKey('TAG003')?mapSVMXTags.get('TAG003') : 'This RMA is Canceled. Cannot complete receipts.';}
    public String getTAG004() {return mapSVMXTags.containsKey('TAG004')?mapSVMXTags.get('TAG004') : 'There are no Open lines in this Shipment Order';}
    public String getTAG005() {return mapSVMXTags.containsKey('TAG005')?mapSVMXTags.get('TAG005') : 'RMA Lines updated';}
    public String getTAG006() {return mapSVMXTags.containsKey('TAG006')?mapSVMXTags.get('TAG006') : 'This Shipment Order is already closed';}
    public String getTAG007() {return mapSVMXTags.containsKey('TAG007')?mapSVMXTags.get('TAG007') : 'This Shipment Order is Canceled. Cannot complete Shipments.';}
    public String getTAG008() {return mapSVMXTags.containsKey('TAG008')?mapSVMXTags.get('TAG008') : 'There are no Open lines in this Shipment Order.';}
    public String getTAG009() {return mapSVMXTags.containsKey('TAG009')?mapSVMXTags.get('TAG009') : 'Shipment Lines updated';}
    public String getTAG010() {return mapSVMXTags.containsKey('TAG010')?mapSVMXTags.get('TAG010') : 'Save';}
    public String getTAG011() {return mapSVMXTags.containsKey('TAG011')?mapSVMXTags.get('TAG011') : 'Processing';}
    
    */  
    
    // RMA Lines Update Method
    public void SVMXC_CompleteRMA(Id RecId) {
        displayImage = 'none';      
        integer CompleteLines = 0;      
        
        RMARec = [SELECT Id, SVMXC__Order_Status__c,SVMXC__Service_Engineer__c, SVMXC__Source_Location__c ,SVMXC__Warehouse__c FROM SVMXC__RMA_Shipment_Order__c WHERE Id=:RecId]; 
        
        if(RMARec.SVMXC__Order_Status__c=='Closed'){
            DisableCommit = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG004()));//getTAG002()));
        }
        else if(RMARec.SVMXC__Order_Status__c=='Canceled'){
            DisableCommit = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG010()));//getTAG003()));
        }
        else{
            
            ListRMALines = [SELECT id, SVMXC__Line_Status__c, SVMXC__Expected_Quantity2__c,SVMXC__Actual_Receipt_Date__c, SVMXC__Actual_Quantity2__c,SVMXC__Returned_Condition__c, SVMXC__Ship_Location__c,SVMXC__Warehouse__c FROM SVMXC__RMA_Shipment_Line__c where SVMXC__RMA_Shipment_Order__c =: RMARec.Id and (SVMXC__Line_Status__c != 'Completed' or SVMXC__Line_Status__c != 'Canceled')];
            system.debug('RMALinesTest'+ListRMALines.size());
            if(ListRMALines!=null && ListRMALines.size()>0){
                for(SVMXC__RMA_Shipment_Line__c oRMALine : ListRMALines){
                    if(oRMALine.SVMXC__Line_Status__c  == 'Completed' || oRMALine.SVMXC__Line_Status__c=='Canceled')
                     CompleteLines = CompleteLines + 1;
                }
                if(ListRMALines.size()==CompleteLines){
                    DisableCommit = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG009()));//getTAG004()));
                }
                else{
                    DisableCommit = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG002()));//getTAG005()));
                }
                
            }
            else
            {
                DisableCommit = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG009()));//getTAG004()));
      
                
            }
        }
    }
    
    // Shipment lines update method
    public void SVMXC_CompleteShipment(Id RecId){
        displayImage = 'none';      
        integer CompleteLines = 0;  
        
        ShipmentRec = [SELECT Id, SVMXC__Order_Status__c,SVMXC__Service_Engineer__c,SVMXC__Destination_Location__c, SVMXC__Sales_Order_Number__c FROM SVMXC__RMA_Shipment_Order__c WHERE Id=:RecId]; 
        if(ShipmentRec.SVMXC__Order_Status__c=='Closed'){
            DisableCommit = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007()));//getTAG006()));
        }
        else if(ShipmentRec.SVMXC__Order_Status__c=='Canceled'){
            DisableCommit = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011()));//getTAG007()));
        }
        else{
            ListShipmentLines = [SELECT SVMXC__Line_Status__c, id, SVMXC__Expected_Quantity2__c,SVMXC__Actual_Ship_Date__c, SVMXC__Actual_Quantity2__c,SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c,SVMXC__Ship_Location__c FROM SVMXC__RMA_Shipment_Line__c WHERE SVMXC__RMA_Shipment_Order__c =:ShipmentRec.Id AND (SVMXC__Line_Status__c != 'Completed' or SVMXC__Line_Status__c != 'Canceled')];
            system.debug('ShipmentLinesTest'+ListShipmentLines.size());
            
            if(ListShipmentLines!=null && ListShipmentLines.size()>0){
                for(SVMXC__RMA_Shipment_Line__c oShipmentLine : ListShipmentLines){
                    if(oShipmentLine.SVMXC__Line_Status__c  == 'Completed' || oShipmentLine.SVMXC__Line_Status__c=='Canceled')
                     CompleteLines = CompleteLines + 1;             
                    
                }
                if(ListShipmentLines.size()==CompleteLines){
                    DisableCommit = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG008()));//getTAG008()));
                }
                else{
                    DisableCommit = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.INFO,getTAG005()));//getTAG009()));
                }               
            }
            else
            {
                DisableCommit = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG008()));//getTAG008()));
            
                
            }
        }
    }
    
    public pageReference SVMX_SaveRMAShipment(){
        string url;
        pageReference p;
        url = '/'+RMAShipRec.Id;
        try{
            if(ListRMALines!=null && ListRMALines.size()>0){
                for(SVMXC__RMA_Shipment_Line__c oRMALine : ListRMALines){
                    oRMALine.SVMXC__Actual_Receipt_Date__c = system.today();
                    oRMALine.SVMXC__Actual_Quantity2__c = oRMALine.SVMXC__Expected_Quantity2__c;
                    oRMALine.SVMXC__Returned_Condition__c = 'As Expected';
                    oRMALine.SVMXC__Ship_Location__c = RMARec.SVMXC__Source_Location__c  ;
                    oRMALine.SVMXC__Warehouse__c = RMARec.SVMXC__Warehouse__c;
                    oRMALine.SVMXC__Line_Status__c  = 'Completed';
                }
                //update ListRMALines;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ListRMALines, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update ListRMALines;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    p = null;
                    return p;
                }
                RMARec.SVMXC__Order_Status__c = 'Closed';
                //update RMARec;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(RMARec, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update RMARec;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    p = null;
                    return p;
                }
            }
            if(ListShipmentLines!=null && ListShipmentLines.size()>0){
                for(SVMXC__RMA_Shipment_Line__c oShipmentLine : ListShipmentLines){
                    oShipmentLine.SVMXC__Actual_Ship_Date__c  = system.today();
                    oShipmentLine.SVMXC__Actual_Quantity2__c = oShipmentLine.SVMXC__Expected_Quantity2__c;
                    oShipmentLine.SVMXC__Service_Engineer__c = ShipmentRec.SVMXC__Service_Engineer__c;
                    oShipmentLine.SVMXC__Ship_Location__c = ShipmentRec.SVMXC__Destination_Location__c  ;
                    oShipmentLine.SVMXC__Sales_Order_Number__c  = ShipmentRec.SVMXC__Sales_Order_Number__c;
                    oShipmentLine.SVMXC__Line_Status__c    = 'Completed';
                }
                //update ListShipmentLines;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ListShipmentLines, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update ListShipmentLines;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    p = null;
                    return p;
                }
                ShipmentRec.SVMXC__Order_Status__c = 'Closed';
                //update ShipmentRec;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ShipmentRec, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update ShipmentRec;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    p = null;
                    return p;
                }
            }
            p=new pageReference(url);
            p.setRedirect(true);
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getmessage()));
            p = null;
        }
        return p;
    }
        
    public pageReference SVMXC_GoBacktoRecord(){
        string url;
        pageReference p;        
        url = '/'+RMAShipRec.Id;
        p=new pageReference(url);
        p.setRedirect(true);
        return p;
    }
}