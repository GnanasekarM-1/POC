public with sharing class OFFL_ManageOfflineProfile{
    
SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
//public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('OFFL002');

public String getTAG001() {return system.label.OFFL002_TAG001;}//Manage Offline Profiles';}
public String getTAG002() {return system.label.OFFL002_TAG002;}//Manage Offline Profiles Help';}
public String getTAG003() {return system.label.OFFL002_TAG003;}//Save';}
public String getTAG004() {return system.label.OFFL002_TAG004;}//Cancel';}
public String getTAG005() {return system.label.OFFL002_TAG005;}//Quick Save';}
public String getTAG007() {return system.label.OFFL002_TAG007;}//Information';}
public String getTAG008() {return system.label.OFFL002_TAG008;}//Profile Name';}
public String getTAG010() {return system.label.OFFL002_TAG010;}//Profile saved sucessfully';}
public String getTAG011() {return system.label.OFFL002_TAG011;}//Please enter a value.';} 
public String getTAG012() {return system.label.OFFL002_TAG012;}//Already an instance has been created with this name.';}
public String getTAG013() {return system.label.OFFL002_TAG013;}//Offline Activities';} 
public String getTAG014() {return system.label.OFFL002_TAG014;}//Access Permission';} 
public String getTAG015() {return system.label.OFFL002_TAG015;}//Information';} 
public String getTAG016() {return system.label.OFFL002_TAG016;}//Profile Name';}
public String getTAG017() {return system.label.OFFL002_TAG017;}//Loading';}  
public String getTAG018() {return system.label.OFFL002_TAG018;}//Select Profiles';}

public String getTAG021() {return system.label.OFFL002_TAG021;}//Manage Offline DataSets';}
public String getTAG022() {return system.label.OFFL002_TAG022;}//Add';}
public String getTAG023() {return system.label.OFFL002_TAG023;}//Edit';}
public String getTAG024() {return system.label.OFFL002_TAG024;}//Tab Order';}
public String getTAG025() {return system.label.OFFL002_TAG025;}//Delete';}
public String getTAG026(){ return system.label.OFFL002_TAG026;}//No records to display';}
public String getTAG027() {return system.label.OFFL002_TAG027;}//Select Profiles - Available';}
public String getTAG028() {return system.label.OFFL002_TAG028;}//Select Profiles - Selected';}
public String getTAG029() {return system.label.OFFL002_TAG029;}//Select';}
public String getTAG030() {return system.label.OFFL002_TAG030;}//Remove';}

//public String getTAG031() {return system.label.OFFL002_TAG031;}//Invalid Record';}
public String getTAG032() {return system.label.OFFL002_TAG032;}//Please select a valid record from list of available profiles';}
public String getTAG033() {return system.label.OFFL002_TAG033;}//Records deleted sucessfully';}
public String getTAG034() {return system.label.OFFL002_TAG034;}//Please select a record to delete';}
//public String getTAG035() {return system.label.OFFL002_TAG035;}//Invalid Data';}
public String getTAG036() {return system.label.OFFL002_TAG036;}//System created objects cannot be deleted';}
public String getTAG037() {return system.label.OFFL002_TAG037;}//Please select one record to edit';}

public String getTAG046() {return system.label.OFFL002_TAG046;}//Following salesforce Profiles are already having an access assigned to servicemax online profile, this access would be revoked on save.';}
public String getTAG051() {return system.label.OFFL002_TAG051;}//Critical Error';}
public String getTAG052() {return system.label.OFFL002_TAG052;}//Invalid dataset values exists.';}
public String getTAG053() {return system.label.OFFL002_TAG053;}//Are you sure?';}
public String getTAG048() {return system.label.OFFL008_TAG048;}//Are you sure?';}
public String getTAG049() {return system.label.OFFL008_TAG049;}//Are you sure?';}
public String getTAG056() {return system.label.OFFL008_TAG056;}//Are you sure?';}

//Neeraj(16-02-2012): Added tags to resolve translation related issues.
public String getTAG057() {return system.label.COMM001_TAG016;} //'Active'
public String getTAG058() {return system.label.OFFL002_TAG054;} //'Enable Task'
public String getTAG059() {return system.label.OFFL002_TAG055;} //'Enable Calendar'
public String getTAG060() {return system.label.COMM001_TAG017;} //'Description'
public String getTAG061() {return system.label.OFFL002_TAG056;} //'Enable Activity Tracking On'
public String getTAG062() {return system.label.OFFL008_TAG062;}
public String getTAG063() {return system.label.OFFL008_TAG063;}
public String getTAG064() {return system.label.OFFL008_TAG064;}
public String getTAG065() {return system.label.OFFL008_TAG065;}

public String getHLPURL() {return system.label.OFFL002_HLPURL;}

//========================================= Settings =============================================//
public String getSET001() {return '/apex/OFFL_TabOrder';}
public String getSET002() {return '/apex/OFFL_ManageDataSets';}
public String getSET003() {return '/apex/OFFL_OfflineProfiles';}
public String getSET004() {return '/apex/OFFL_ManageOfflineProfile';}

//========================================= Variables =============================================//
String OPId= System.currentPageReference().getParameters().get('pid');
public String PId= System.currentPageReference().getParameters().get('pid');
public String Clone= System.currentPageReference().getParameters().get('cl');
public String getClone(){
        return Clone;
}
    Boolean CheckAllLines=false; 
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
public String OId;
public Integer custSize=0;
Boolean OnLaunch=true;
Id NewProf;
Id EstRecType = getEstRecordTypes().Id;
public List<Profile> Profiles;
public List<Profile> SProfiles = new List<Profile>();
public List<Profile> AProfiles = new List<Profile>();

public Map<String, Schema.SObjectType> allObjs;

public List<String> profile = new List<String>(); //Base Profiles
public List<String> getProfile(){   return this.profile; }  
public void setProfile(String[] s){ this.profile =s; } 

public List<String> Sprofile = new List<String>();  //To Profiles
public List<String> getSProfile(){  return this.Sprofile; }  
public void setSProfile(String[] s){ this.Sprofile =s; } 

public List<String> T1profile = new List<String>();
public List<String> T2profile = new List<String>();

public List<SelectOption> SelectedProf = new List<SelectOption>();
public List<SelectOption> AvailProf = new List<SelectOption>();
public List<User> Usrs = new List<User>();

public SVMXC__ServiceMax_Config_Data__c conf_data=new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
public SVMXC__ServiceMax_Config_Data__c Updconf_data=new SVMXC__ServiceMax_Config_Data__c();
List<SVMXC__ServiceMax_Config_Data__c> serviceMaxAccessBuf=new List<SVMXC__ServiceMax_Config_Data__c>();
Map<Id, String> IdToSMXProfileMap =  new Map<Id, String> {};
Map<Id, Id> IdToSMXProfileIDMap =  new Map<Id, Id> {};
Set<Id> OthrProfList = new Set<Id>();

    private final Offline_Object__c obj;
    public string ProfileName;
    public boolean flag=false;
    public string items;
    List<SelectOption> options = new List<SelectOption>();
    public List<Offline_Object__c> OfflineObjlst = new List<Offline_Object__c>();
    // The extension constructor initializes the private member 
    // variable obj by using the getRecord method from the standard controller.
    
    private integer selectedIndex = 0;
    private boolean isUpAction = false;
    public List<SelectOption> Profile_AutoSyncUnit{get;set;}
    public List<SelectOption> userlist {get;set;}
    public String selval{get;set;}
    public String showMessage{get;set;}
    set<Id> setPofileIds = new set<Id>();
    //public boolean isGetPriceMode = false;
    //public boolean getisGetPriceMode() {return isGetPriceMode;}
    //Fix for #3816
    Set<Id> NewObjId = new Set<Id>();
    List<SVMXC__Offline_Object__c> recId = new List<SVMXC__Offline_Object__c>();    
    List<SVMXC__Offline_Object__c> BufrecId = new List<SVMXC__Offline_Object__c>();
    List<SVMXC__Offline_Object__c> RelObj = new List<SVMXC__Offline_Object__c>();
    List<SVMXC__Offline_View__c> lstOfflView = new List<SVMXC__Offline_View__c>();
    List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExp = new List<SVMXC__Offline_Dataset_Expression__c>();
    //Fix for #3816-end
    
//======================================== Constructure call ===================================================//  
public OFFL_ManageOfflineProfile(){
    Profiles = [Select Id, Name From Profile where Name != '' order by Name];//defect #001688
    Profile_AutoSyncUnit = new List<SelectOption>();
    GetSyncUnit();
    onLoad();
    GetUsersList();
}
private void GetSyncUnit()
    {
        Schema.DescribeFieldResult defaultSyncUnit=SVMXC__ServiceMax_Config_Data__c.SVMXC__Auto_Sync_Duration_Unit__c.getDescribe();
        List<Schema.PicklistEntry> SyncUnit = defaultSyncUnit.getPicklistValues();
        for(Schema.PicklistEntry currentSyncUnit: SyncUnit)
        {
            if(currentSyncUnit.isDefaultValue())
            {
                Profile_AutoSyncUnit.add(0, new SelectOption(currentSyncUnit.getValue(), currentSyncUnit.getLabel()));
            }
            else
            {
                Profile_AutoSyncUnit.add(new SelectOption(currentSyncUnit.getValue(),currentSyncUnit.getLabel()));
            }
            
        } 
              
    }
private void GetUsersList()
{
    if(PId!=NULL && Clone!='s')
    {
        userlist = new List<SelectOption>();
        setPofileIds.clear();
        system.debug('List of Profiles: '+serviceMaxAccessBuf.size());
        if(serviceMaxAccessBuf.size()>0){
            for(Integer i = 0; i < serviceMaxAccessBuf.size();i++)
            {
                
                setPofileIds.add(serviceMaxAccessBuf[i].SVMXC__Profile__c);
                }
                Usrs = [Select Username, Name From User where Name != '' and IsActive = true and ProfileId IN : setPofileIds order by Name];
                If(Usrs.size()>0){
                 for(Integer j = 0; j < Usrs.size();j++){
                    userlist.add(new SelectOption(Usrs[j].Username,Usrs[j].Name));
                    }
                 }
               }
        }
}  
     
//======================================== Followed by Constructure call ===================================================// 
public void onLoad(){

    if(PId!=NULL)
    {
    conf_data = [SELECT SVMXC__Profile_Name__c, SVMXC__Description__c, SVMXC__Active__c, SVMXC__Configuration_Type__c,SVMXC__Enable_Activity_Tracking_On__c,Enable_Calendar__c,Enable_Task__c,SVMXC__Remove_Events_Older_Than2__c,SVMXC__Remove_Records_Older_Than2__c,SVMXC__Sync_Data_On_Login__c,SVMXC__Auto_Sync_Duration2__c,SVMXC__Auto_Sync_Duration_Unit__c,SVMXC__Allow_API_Access__c,SVMXC__Validate_User_Credentials_Every__c From SVMXC__ServiceMax_Config_Data__c where Id=:PId];
    serviceMaxAccessBuf=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :PId];
    //isGetPriceMode =true;
    }
    else if(Clone!='i')
    {
    ProfDisplayBlockLevelMessage = true;  
    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',getTAG032())); 
    }
    if(Clone=='i'||Clone=='s')
    conf_data.SVMXC__Active__c=true;
    if(Clone=='i')
    {
      conf_data.SVMXC__Sync_Data_On_Login__c =true;
      //isGetPriceMode =true;
    }
    
    
    List<SVMXC__ServiceMax_Config_Data__c> OfflSVMXprofiles;
    List<SVMXC__ServiceMax_Config_Data__c> serviceMaxAccessAvail=new List<SVMXC__ServiceMax_Config_Data__c>();
    List<String> T3profile = new List<String>();
    OfflSVMXprofiles = [Select Id,SVMXC__Profile_Name__c  From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Offline Profile'];
    
        for(Integer i = 0; i < OfflSVMXprofiles.size();i++){
            if(OfflSVMXprofiles[i].Id!=PId || Clone=='s')
            {
            List<SVMXC__ServiceMax_Config_Data__c> temp;
            temp=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :OfflSVMXprofiles[i].Id];
            for(SVMXC__ServiceMax_Config_Data__c s :temp)
            {
                IdToSMXProfileMap.put(s.SVMXC__Profile__c,OfflSVMXprofiles[i].SVMXC__Profile_Name__c);
                IdToSMXProfileIDMap.put(s.SVMXC__Profile__c,OfflSVMXprofiles[i].Id);
                OthrProfList.add(s.SVMXC__Profile__c);
            }
            serviceMaxAccessAvail.addAll(temp);
            }
        }
    boolean Isvalid=true;
    boolean isCriticalErr=false;
    if(PId!=NULL)
    {
    OfflineObjlst = [Select SVMXC__Tab_Order__c, SVMXC__Select__c, SVMXC__Ownership_Limit__c, SVMXC__Object_Name__c, SVMXC__Allow_Upload__c, SVMXC__Allow_Tab__c, Id, SVMXC__Offline_Profile__c,SVMXC__User_Defined__c,SVMXC__Use_Object_As_Home_Tab__c,SVMXC__Allow_Attachment__c,SVMXC__Allow_API_Access__c From SVMXC__Offline_Object__c where SVMXC__User_Defined__c = true and SVMXC__Related_To__c='' and SVMXC__Parent_Object__c='' and SVMXC__Offline_Profile__c=:PId order by SVMXC__Tab_Order__c asc];
    custSize=OfflineObjlst.size();
    Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    Map<String, Schema.SObjectType> tempallObjs = Schema.getGlobalDescribe();
    for(Schema.SObjectType lON : tempallObjs.values()) //Loop List of all Objects and describe each
    {
         Schema.DescribeSObjectResult D = lON.getDescribe();
          allObjs.put(D.getName(), lON);
    }
    //Map<String, Schema.SObjectType> allObjs;
    //allObjs = Schema.getGlobalDescribe();   
    for(integer a=0;a<OfflineObjlst.size();a++)
    {
        string name = OfflineObjlst[a].SVMXC__Object_Name__c;
        system.debug('name' + name);
        //if(name.contains('Service_Order__c'))
        //isGetPriceMode = false;
        Schema.SObjectType objT = allObjs.get(name);
        system.debug('objT' + objT);
        string s;  
        if(objT!=NULL)
        {
            system.debug('objT1' + String.valueOf(objT.getDescribe().getLabel()));
            s= String.valueOf(objT.getDescribe().getLabel());
            BufrecId.add(OfflineObjlst.get(a));
        }
        else
        {
            //CriticalErr=false;
            //isCriticalErr=true; 
            //break;
            //Fix for #3816 
            system.debug('Null reference rec Id:' + OfflineObjlst.get(a).Id);
            recId.add(OfflineObjlst.get(a));
            NewObjId.add(OfflineObjlst.get(a).Id);
            //Fix for #3816-end
        }
        OfflineObjlst[a].SVMXC__Object_Name__c = s;    
    }
        //Fix for #3816
       OfflineObjlst.clear();
       OfflineObjlst=BufrecId;
       //Fix for #3816-end
        
    }
    //if(isCriticalErr==true) 
    //{
        //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG051(),getTAG052()));  
    //} 

    if(Clone==NULL){
        for(Integer i = 0; i < serviceMaxAccessBuf.size();i++){
            for(Integer j = 0; j < Profiles.size();j++){
                if(serviceMaxAccessBuf[i].SVMXC__Profile__c==Profiles[j].Id){
                    SelectedProf.add(new SelectOption(Profiles[j].Id,Profiles[j].Name));
                    T2profile.add(Profiles[j].Id);
                    T3profile.add(Profiles[j].Id);
                    SProfiles.add(Profiles[j]);
                }
             }
        }
    }

    If(Profiles.size()>0){ 
        for(Integer i = 0; i < Profiles.size();i++){
            Isvalid=true;
            for(Integer j = 0; j < T2profile.size();j++){
                if(Profiles[i].Id==T2profile[j])
                Isvalid=false;
            }
            if(Isvalid==true){
                AvailProf.add(new SelectOption(Profiles[i].Id,Profiles[i].Name));
                T1profile.add(Profiles[i].Id);
                AProfiles.add(Profiles[i]);
            }
         }
    }

    T2profile.clear();
    T2profile=T3profile;  
    AvailProf=sortingSelectAvailProfOption(AvailProf);
    SelectedProf=sortingSelectSelectedProfOption(SelectedProf);
}

  //Fix for #3816
  public void UpdateOfflobj()
  {
     if(recId.size()>0)
     {
           RelObj =[select id from SVMXC__Offline_Object__c where SVMXC__Related_To__c IN :NewObjId];
           lstOfflView =[select id from SVMXC__Offline_View__c where SVMXC__Object_Name__c IN :NewObjId];
           lstOffl_DSExp = [select Id From SVMXC__Offline_Dataset_Expression__c where SVMXC__Offline_Object__c IN :NewObjId];

           if(lstOfflView.size()>0)delete lstOfflView;
           if(lstOffl_DSExp.size()>0)delete lstOffl_DSExp;
           if(RelObj.size()>0)delete RelObj;
                
           system.debug('Deleting' + recId);
           if(recId.size()>0)delete recId ;
    }   
  }
  //Fix for #3816-end


    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectAvailProfOption(List<SelectOption> so){
        SelectOption tempObj; 
        String tempLst;              
                Integer size = so.size();
                Integer i,j;
                for(i=0;i<size;i++){
                  for(j=i+1;j<size;j++){
                      Integer result=so[i].getLabel().compareTo(so[j].getLabel());
                        if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                            tempObj = so[j];
                            so[j] = so[i];
                            so[i] = tempObj;
                            tempLst = T1profile[j];
                            T1profile[j] = T1profile[i];
                            T1profile[i] = tempLst;
                        }
                    }
                }
                return so;
    }
    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectSelectedProfOption(List<SelectOption> so){
        SelectOption tempObj; 
        String tempLst;              
                Integer size = so.size();
                Integer i,j;
                for(i=0;i<size;i++){
                  for(j=i+1;j<size;j++){
                      Integer result=so[i].getLabel().compareTo(so[j].getLabel());
                        if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                            tempObj = so[j];
                            so[j] = so[i];
                            so[i] = tempObj;
                            tempLst = T2profile[j];
                            T2profile[j] = T2profile[i];
                            T2profile[i] = tempLst;
                        }
                    }
                }
                return so;
    }
