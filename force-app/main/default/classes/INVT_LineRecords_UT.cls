@isTest
Private class INVT_LineRecords_UT{
    private static SVMXC.INVT_LineRecords lineRecObj = new SVMXC.INVT_LineRecords();
    static testMethod void INVT_LineRecords_UT(){
        test.starttest();
        lineRecObj.FromStatus ='';
        lineRecObj.ToStatus='';
        lineRecObj.LineName = '';
        lineRecObj.selected = false;
        lineRecObj.prodName = '';
        lineRecObj.prodId = '';
        lineRecObj.exQty = 0;
        lineRecObj.trQty = 0;
        lineRecObj.closeLine = false;
        lineRecObj.recLineId= '';
        lineRecObj.FromLocationId= '';
        lineRecObj.ToLocationId= '';
        lineRecObj.FromLocationName= '';
        lineRecObj.ToLocationName= '';
        lineRecObj.LineObject = new SVMXC__Service_Order_Line__c();
        lineRecObj.isNegativeStoctAtSource = true;
        lineRecObj.getselected();
        lineRecObj.setselected( lineRecObj.selected ); 
        
        system.assert(lineRecObj.getLineName()!=null,'getLineName assertion failed');
        lineRecObj.setLineName(lineRecObj.LineName); 
        
        system.assert(lineRecObj.getprodName()!=null,'getprodName assertion failed');
        lineRecObj.setprodName( lineRecObj.prodName ); 
        
        system.assert(lineRecObj.getprodId()!=null,'getprodId assertion failed');
        lineRecObj.setprodId( lineRecObj.prodId ); 
        
        system.assert(lineRecObj.getexQty()!=null,'getexQty assertion failed');
        lineRecObj.setexQty(lineRecObj.exQty ); 
        
        system.assert(lineRecObj.gettrQty()!=null,'gettrQty assertion failed');
        lineRecObj.settrQty(lineRecObj.trQty ); 
        
        system.assert(lineRecObj.getcloseLine()!=null,'getcloseLine assertion failed');
        lineRecObj.setcloseLine( lineRecObj.closeLine ); 
        
        system.assert(lineRecObj.getrecLineId()!=null,'getrecLineId assertion failed');
        lineRecObj.setrecLineId( lineRecObj.recLineId ); 
        
        system.assert(lineRecObj.getFromLocationID()!=null,'getFromLocationID assertion failed');
        lineRecObj.setFromLocationID( lineRecObj.FromLocationID ); 
        
        system.assert(lineRecObj.getToLocationID()!=null,'getToLocationID assertion failed');
        lineRecObj.setToLocationID( lineRecObj.ToLocationID); 
        
        system.assert(lineRecObj.getFromLocationName()!=null,'getFromLocationName assertion failed');
        lineRecObj.setFromLocationName( lineRecObj.FromLocationName ); 
        
        system.assert(lineRecObj.getToLocationName()!=null,'getToLocationName assertion failed');
        lineRecObj.setToLocationName( lineRecObj.ToLocationName ); 
        
        system.assert(lineRecObj.getFromStatus()!=null,'getFromStatus assertion failed');
        lineRecObj.setFromStatus(lineRecObj.FromStatus);
        system.assert(lineRecObj.getToStatus()!=null,'getToStatus assertion failed');
        lineRecObj.setToStatus(lineRecObj.ToStatus);
    
        lineRecObj.Assign(lineRecObj.LineObject,lineRecObj.selected,lineRecObj.prodName,lineRecObj.prodId,lineRecObj.exQty,lineRecObj.trQty,lineRecObj.closeLine,lineRecObj.recLineId,lineRecObj.FromLocationId,lineRecObj.ToLocationId,lineRecObj.FromLocationName,lineRecObj.ToLocationName,false,lineRecObj.getToLocationName());
        test.stoptest();
    }
}