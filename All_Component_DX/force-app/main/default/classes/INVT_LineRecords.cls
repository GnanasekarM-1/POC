public with sharing class INVT_LineRecords
{
    public Boolean selected = false;
    public Object LineName = '';
    public Object prodName = '';
    public Object prodId = '';
    public Double exQty = 0;
    public Double trQty = 0;
    public Boolean closeLine = false;
    public Object recLineId = '';
    public Object FromLocationId = '';
    public Object ToLocationId = '';
    public Object FromLocationName = '';
    public Object ToLocationName = '';
    public Object FromStatus = '';
    public Object ToStatus = '';
    public sObject LineObject;
    public Boolean isNegativeStoctAtSource;
    public Boolean isEnableSerialSelection;
    
    public boolean getselected()        { return this.selected; }
    public void setselected(boolean s)  { this.selected = s; } 
    
    public Object getLineName()        { return this.LineName; }
    public void setLineName(Object s)  { this.LineName = s; } 
    
    public Object getprodName()        { return this.prodName; }
    public void setprodName(Object s)  { this.prodName = s; } 
    
    public Object getprodId()        { return this.prodId; }
    public void setprodId(Object s)  { this.prodId = s; } 

    public Double getexQty()        { return this.exQty; }
    public void setexQty(Double s)  { this.exQty = s;     } 

    public Double gettrQty()        { return this.trQty; }
    public void settrQty(Double s)  { this.trQty = s; } 

    public boolean getcloseLine()        { return this.closeLine; }
    public void setcloseLine(boolean s)  { this.closeLine = s; } 
    
    public Object getrecLineId()        { return this.recLineId; }
    public void setrecLineId(Object s)  { this.recLineId = s; } 
    
    public Object getFromLocationID()        { return this.FromLocationID; }
    public void setFromLocationID(Object o)  { this.FromLocationID = o; } 
    
    public Object getToLocationID()        { return this.ToLocationID; }
    public void setToLocationID(Object o)  { this.ToLocationID = o; } 
    
    public Object getFromLocationName()        { return this.FromLocationName; }
    public void setFromLocationName(Object o)  { this.FromLocationName = o; } 
    
    public Object getToLocationName()        { return this.ToLocationName; }
    public void setToLocationName(Object o)  { this.ToLocationName = o; } 
    
    public Object getFromStatus()        { return this.FromStatus; }
    public void setFromStatus(Object s)  { this.FromStatus = s; } 
    
    public Object getToStatus()        { return this.ToStatus; }
    public void setToStatus(Object s)  { this.ToStatus = s; } 
    
    /*public String getstrtrQty()        { return String.valueOf(this.trQty); }
    public void setstrtrQty(String s)  
    {
        try
        {
            this.trQty = Double.valueOf(s);
        }
        catch(exception ex)
        {
            this.trQty = 0;
        } 
    } */
    public INVT_LineRecords Assign(sObject oLineSObject, Boolean sel, Object pN, Object pId, Object exQ, Object trQ, Boolean cL,Object rLi, Object fLoID, Object tLoID, Object fLoName, Object tLoName, boolean bisEnableSerialSelection, Object lName)
    {
        INVT_LineRecords ln = new INVT_LineRecords();
        ln.selected = sel;
        ln.LineName = lName;
        ln.prodName = pN;
        ln.prodId = pId;
        
        if(exQ != null)
        {
            try
            {
                String exQStr = String.valueOf(exQ);
                ln.exQty = Double.valueOf(exQStr);
            }
            catch(exception ex)
            {
                ln.exQty = 0;
            }
        }
        else
            ln.exQty = 0;
        if(trQ != null)
        {
            try
            {
                String trQStr = String.valueOf(trQ);
                ln.trQty = Double.valueOf(trQStr);
            }
            catch(exception ex)
            {
                ln.trQty = 0;
            }
        }
        else
            ln.trQty = 0;
        
        ln.closeLine =cL;
        ln.recLineId =rLi;
        ln.FromLocationID = fLoID;
        ln.ToLocationID = tLoID;
        ln.FromLocationName = fLoName;
        ln.ToLocationName = tLoName;
        ln.LineObject = oLineSObject;
        ln.isEnableSerialSelection = bisEnableSerialSelection;
       /*ln.FromStatus = oFromStatus; 
        ln.ToStatus = oToStatus;*/
        return ln;
    }
}