//======================================== Counts custom records ===================================================//
public boolean getIsListAvail(){
        boolean avail=false;
        if(custSize>0)
        avail=true;
        return avail;
}
public Integer getcustSize(){
        return custSize;
}
boolean AccessMessage;
public boolean getAccessMessage(){
        return AccessMessage;
}
//======================================== Getting Reord type Ids ===================================================//
public RecordType getEstRecordTypes(){
RecordType erTypes;
String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Offline Profile\'';       
            erTypes = Database.query(SOQL);      
return erTypes;
}

Id ProfEstRecType = getProfEstRecordTypes().Id;
public RecordType getProfEstRecordTypes(){
RecordType erTypes;
String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Configuration Access\'';       
            erTypes = Database.query(SOQL);
return erTypes;
}

//========================================= Function : Handles Profiles =============================================//
public List<SelectOption> getAvailProf(){
return AvailProf;  
}  

public List<SelectOption> getSelectedProf(){
return SelectedProf; 
}  
//========================================= Function : Bound Profile details =============================================//
public SVMXC__ServiceMax_Config_Data__c getProf_Detail() {
    if(Clone!=null && OnLaunch==true){OnLaunch=false; conf_data.SVMXC__Profile_Name__c='';conf_data.SVMXC__Description__c='';}
    return conf_data;
}

