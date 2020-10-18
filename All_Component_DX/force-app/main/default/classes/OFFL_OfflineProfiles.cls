public with sharing class OFFL_OfflineProfiles{ 
    
SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('OFFL001');
//public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('OFFL001');

public String getTAG001() {return system.label.OFFL001_TAG001;}//Offline Profiles';}
public String getTAG002() {return system.label.OFFL001_TAG002;}//Offline Profiles Help';}
public String getTAG003() {return system.label.OFFL001_TAG003;}//Edit';}
public String getTAG004() {return system.label.OFFL001_TAG004;}//Clone';}
public String getTAG005() {return system.label.OFFL001_TAG005;}//Delete';}
public String getTAG006() {return system.label.OFFL001_TAG006;}//Activate';}
public String getTAG007() {return system.label.OFFL001_TAG007;}//Status';}
public String getTAG008() {return system.label.OFFL001_TAG008;}//Type';}
public String getTAG009() {return system.label.OFFL001_TAG009;}//Created By';}
public String getTAG010() {return system.label.OFFL001_TAG010;}//Profile Name';}

public String getTAG011() {return system.label.OFFL001_TAG011;}//Invalid Data';} 
public String getTAG012() {return system.label.OFFL001_TAG012;}//Please selecet a record from the list';} 
public String getTAG013() {return system.label.OFFL001_TAG013;}//Record deleted';} 
public String getTAG014() {return system.label.OFFL001_TAG014;}//Profile Sucessfully deleted';} 
public String getTAG015() {return system.label.OFFL001_TAG015;}//Activated';} 
public String getTAG016() {return system.label.OFFL001_TAG016;}//Profile Sucessfully activated';}
public String getTAG017() {return system.label.OFFL001_TAG017;}//Standard and active profiles cannot be deleted';}  

public String getTAG018() {return system.label.OFFL001_TAG018;}//Deactivate';}
public String getTAG019() {return system.label.OFFL001_TAG019;}//Profiles Deactivated';} 
public String getTAG020() {return system.label.OFFL001_TAG020;}//Profile Sucessfully deactivated';}
public String getTAG021() {return system.label.OFFL001_TAG021;}//New';}
public String getTAG022() {return system.label.OFFL001_TAG022;}//Please selecet only one record from the list';} 
public String getTAG023(){ return system.label.OFFL001_TAG023;}//No records to display';}
public String getTAG024(){ return system.label.OFFL001_TAG024;}//Requesting...';}
public String getTAG025(){ return system.label.OFFL001_TAG025;}//Setup Home';}
public String getTAG026() {return system.label.OFFL001_TAG026;}//Are you sure you wish to continue?';}
public String getHLPURL() {return system.label.OFFL001_HLPURL;}
public String getTAG027() {return system.label.COMM001_TAG076;}

//========================================= Settings =============================================//
public String getSET001() {return '/apex/OFFL_ManageOfflineProfile';}

public String PId;
public Integer custSize=0;
public boolean error=false;
public List<SVMXC__ServiceMax_Config_Data__c> OfflSVMXprofiles;
List<SVMXC__ServiceMax_Config_Data__c> DelMaxAccessBuf;

public  List<SVMXC__ServiceMax_Config_Data__c> deleteProf = new List<SVMXC__ServiceMax_Config_Data__c>();  
Id EstRecType = getEstRecordTypes().Id;
  Boolean CheckAllLines=false;    
  public Boolean getCheckAllLines() {return CheckAllLines;  }
  public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
      
    //======================================== Constructure call ===================================================//      
    public OFFL_OfflineProfiles(){
        OfflSVMXprofiles = [Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, CreatedBy.Username, LastModifiedDate, SVMXC__Select__c, SVMXC__IsDefault__c, LastModifiedBy.Username From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Offline Profile'];
        custSize=OfflSVMXprofiles.size();
       }

        public List<SVMXC__ServiceMax_Config_Data__c> getOfflSVMXprofiles(){
        custSize=OfflSVMXprofiles.size();
        return OfflSVMXprofiles;
        }
        
//======================================== Setting Initial Checklist status ===================================================//
public RecordType getEstRecordTypes(){
RecordType erTypes;
String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Offline Profile\'';       
            erTypes = Database.query(SOQL);      
return erTypes;
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
    //======================================== Function to check whether the data is valid for selected options ===================================================//
    public void isValid(String OpType){
        error=false;
        List<Integer> selectedLines = new List<Integer>();
        Integer i;  
            for (i=0;i<OfflSVMXprofiles.size();i++){
            if (OfflSVMXprofiles.get(i).SVMXC__Select__c==true){
                            selectedLines.add(i);
                            PId=OfflSVMXprofiles.get(i).Id;
            }
        }
        if(selectedLines.size()!=1 && (OpType=='Edit' || OpType=='Clone')){
            error=true;
        }
    }
    //======================================== Action for redirecting on edit event ===================================================//
    public PageReference EditProf() {
        
        error=false;
        OfflineBlockLevelMessage = false; 
        isValid('Edit');

        if (error==true){
        OfflineBlockLevelMessage = true;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG022()));  
        return null;    
        }
        return GoEditPage();
    }

    //======================================== Action for redirecting on clone event ===================================================//
    public PageReference CloneProf() {
        
        error=false;
        OfflineBlockLevelMessage = false; 
        isValid('Clone');

        if (error==true){
        OfflineBlockLevelMessage = true; 
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG022()));  
        return null;    
        }
        return GoClonePage();
    }

    //======================================== Action for redirecting on Dlete event ===================================================//

