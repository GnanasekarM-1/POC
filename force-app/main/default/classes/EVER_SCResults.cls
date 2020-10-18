/* -------------------------------------------------------------------------------------
* EVER_SCResults class 
* GM  01 April 2009
* 
*
* Service Contract Search Results Wrapper Class
* - Used by the EVER_CaseEntitlement Class and Page 
* - Main purpose is to return a LIST of Service Contracts along with a custom checkbox that can 
*   be used to let the user select which rows to Use and which to ignore.
*  ------------------------------------------------------------------------------------- */

public class EVER_SCResults {

    public boolean selected = false;
    //public SVMXC__Service_Contract__c scont = new SVMXC__Service_Contract__c();
    public Date StartDate;
    public Date EndDate;
    public String CoveredBy;
    public String SCName;
    public Id SCId;
    public String SLAName;
    public Id SLAID;
    public Id idSelectdIS;
    public String strNameIS;
    public String strUnitsAvl;
    public List<IncludedServicesWrapper> lstISWrapper = new List<IncludedServicesWrapper>();
   // public Id ID;
    
   public void setStartDate(Date d){StartDate =d;}
   public void setEndDate(Date d){EndDate =d;}
   public void setCoveredBy(String cb){CoveredBy = cb;}
   public void setSCName(String scname){SCName = scname;}
   public void setSCId(Id scid){SCId= scid;}
   public void setSLAName(String sla){SLAName=sla;}
   public void setSLAID(Id sl){SLAID=sl;}
   public void setidSelectdIS(Id IdIS){idSelectdIS = IdIS;}
   public void setstrNameIS(String strNmIS){strNameIS = strNmIS;}
   public void setstrUnitsAvl(String strAvl){strUnitsAvl = strAvl;}
   public void setlstISWrapper(List<IncludedServicesWrapper> WrapperLst){lstISWrapper = WrapperLst;}
   
   
   public Date getStartDate(){return StartDate ;}
   public Date getEndDate(){return EndDate; }
   public String getCoveredBy(){return CoveredBy ;}
   public String getSCName(){return SCName; }
   public Id getSCId(){return SCId;}
   public String getSLAName(){return SLAName;}
   public Id getSLAID(){return SLAID;}
   public Id getidSelectdIS() {return idSelectdIS;}
   public String getstrNameIS() {return strNameIS;}
   public String getstrUnitsAvl() {return strUnitsAvl;}
   public List<IncludedServicesWrapper> getlstISWrapper() {return lstISWrapper;}

    public EVER_SCResults() { }
    public EVER_SCResults(Date sd ,Date ed,String cb,String scname,String scid,String sla)
    {
        StartDate =sd;
        EndDate = ed;
        CoveredBy = cb;
        SCName = scname;
        SCId = scid;
        SLAName=sla; 
    }
    public boolean getselected()        { return this.selected; }
    public void setselected(boolean s)  { this.selected = s; }  
    public string getSDate()      
    { 
        if (StartDate==null)
            return '';
        else
            return date.newInstance(this.StartDate.year(), this.StartDate.month(), this.StartDate.day()).format() ;
    }
    public string getEDate() 
    { 
        if (EndDate==null)
            return '';
        else
            return date.newInstance(this.EndDate.year(), this.EndDate.month(), this.EndDate.day()).format() ;
    }  
    
    public class IncludedServicesWrapper{
        public String strServiceName{get;set;}
        public boolean isSelected{get; set;}
        //public String strWrprQualified{get; set;}
        public boolean isQualified{get; set;}
        public String strTracked{get; set;}
        public SVMXC__Service_Contract_Services__c IncludedServices = new SVMXC__Service_Contract_Services__c();
        public void setIncludedServices(SVMXC__Service_Contract_Services__c SCIS){IncludedServices = SCIS;}
        public SVMXC__Service_Contract_Services__c getIncludedServices() {return IncludedServices;}
        public IncludedServicesWrapper()
        {
            isSelected = false; 
        }
    }
}