//======================================== Function : Check whether the data is valid for custom modules ===================================================//
public Boolean isValidData(){
        Integer tempCount=[Select count() From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Offline Profile' and SVMXC__Profile_Name__c = :conf_data.SVMXC__Profile_Name__c];
        Integer i;
        boolean error=false;
        if (conf_data.SVMXC__Profile_Name__c==null){
                error=true;
                conf_data.SVMXC__Profile_Name__c.addError(getTAG011());
        }
        if (tempCount!=0 && (Clone=='s'||Clone=='i') && error!=true){
                error=true;
                conf_data.SVMXC__Profile_Name__c.addError(getTAG012());
        }
        return error;
}
public void GenKey() {
   system.debug('Selected user:'+selval);
   if(selval!=null)
   {
       Blob beforeblob = Blob.valueOf(selval);
       string paramvalue = EncodingUtil.base64Encode(beforeblob);
       string strEncryptedVal = paramvalue.substring(0,5)+ paramvalue.length();
       showMessage=strEncryptedVal.toLowerCase();
       system.debug('EncodedText'+strEncryptedVal.toLowerCase());
   }
}
//======================================== Action for save ===================================================//
public PageReference MSaveProf() {
    system.debug('asdf'+ProfDisplayBlockLevelMessage );
AccessMessage=false;
ProfDisplayBlockLevelMessage = true;
boolean error=false;
error=isValidData();
    if (error==true){
    return null;    
    }
    else{
    try {
            if(Clone!='s' && Clone!='u'){
                if(Clone=='i')
                {
                SVMXC__ServiceMax_Config_Data__c conf_set = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
                conf_set.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                conf_set.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                conf_set.SVMXC__Active__c=conf_data.SVMXC__Active__c;
                conf_set.Enable_Activity_Tracking_On__c=conf_data.Enable_Activity_Tracking_On__c;
                conf_set.Enable_Calendar__c=conf_data.Enable_Calendar__c;
                conf_set.Enable_Task__c=conf_data.Enable_Task__c;
                conf_set.SVMXC__Remove_Events_Older_Than2__c = conf_data.SVMXC__Remove_Events_Older_Than2__c;
                conf_set.SVMXC__Remove_Records_Older_Than2__c = conf_data.SVMXC__Remove_Records_Older_Than2__c;
                conf_set.SVMXC__Sync_Data_On_Login__c=conf_data.SVMXC__Sync_Data_On_Login__c;
                conf_set.SVMXC__Auto_Sync_Duration2__c=conf_data.SVMXC__Auto_Sync_Duration2__c;
                conf_set.SVMXC__Auto_Sync_Duration_Unit__c=conf_data.SVMXC__Auto_Sync_Duration_Unit__c;
                conf_set.SVMXC__Allow_API_Access__c=conf_data.SVMXC__Allow_API_Access__c;
                conf_set.SVMXC__Validate_User_Credentials_Every__c = conf_data.SVMXC__Validate_User_Credentials_Every__c;
                //conf_set.SVMXC__Enable_Get_Price__c = conf_data.SVMXC__Enable_Get_Price__c;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_set, COMM_SecurityUtils.Access.Createable ) ) {
                    insert conf_set;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                Updconf_data=conf_set;
                PId=conf_set.Id;   
                onInsertProfile();          
                }
                else
                {
                //check_conf_CalStatus();
                 if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                        update conf_data;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }
            else if(Clone=='u'){
            Updconf_data.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
            Updconf_data.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                //check_conf_CalStatus();
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Updconf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                    update Updconf_data;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else if(Clone=='s')
            {
                SVMXC__ServiceMax_Config_Data__c conf_set = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
                conf_set.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                conf_set.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                conf_set.SVMXC__Active__c=conf_data.SVMXC__Active__c;
                conf_set.Enable_Activity_Tracking_On__c=conf_data.Enable_Activity_Tracking_On__c;
                conf_set.Enable_Calendar__c=conf_data.Enable_Calendar__c;
                conf_set.Enable_Task__c=conf_data.Enable_Task__c;
                conf_set.SVMXC__Remove_Events_Older_Than2__c = conf_data.SVMXC__Remove_Events_Older_Than2__c;
                conf_set.SVMXC__Remove_Records_Older_Than2__c = conf_data.SVMXC__Remove_Records_Older_Than2__c;
                conf_set.SVMXC__Sync_Data_On_Login__c=conf_data.SVMXC__Sync_Data_On_Login__c;
                conf_set.SVMXC__Auto_Sync_Duration2__c=conf_data.SVMXC__Auto_Sync_Duration2__c;
                conf_set.SVMXC__Auto_Sync_Duration_Unit__c=conf_data.SVMXC__Auto_Sync_Duration_Unit__c;
                conf_set.SVMXC__Allow_API_Access__c=conf_data.SVMXC__Allow_API_Access__c;
                conf_set.SVMXC__Validate_User_Credentials_Every__c = conf_data.SVMXC__Validate_User_Credentials_Every__c;
                //conf_set.SVMXC__Enable_Get_Price__c = conf_data.SVMXC__Enable_Get_Price__c;
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_set, COMM_SecurityUtils.Access.Createable ) ) {
                    insert conf_set;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                Updconf_data=conf_set;
                PId=conf_set.Id;
                CloneDatasetValue();
            }
        saveAccessProf();
        check_conf_CalStatus();
        return cancelProf();
    }
    catch (Exception ex){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));     
    }
    }
return null;
}