public PageReference DelProf() {
    OfflineBlockLevelMessage=true;

            List<SVMXC__ServiceMax_Config_Data__c> recId = new List<SVMXC__ServiceMax_Config_Data__c>();  
            List<SVMXC__ServiceMax_Config_Data__c> BufrecId = new List<SVMXC__ServiceMax_Config_Data__c>();  
            List<SVMXC__Offline_Object__c> OflineObj = new List<SVMXC__Offline_Object__c>();
            List<SVMXC__Offline_Object__c> BufOflineObj = new List<SVMXC__Offline_Object__c>();

            List<SVMXC__Offline_View__c> lstOfflView = new List<SVMXC__Offline_View__c>();
            List<SVMXC__Offline_Dataset_Expression__c> lstOffl_DSExp = new List<SVMXC__Offline_Dataset_Expression__c>();
            
            Set<Id> NewObjId = new Set<Id>();

            List<Integer> selectedLines = new List<Integer>();
            Integer i; 
            Integer DelCount; 
            for (i=0;i<OfflSVMXprofiles.size();i++){
                if (OfflSVMXprofiles.get(i).SVMXC__Select__c==true){
                                selectedLines.add(i);
                }
            }
        if(selectedLines.size()==0){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG012()));            
        return null;
        }

            for (i=0;i<OfflSVMXprofiles.size();i++){
            if (OfflSVMXprofiles.get(i).SVMXC__Select__c==true && OfflSVMXprofiles.get(i).SVMXC__Active__c != true){
                            recId.add(OfflSVMXprofiles.get(i));
            }
            else
            {
            OfflSVMXprofiles.get(i).SVMXC__Select__c=false;
            BufrecId.add(OfflSVMXprofiles.get(i));
            }
        }
    OfflSVMXprofiles.clear();
    OfflSVMXprofiles=BufrecId;
    custSize=OfflSVMXprofiles.size();
    CheckAllLines=false;
    //deletes only if records exist
    DelCount=recId.size();
    if(recId.size()>0){

            for(Integer j = 0; j < recId.size();j++){
                DelMaxAccessBuf=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :recId[j].Id];
                
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    delete DelMaxAccessBuf;
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
                DelMaxAccessBuf.clear();
                OflineObj = [SELECT Id FROM SVMXC__Offline_Object__c where SVMXC__Offline_Profile__c=:recId[j].Id];
                    for(SVMXC__Offline_Object__c No :OflineObj){
                        NewObjId.add(No.Id);
                   }
                BufOflineObj.addAll(OflineObj);
            }
            
        lstOfflView =[select id from SVMXC__Offline_View__c where SVMXC__Object_Name__c IN :NewObjId];
        lstOffl_DSExp = [select Id From SVMXC__Offline_Dataset_Expression__c where SVMXC__Offline_Object__c IN :NewObjId];
 
        if(BufOflineObj.size()>0)delete BufOflineObj;
        if(lstOfflView.size()>0)delete lstOfflView;
        if(lstOffl_DSExp.size()>0)delete lstOffl_DSExp;
        if(recId.size()>0)delete recId;
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG013(),getTAG014()));

    }
        if(selectedLines.size()!=DelCount)
        {
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG017()));  
        recId.clear();
        return null;    
        }
    return null;
}
//Activate Selected Profiles
public PageReference ActProf() {

    OfflineBlockLevelMessage=true;
        Integer i;  
        List<Integer> selectedLines = new List<Integer>();
        
        for (i=0;i<OfflSVMXprofiles.size();i++){
                if (OfflSVMXprofiles.get(i).SVMXC__Select__c==true)
                {
                    selectedLines.add(i);
                    OfflSVMXprofiles.get(i).SVMXC__Active__c=true;
                    OfflSVMXprofiles.get(i).SVMXC__Select__c=false;
                }
                
        }
        CheckAllLines=false;
        if(selectedLines.size()==0){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG012())); 
        return null;    
        }

            if(OfflSVMXprofiles.size()>0)upsert OfflSVMXprofiles;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG015(), getTAG016())); 

        return null;
}
//DeActivate Selected Profiles
public PageReference DeActProf() {

    OfflineBlockLevelMessage=true;

        Integer i;  
        List<Integer> selectedLines = new List<Integer>();
        
        for (i=0;i<OfflSVMXprofiles.size();i++){
                if (OfflSVMXprofiles.get(i).SVMXC__Select__c==true)
                {
                    selectedLines.add(i);
                    OfflSVMXprofiles.get(i).SVMXC__Active__c=false;
                    OfflSVMXprofiles.get(i).SVMXC__Select__c=false;
                }
                
        }
        CheckAllLines=false;
        if(selectedLines.size()==0){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),getTAG012())); 
        return null;    
        }


            if(OfflSVMXprofiles.size()>0) upsert OfflSVMXprofiles;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG019(), getTAG020())); 

        return null;
}

    public PageReference GoEditPage() {
      String url = '/';
      url =getSET001();
      //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
      //PageReference ManageProfEd = new PageReference('/apex/OFFL_ManageOfflineProfile');
      PageReference ManageProfEd = new PageReference(url);
      ManageProfEd.getparameters().put('pid',PId);
      ManageProfEd.setRedirect(true);
      return ManageProfEd;      
    }

    public PageReference GoClonePage() {
      String url = '/';
      url =getSET001();
      //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
      //PageReference ManageProfCl = new PageReference('/apex/OFFL_ManageOfflineProfile');
      PageReference ManageProfCl = new PageReference(url);
      ManageProfCl.getparameters().put('pid',PId);
      ManageProfCl.getparameters().put('cl','s');
      ManageProfCl.setRedirect(true);
      return ManageProfCl;      
    }

    public PageReference NewProf() {
      String url = '/';
      url =getSET001();
      //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
      //PageReference ManageProfCl = new PageReference('/apex/OFFL_ManageOfflineProfile');
      PageReference ManageProfCl = new PageReference(url);
      ManageProfCl.getparameters().put('pid',PId);
      ManageProfCl.getparameters().put('cl','i');
      ManageProfCl.setRedirect(true);
      return ManageProfCl;      
    }

//======================================== Action "Back To Setup Home" ===================================================//
public PageReference GoSetupHome(){
      String url = '/apex/SVMXC__CONF_SetupHome';
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
}

    //======================================== Set true to display blocklevel messge ===================================================//
    public Boolean OfflineBlockLevelMessage = false;
    public Boolean getOfflineBlockLevelMessage(){ return OfflineBlockLevelMessage; } 
}