//======================================== Action for Quick Save ===================================================//
public PageReference MQSaveProf() {
AccessMessage=false;
ProfDisplayBlockLevelMessage = true;  
boolean error=false;
error=isValidData();
    if (error==true){
    return null;    
    }
    try {
            if(Clone!='s' && Clone!='u'){
                if(Clone=='i')
                {
                SVMXC__ServiceMax_Config_Data__c conf_set = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
                conf_set.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                conf_set.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                conf_set.SVMXC__Active__c=conf_data.SVMXC__Active__c;
                conf_set.Enable_Activity_Tracking_On__c=conf_data.Enable_Activity_Tracking_On__c;
                conf_set.Enable_Calendar__c=conf_data.Enable_Calendar__c;
                conf_set.Enable_Task__c=conf_data.Enable_Task__c;
                conf_set.SVMXC__Remove_Events_Older_Than2__c = conf_data.SVMXC__Remove_Events_Older_Than2__c;
                conf_set.SVMXC__Remove_Records_Older_Than2__c = conf_data.SVMXC__Remove_Records_Older_Than2__c;
                conf_set.SVMXC__Sync_Data_On_Login__c=conf_data.SVMXC__Sync_Data_On_Login__c;
                conf_set.SVMXC__Auto_Sync_Duration2__c=conf_data.SVMXC__Auto_Sync_Duration2__c;
                conf_set.SVMXC__Auto_Sync_Duration_Unit__c=conf_data.SVMXC__Auto_Sync_Duration_Unit__c;
                conf_set.SVMXC__Allow_API_Access__c=conf_data.SVMXC__Allow_API_Access__c;
                conf_set.SVMXC__Validate_User_Credentials_Every__c = conf_data.SVMXC__Validate_User_Credentials_Every__c;
               // conf_set.SVMXC__Enable_Get_Price__c = conf_data.SVMXC__Enable_Get_Price__c;
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_set, COMM_SecurityUtils.Access.Createable ) ) {
                        insert conf_set;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                Updconf_data=conf_set;
                PId=conf_set.Id; 
                onInsertProfile();              
                }
                else
                {
                //check_conf_CalStatus();
                
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                        update conf_data;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }
            else if(Clone=='u'){
            Updconf_data.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
            Updconf_data.SVMXC__Description__c=conf_data.SVMXC__Description__c;
            //check_conf_CalStatus();
            
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Updconf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                    update Updconf_data;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            else if(Clone=='s')
            {
            SVMXC__ServiceMax_Config_Data__c conf_set = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
            conf_set.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
            conf_set.SVMXC__Description__c=conf_data.SVMXC__Description__c;
            conf_set.SVMXC__Active__c=conf_data.SVMXC__Active__c;
            conf_set.Enable_Activity_Tracking_On__c=conf_data.Enable_Activity_Tracking_On__c;
            conf_set.Enable_Calendar__c=conf_data.Enable_Calendar__c;
            conf_set.Enable_Task__c=conf_data.Enable_Task__c;
            conf_set.SVMXC__Remove_Events_Older_Than2__c = conf_data.SVMXC__Remove_Events_Older_Than2__c;
            conf_set.SVMXC__Remove_Records_Older_Than2__c = conf_data.SVMXC__Remove_Records_Older_Than2__c;
            conf_set.SVMXC__Sync_Data_On_Login__c=conf_data.SVMXC__Sync_Data_On_Login__c;
            conf_set.SVMXC__Auto_Sync_Duration2__c=conf_data.SVMXC__Auto_Sync_Duration2__c;
            conf_set.SVMXC__Auto_Sync_Duration_Unit__c=conf_data.SVMXC__Auto_Sync_Duration_Unit__c;
            conf_set.SVMXC__Allow_API_Access__c=conf_data.SVMXC__Allow_API_Access__c;
            conf_set.SVMXC__Validate_User_Credentials_Every__c = conf_data.SVMXC__Validate_User_Credentials_Every__c;
           // conf_set.SVMXC__Enable_Get_Price__c = conf_data.SVMXC__Enable_Get_Price__c;
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_set, COMM_SecurityUtils.Access.Createable ) ) {
                    insert conf_set;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            Updconf_data=conf_set;
            PId=conf_set.Id;
            CloneDatasetValue();
            }
            saveAccessProf();
            check_conf_CalStatus();
            GetUsersList();
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,'',getTAG010()));   
    }
    catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
    return null;
}

//======================================== Action for cloning dataset ===================================================//
public PageReference check_conf_CalStatus() {
    List<SVMXC__Offline_Object__c> CloneDSSetValue;
    List<SVMXC__Offline_Object__c> CloneDSSetValue1;
    List<SVMXC__Offline_Object__c> CloneDSSetValue2;
    
    CloneDSSetValue= [Select SVMXC__Offline_Profile__c From SVMXC__Offline_Object__c where SVMXC__Object_Name__c='Event' and SVMXC__Offline_Profile__c = :PId];
    CloneDSSetValue1=[Select SVMXC__Offline_Profile__c From SVMXC__Offline_Object__c where SVMXC__Object_Name__c='Task' and SVMXC__Offline_Profile__c = :PId];
    CloneDSSetValue2=[Select SVMXC__Offline_Profile__c From SVMXC__Offline_Object__c where SVMXC__Object_Name__c='Attachment' and SVMXC__Offline_Profile__c = :PId];
    
    if(conf_data.Enable_Calendar__c==false){
        if(CloneDSSetValue.size()>0){
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Offline_Object__c' ) ) {
                delete CloneDSSetValue; 
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
    }
    
    else{
        if(CloneDSSetValue.size()==0){
            SVMXC__Offline_Object__c OffObj1 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
            OffObj1.SVMXC__Object_Name__c='Event';
            OffObj1.SVMXC__User_Defined__c=false;
            OffObj1.SVMXC__Allow_Upload__c=true;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj1, COMM_SecurityUtils.Access.Createable ) ) {
                insert OffObj1;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
    }
    if(conf_data.Enable_Task__c==false){
        if(CloneDSSetValue1.size()>0){
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Offline_Object__c' ) ) {
                delete CloneDSSetValue1;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
    }
    
    else{
        if(CloneDSSetValue1.size()==0){
            SVMXC__Offline_Object__c OffObj2 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
            OffObj2.SVMXC__Object_Name__c='Task';
            OffObj2.SVMXC__User_Defined__c=false;
            OffObj2.SVMXC__Allow_Upload__c=true;
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj2, COMM_SecurityUtils.Access.Createable ) ) {
                insert OffObj2;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
    }
    if(CloneDSSetValue2.size()>0){
        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Offline_Object__c' ) ) {
            delete CloneDSSetValue2;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    }
        //else
        //{
            //if(CloneDSSetValue2.size()==0){
            SVMXC__Offline_Object__c OffObj3 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
            OffObj3.SVMXC__Object_Name__c='Attachment';
            OffObj3.SVMXC__User_Defined__c=false;
            OffObj3.SVMXC__Allow_Upload__c=true;
            //OffObj3.SVMXC__Child_To_Parent_Field_Name__c = 'ParentId';
    
    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj3, COMM_SecurityUtils.Access.Createable ) ) {
        insert OffObj3;
    } else {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }
        //}
            
       // }
    return null;
}
//======================================== Action for cloning dataset ===================================================//
public PageReference CloneDatasetValue() {

    Map<Id, Id> ObjectMap =  new Map<Id, Id> {};
    Set<Id> OldObjId = new Set<Id>();
    Set<Id> NewObjId = new Set<Id>();
    List<SVMXC__Offline_Object__c> CloneDSSetValue;
    List<SVMXC__Offline_Object__c> lstOfflObj_RefObj;
    
    List<SVMXC__Offline_View__c> lstOfflView;
    List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExp;

    List<SVMXC__Offline_View__c> BUF_lstOfflView = new List<SVMXC__Offline_View__c>();
    List<SVMXC__Offline_Dataset_Expression__c> BUF_lstOffl_DSExp = new List<SVMXC__Offline_Dataset_Expression__c>();
          
    List<SVMXC__Offline_Object__c> InsertDSSetValue= new List<SVMXC__Offline_Object__c>();
    List<SVMXC__Offline_Object__c> InsertRelDSSetValue= new List<SVMXC__Offline_Object__c>();
    List<SVMXC__Offline_Object__c> InsertRelDSSetValue_Ids= new List<SVMXC__Offline_Object__c>();
    
    String SOQLQUERY;
    String fieldNames;
    
    Schema.DescribeSObjectResult dsoResult;
    Map<String, SObjectField> fieldMap;
    List<String> fieldList;
    
    //build a list of all fieldnames for the object
    dsoResult = SVMXC__Offline_Object__c.sObjectType.getDescribe();
    fieldMap = Schema.SObjectType.SVMXC__Offline_Object__c.fields.getMap();
    fieldList = getFieldList(fieldMap,true);      
    fieldNames = getFieldNamesFromList(fieldList);
                
    SOQLQUERY = '  SELECT '+ fieldNames +' FROM SVMXC__Offline_Object__c where SVMXC__Offline_Profile__c=\''+OPId+'\'';
        
    CloneDSSetValue=Database.query(SOQLQUERY);
    SVMXC__Offline_Object__c cloneDS;

    integer i;
    integer j;

    for(i = 0; i < CloneDSSetValue.size();i++){
        SVMXC__Offline_Object__c cloneOMap = CloneDSSetValue[i].clone(false,true); //Clone the existing line
        cloneOMap.SVMXC__Offline_Profile__c=PId;
        InsertDSSetValue.add(cloneOMap); 
    } 

    if(InsertDSSetValue.size()>0)upsert InsertDSSetValue; 

for (SVMXC__Offline_Object__c No :InsertDSSetValue){
    for (SVMXC__Offline_Object__c Oo :CloneDSSetValue){
        if((Oo.SVMXC__Object_Name__c==No.SVMXC__Object_Name__c) && (Oo.SVMXC__Related_To__c==NULL) && (No.SVMXC__Related_To__c==NULL)){         
                ObjectMap.put(Oo.Id,No.Id);
                OldObjId.add(Oo.Id);
                NewObjId.add(No.Id);
                break;
        }
    }
}

    try{

        lstOfflObj_RefObj = [Select SVMXC__Offline_Profile__c,SVMXC__Allow_View_Override__c,SVMXC__Allow_Tab__c,SVMXC__Allow_Upload__c, SVMXC__Archival_Criteria__c, SVMXC__Lock_Criteria__c,SVMXC__Object_Name__c, SVMXC__Offline_Query__c, SVMXC__Ownership_Limit__c, SVMXC__Parent_Object__c, SVMXC__Related_To__c, SVMXC__SOQL_Query__c, SVMXC__Tab_Order__c, SVMXC__Use_Object_As_Home_Tab__c, SVMXC__User_Defined__c,SVMXC__Allow_Attachment__c from SVMXC__Offline_Object__c where SVMXC__Offline_Profile__c=:PId];

    for(i = 0; i < lstOfflObj_RefObj.size();i++){
        SVMXC__Offline_Object__c cloneDS_Chld_OFBJ = lstOfflObj_RefObj[i];//Clone the existing line
                if(lstOfflObj_RefObj[i].SVMXC__Related_To__c!=NULL)
                cloneDS_Chld_OFBJ.SVMXC__Related_To__c=ObjectMap.get(lstOfflObj_RefObj[i].SVMXC__Related_To__c);
        InsertRelDSSetValue.add(cloneDS_Chld_OFBJ); 
    } 
    if(InsertRelDSSetValue.size()>0)update InsertRelDSSetValue; 

    //build a list of all fieldnames for the object
    dsoResult = SVMXC__Offline_View__c.sObjectType.getDescribe();
    fieldMap = Schema.SObjectType.SVMXC__Offline_View__c.fields.getMap();
    fieldList = getFieldList(fieldMap,true);      
    fieldNames = getFieldNamesFromList(fieldList);
                
    SOQLQUERY = '  SELECT '+ fieldNames +' FROM SVMXC__Offline_View__c where SVMXC__Object_Name__c IN ('+getValuesFromSet(OldObjId)+')';
    
    system.debug('TESPB:'+SOQLQUERY);
    lstOfflView =Database.query(SOQLQUERY);
    system.debug('TESPB1:'+lstOfflView);

    for(i = 0; i < lstOfflView.size();i++){
        SVMXC__Offline_View__c cloneDS_Chlds_OFVW = lstOfflView[i].clone(false,true); //Clone the existing line
                cloneDS_Chlds_OFVW.SVMXC__Object_Name__c=ObjectMap.get(lstOfflView[i].SVMXC__Object_Name__c);
        BUF_lstOfflView.add(cloneDS_Chlds_OFVW); 
    } 
    if(BUF_lstOfflView.size()>0)upsert BUF_lstOfflView;

    //build a list of all fieldnames for the object
    dsoResult = SVMXC__Offline_Dataset_Expression__c.sObjectType.getDescribe();
    fieldMap = Schema.SObjectType.SVMXC__Offline_Dataset_Expression__c.fields.getMap();
    fieldList = getFieldList(fieldMap,true);      
    fieldNames = getFieldNamesFromList(fieldList);
                
    SOQLQUERY = '  SELECT '+ fieldNames +' FROM SVMXC__Offline_Dataset_Expression__c where SVMXC__Offline_Object__c IN ('+getValuesFromSet(OldObjId)+')';
    
    lstOffl_DSExp = Database.query(SOQLQUERY);

    for(i = 0; i < lstOffl_DSExp.size();i++){
        SVMXC__Offline_Dataset_Expression__c cloneDS_Chlds_OFEXP = lstOffl_DSExp[i].clone(false,true); //Clone the existing line
                cloneDS_Chlds_OFEXP.SVMXC__Offline_Object__c=ObjectMap.get(lstOffl_DSExp[i].SVMXC__Offline_Object__c);
        BUF_lstOffl_DSExp.add(cloneDS_Chlds_OFEXP); 
    } 
    if(BUF_lstOffl_DSExp.size()>0)upsert BUF_lstOffl_DSExp;
    }
    catch (Exception ex){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));    
        return null;
    }
    return null;
}

public static List<String> getFieldList( Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)
{
    List<String> fieldList = new List<String>();
    //build dynamic list of fieldnames
    for (String fieldKey : fieldMap.keySet()) 
    {
        Schema.SObjectField fsObj = fieldMap.get(fieldKey);
        Schema.DescribeFieldResult f = fsObj.getDescribe();
        String fieldName;
        fieldName = f.getName();
        if (selectAllFields) 
        {
            fieldList.add(fieldName);
        } 
        else
        {
            if (f.getName()=='Id' || f.isNameField() || f.isCustom()) 
            {
                fieldList.add(fieldName);
            }
        }
    }
    return fieldList;
}
public static String getFieldNamesFromList(List<String> fieldList) 
{
    String fieldNames = '';
    for (String field : fieldList) 
    {
        if (fieldNames.length()>0) 
        {
            fieldNames += ',';
        }
        fieldNames += field;
    }
    return fieldNames;
}  

public static String getValuesFromSet(Set<Id> ValueList) 
{
    String Values = '';
    for (String Value : ValueList) 
    {
        if (Values.length()>0) 
        {
            Values += ',';
        }
        Values += '\''+Value+'\'';
    }
    return Values;
}  
//======================================== Function to Seed Dataset : While inserting a profile ===================================================//
public PageReference onInsertProfile() {
    SVMXC__Offline_Object__c OffObj1 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
        OffObj1.SVMXC__Object_Name__c='User';
        OffObj1.SVMXC__User_Defined__c=false;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj1, COMM_SecurityUtils.Access.Createable ) ) {
            insert OffObj1;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    SVMXC__Offline_Object__c OffObj2 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
        OffObj2.SVMXC__Object_Name__c='RecordType';
        OffObj2.SVMXC__User_Defined__c=false;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj2, COMM_SecurityUtils.Access.Createable ) ) {
            insert OffObj2;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    if(conf_data.Enable_Calendar__c==true){
        SVMXC__Offline_Object__c OffObj3 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
        OffObj3.SVMXC__Object_Name__c='Event';
        OffObj3.SVMXC__Allow_Upload__c=true;
        OffObj3.SVMXC__User_Defined__c=false;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj3, COMM_SecurityUtils.Access.Createable ) ) {
            insert OffObj3;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    }
    if(conf_data.Enable_Task__c==true){
        SVMXC__Offline_Object__c OffObj4 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
        OffObj4.SVMXC__Object_Name__c='Task';
        OffObj4.SVMXC__Allow_Upload__c=true;
        OffObj4.SVMXC__User_Defined__c=false;
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj4, COMM_SecurityUtils.Access.Createable ) ) {
            insert OffObj4;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
    }
    SVMXC__Offline_Object__c OffObj5 = new SVMXC__Offline_Object__c(SVMXC__Offline_Profile__c=PId);
        OffObj5.SVMXC__Object_Name__c='Attachment';
        OffObj5.SVMXC__Allow_Upload__c=true;
        OffObj5.SVMXC__User_Defined__c=false;
        //OffObj5.SVMXC__Child_To_Parent_Field_Name__c = 'ParentId';
        
    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OffObj5, COMM_SecurityUtils.Access.Createable ) ) {
        insert OffObj5;
    } else {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }
    return null;
}

//======================================== Action for Saving Access Permissions ===================================================//
public PageReference saveAccessProf() {
    SVMXC__ServiceMax_Config_Data__c tempAccess;
    List<SVMXC__ServiceMax_Config_Data__c> tempAccessList =  new List<SVMXC__ServiceMax_Config_Data__c>();
    
    if(Clone==NULL || Clone=='u')
    if(serviceMaxAccessBuf.size()>0)delete serviceMaxAccessBuf;
    serviceMaxAccessBuf.clear();

    for(Integer j = 0; j < T2profile.size();j++){
            SVMXC__ServiceMax_Config_Data__c newProfLine = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=ProfEstRecType,SVMXC__Access_Configuration_Profile__c=PId,SVMXC__Profile__c=T2profile[j],SVMXC__Active__c=true);             
            serviceMaxAccessBuf.add(newProfLine);
    }
    List<SVMXC__ServiceMax_Config_Data__c> temp;
    temp=[Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Profile__c IN :T2profile and SVMXC__Profile__c IN :OthrProfList];
    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
        delete temp;
    } else {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
    }

    for (Integer i=T2profile.size()-1;i>=0;i--){
        if(OthrProfList.contains(T2profile[i]))
        OthrProfList.remove (T2profile[i]);
    }
        
    if(serviceMaxAccessBuf.size()>0)insert serviceMaxAccessBuf;  
    if(Clone=='s' || Clone=='i')Clone='u';
return null;
}

//======================================== Action for Listing Profiles ===================================================//
public PageReference onAddProfile(){
List<Integer> selectedLines = new List<Integer>();
    Integer i;
    for(String fs: profile){
            for(i = 0; i < T1profile.size();i++){
                     if(fs == T1profile[i]){
                        selectedLines.add(i);
                         SelectedProf.add(AvailProf.get(i));
                         //SProfiles.add(AProfiles[i]);
                         T2profile.add(T1profile[i]);
                     }
            }
        }
        for (i=selectedLines.size()-1;i>=0;i--){
        //AProfiles.remove(selectedLines.get(i));
        AvailProf.remove(selectedLines.get(i));
        T1profile.remove(selectedLines.get(i));
        }
    SelectedProf=sortingSelectSelectedProfOption(SelectedProf);
    AccessStatusCheck();
    return null;
}
/*******************************************************************************************************/
public PageReference onRemProfile(){
List<Integer> selectedLines = new List<Integer>();
Integer i;
    for(String ps: Sprofile){
            for(i = 0; i < T2profile.size();i++){
                     if(ps == T2profile[i]){
                        selectedLines.add(i);
                         AvailProf.add(SelectedProf.get(i));
                         T1profile.add(T2profile[i]);
                         //AProfiles.add(SProfiles[i]);
                     }  
            }
        }
        for (i=selectedLines.size()-1;i>=0;i--){
        //SProfiles.remove(selectedLines.get(i));
        SelectedProf.remove(selectedLines.get(i));
        T2profile.remove(selectedLines.get(i));
        }
    AvailProf=sortingSelectAvailProfOption(AvailProf);
    AccessStatusCheck();
    return null;
}


public void AccessStatusCheck()
{
AccessMessage=false;
String Status='';
    Integer i;
    for (i=T2profile.size()-1;i>=0;i--){
        if(OthrProfList.contains(T2profile[i]))
        {
            if(AccessMessage!=true){
            AccessMessage=true;
            //Status=IdToSMXProfileMap.get(T2profile[i])+getTAG047()+IdToSFXProfileMap.get(T2profile[i])+Status;
            Status=IdToSMXProfileMap.get(T2profile[i])+Status;
            }
            else{
            //Status=Status+' , '+IdToSMXProfileMap.get(T2profile[i])+getTAG047()+IdToSFXProfileMap.get(T2profile[i]);
            Status=Status+' , '+IdToSMXProfileMap.get(T2profile[i]);
            }
        }
    }
if(AccessMessage==true)
    //Status=Status+getTAG050();
    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.WARNING,getTAG046(),Status));   
}
public PageReference cancelProf(){
      String url = '/';
      url =getSET003();
      //if(svmxSettingList.containsKey('SET003') == true) url =svmxSettingList.get('SET003');
      PageReference ManageProf = new PageReference(url);
      ManageProf.setRedirect(true);
      return ManageProf; 
}


public string getProfileName()
{
    user u= [Select Profile.Name, ProfileId From User where Id=:userinfo.getuserid()];
    ProfileName = u.Profile.Name;       
    return ProfileName;
}
public List<Offline_Object__c> getOfflineObjlst()
{
    return OfflineObjlst;
}

    //======================================== Function to check whether the data is valid for selected options ===================================================//
    public Boolean isValid(String OpType){
        boolean error=false;
        List<Integer> selectedLines = new List<Integer>();
        Integer i;  
            for (i=0;i<OfflineObjlst.size();i++){
            if (OfflineObjlst.get(i).SVMXC__Select__c==true){
                            selectedLines.add(i);
                            OId=OfflineObjlst.get(i).Id;
            }
        }
        if(selectedLines.size()!=1 && (OpType=='Edit')){
            error=true;
        }
        return error;
    }
    //======================================== Action for Edit event ===================================================//
    public PageReference EditObj() {
        
        boolean error=false;
        ProfDisplayBlockLevelMessage = false; 
        error=isValid('Edit');

        if (error==true){
        ObjDisplayBlockLevelMessage = true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',getTAG037()));  
        return null;    
        }
        return GoEditObj();
    }
    //======================================== Action for Delete event ===================================================//
    public PageReference delObj()
    {

        ProfDisplayBlockLevelMessage = false; 
        ObjDisplayBlockLevelMessage = true;
        
            List<SVMXC__Offline_Object__c> recId = new List<SVMXC__Offline_Object__c>();  
            List<SVMXC__Offline_Object__c> BufrecId = new List<SVMXC__Offline_Object__c>();  
            List<SVMXC__Offline_Object__c> RelObj = new List<SVMXC__Offline_Object__c>();
            List<SVMXC__Offline_View__c> lstOfflView = new List<SVMXC__Offline_View__c>();
            List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExp = new List<SVMXC__Offline_Dataset_Expression__c>();
            
            Set<Id> NewObjId = new Set<Id>();
            List<Integer> selectedLines = new List<Integer>();
            Integer i; 
            Integer DelCount; 
            for (i=0;i<OfflineObjlst.size();i++){
                if (OfflineObjlst.get(i).SVMXC__Select__c==true)
                {
                     selectedLines.add(i);
                }
            }
            if(selectedLines.size()==0){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',getTAG034()));            
            return null;
            }

            for (i=0;i<OfflineObjlst.size();i++){
                if (OfflineObjlst.get(i).SVMXC__Select__c==true && OfflineObjlst.get(i).SVMXC__User_Defined__c==true)
                {
                      recId.add(OfflineObjlst.get(i));
                      NewObjId.add(OfflineObjlst.get(i).Id);
                      //system.debug('DelObject'+ OfflineObjlst.get(i).SVMXC__Object_Name__c);
                      //isGetPriceMode =true;
                }
                else
                {
                      OfflineObjlst.get(i).SVMXC__Select__c=false;
                      BufrecId.add(OfflineObjlst.get(i));
                }
            }
        OfflineObjlst.clear();
        OfflineObjlst=BufrecId;
        custSize=OfflineObjlst.size();
        DelCount=recId.size();
        if(recId.size()>0){
            
                RelObj =[select id from SVMXC__Offline_Object__c where SVMXC__Related_To__c IN :NewObjId];
                lstOfflView =[select id from SVMXC__Offline_View__c where SVMXC__Object_Name__c IN :NewObjId];
                lstOffl_DSExp = [select Id From SVMXC__Offline_Dataset_Expression__c where SVMXC__Offline_Object__c IN :NewObjId];

                if(lstOfflView.size()>0)delete lstOfflView;
                if(lstOffl_DSExp.size()>0)delete lstOffl_DSExp;
                if(RelObj.size()>0)delete RelObj;
                if(recId.size()>0)delete recId;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,'',getTAG033()));
        }
        if(selectedLines.size()!=DelCount)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'',getTAG036()));  
        recId.clear();
        return null;    
        }
    return null;
    }
//======================================== Move to Tab Order Page ===================================================//
public pageReference taborder()
{
  String url = '/';
  url =getSET001();
  //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
  PageReference ManageTabOrdr = new PageReference(url);
  ManageTabOrdr.getparameters().put('pid',PId);
  ManageTabOrdr.setRedirect(true);
  return ManageTabOrdr;      
}
//======================================== Move to Edit Dataset Page ===================================================//
public PageReference GoEditObj() {
  String url = '/';
  url =getSET002();
  //if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
  PageReference ManageObjEd = new PageReference(url);
  ManageObjEd.getparameters().put('did',OId);
  ManageObjEd.setRedirect(true);
  return ManageObjEd;      
}
//======================================== Move to Add Dataset Page ===================================================//
public PageReference GoAddObj() {
  String url = '/';
  url =getSET002();
  //if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
  PageReference ManageObjAd = new PageReference(url);
  ManageObjAd.getparameters().put('pid',PId);
  ManageObjAd.setRedirect(true);
  return ManageObjAd;      
}
//======================================== Set true to display blocklevel messge ===================================================//
public Boolean ProfDisplayBlockLevelMessage = false;
public Boolean getProfDisplayBlockLevelMessage(){ return ProfDisplayBlockLevelMessage; } 
public Boolean ObjDisplayBlockLevelMessage = false;
public Boolean getObjDisplayBlockLevelMessage(){ return ObjDisplayBlockLevelMessage; }
public Boolean CriticalErr = true;
public Boolean getCriticalErr(){ return CriticalErr; } 
}