/* Security Scanned */
public with sharing class IPRD_CreateCaseFromIB 
{



 //*****************************************Decleration for Tags & Settings*****************************************************************

SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 

SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
//SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
//public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD003');

Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('IPRD003');  
String mapId  = AllSubModuleSettings.get('SET001');
String defRT = AllSubModuleSettings.get('SET002');

 //********************************************************************************************************************************///
 
 //**************************************************Declaration for Globle variables....*****************************************///
public Boolean btnisdisabled = false;
public Boolean getbtnisdisabled(){return btnisdisabled;}
public String SelectedRT; 
public List<selectoption> options = new List<selectoption>();  
public String IBId = System.currentPageReference().getParameters().get('ibid'); 
public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> (); 
public SVMXC__Installed_Product__c souObjRec = new SVMXC__Installed_Product__c() ;
public Case caseHeader = new Case();  // new Case created from IB.. // RecordTypeId = SelectedRT 
public SVMXC__Installed_Product__c iprd;
public List<RecordType> Rtype = new List<RecordType>(); //changed frm none to public 
public Boolean ValidRecords = true;
public Boolean isdisplay = false;
public String souObjFieldNames; 
public String SOQLHeader;
public list<String> Fieldname = new List<String>();
public Map<String,String> MapofPickListDefValue = new Map<String,String>();  
//**************************************************************Constructor**********************************************************//

 public IPRD_CreateCaseFromIB() //Removed std controller : ApexPages.StandardController stdcontroller : by GM on 30jan10 
 {
    
    //try
    //{
        // if(svmxTagList.size() == null && AllSubModuleSettings.size() == null)
         //{
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG008()));
        // }
   // }
    //catch(Exception e)
    //{
      //   ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
    //}
    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    Rtype = [Select id,Name From RecordType where SobjectType = 'Case' and IsActive=true];
     
     try
      {
        if(Rtype.size() == 0)
        {
           options.add(new selectoption(System.Label.IPRD003_TAG005,System.Label.IPRD003_TAG005));
           SelectedRT = System.Label.IPRD003_TAG005;
        }
        else
        {
          for (RecordType r : Rtype)
          {
             Options.add(new SelectOption(r.Id,r.Name));
             if(defRT != null )
             {
                if(defRT == r.Name)
                SelectedRT = r.Id;
             }
          }           
        }
        caseHeader.OwnerId = Userinfo.getUserId();
        Fieldname.add('Status');
        Fieldname.add('Priority');
        Fieldname.add('Origin');
        Fieldname.add('Type');
        MapofPickListDefValue = utils.SVMX_getDefaultPicklistValue('Case',FieldName);
        system.debug('MapofPickListDefValue'+MapofPickListDefValue);
        if(MapofPickListDefValue.size() > 0)
        {
            if(MapofPickListDefValue.containsKey('Status'))
                caseHeader.Status = MapofPickListDefValue.get('Status');
            if(MapofPickListDefValue.containsKey('Priority'))
                caseHeader.Priority = MapofPickListDefValue.get('Priority');
            if(MapofPickListDefValue.containsKey('Origin')) 
                caseHeader.Origin = MapofPickListDefValue.get('Origin');
            if(MapofPickListDefValue.containsKey('Type')) 
                caseHeader.Type = MapofPickListDefValue.get('Type');
        }
        if(AllSubModuleSettings.get('SET008') != null && AllSubModuleSettings.get('SET008').toLowercase()=='true')
            caseHeader.SVMXC__Perform_Auto_Entitlement__c = true;
        else
            caseHeader.SVMXC__Perform_Auto_Entitlement__c = false;
        
      }
     catch(Exception e)
     {
         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
     }
     try
       {
            fieldMapSetting = settings.SVMX_getFieldMapping(mapId); 
            souObjFieldNames = '';
            for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
               if(souObjFieldNames.length() > 0) 
               { 
                  souObjFieldNames += ', '; 
               }
               if(fld.SVMXC__Source_Field_Name__c != null) souObjFieldNames += fld.SVMXC__Source_Field_Name__c;
            }
            SOQLHeader = '  SELECT '+souObjFieldNames+' FROM SVMXC__Installed_Product__c where Id=:IBId'; //\''+IBId+'\'(commented by amar on 18/2/10 3:15 pm becasue of Security Review)
            souObjRec = Database.query(SOQLHeader);
            for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
                     String targetFieldName = fld.SVMXC__Target_Field_Name__c;                    
                     String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                     Object souFldVal;

                     if(sourceFieldName != null )
                     souFldVal = souObjRec.get(sourceFieldName);
                    
                     if(souFldVal != null)
                     {
                          caseHeader.put(targetFieldName, souFldVal);
                     }
                   
            }
            if(SelectedRT != System.Label.IPRD003_TAG005)
                caseHeader.put('RecordtypeId',selectedRT);
             
             
           
       }    
       catch(Exception e)
       {
          ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
       }
                
 }



//*******************************************************All Getter & Setter Methods.....*****************************************//
   
  public String getIBname()
  { 
      
      If(IBId != null)
      { 
        List<String> queryFields = new List<String> {'name', 'Id'};
        
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, System.Label.COMM001_TAG142 ) );                    
            return null;
        }
        //SDL-SVMX-READ-FLS-ENFORCED 
        iprd = [select id,name from SVMXC__Installed_Product__c where id =: IBId]; 
        return iprd.name;
      }
      else
      {
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG009())); 
        return null;
      }
      
  } 
  public Case getcaseHeader(){return caseHeader;}
  public String getTAG001() {return System.Label.IPRD003_TAG001;}      // Create Case For
  public String getTAG002() {return System.Label.IPRD003_TAG002;}      // Create Case 
  public String getTAG003() {return System.Label.IPRD003_TAG003; }      // Cancel 
  public String getTAG004() {return System.Label.IPRD003_TAG004; }      //Select Case Record Type
  public String getTAG005() {return System.Label.IPRD003_TAG005; }      // Default
  public String getTAG008() {return System.Label.IPRD003_TAG008; }      // Error msg for setting & tags
  public String getTAG009() {return System.Label.IPRD003_TAG009; }      //Error Msg
  public String getTAG010() {return System.Label.IPRD003_TAG010; }      // Case Help
  public String getTAG011() {return System.Label.IPRD003_TAG011; }      // Case Help
  public String getHLPURL() {return System.Label.IPRD003_HLPURL;}//System.Label.IPRD003_HLPURL;}
  
///*******************************************************Methods for selecting the record type.....*****************************************//
  
  
  public List<selectoption> getRecordType() 
    {
      return options;
    }
    
    public String getSelectedRT()
    {
        return SelectedRT;
    }
    public void setSelectedRT(String s)
    {
        this.SelectedRT = s;
    }
    
   
//*****************************************************Method for display error message....**********************************************//    
    
    public Boolean getIsDisplay()
    {
        isdisplay = false;
        if(IBId == null)
        {
          isdisplay = false;
          return isdisplay;
        }
        else
        {
          isdisplay = true;
          return isdisplay;
        }
    }
    
   
//*****************************************************all PageReference Methods....**********************************************//
   public PageReference DoCancel() 
    {
        if(IBId == null)
        {
            PageReference homepage = new PageReference('/'+ 'home/home.jsp');
            return homepage;
        }
        
        PageReference newPage = new PageReference('/' + IBId);
        return newPage;
    }
    public PageReference CreateCase() 
    {
      try
      {  
        if(SelectedRT != System.Label.IPRD003_TAG005)
                caseHeader.put('RecordtypeId',selectedRT);
                
        //insert caseHeader;
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( caseHeader, COMM_SecurityUtils.Access.Createable ) ) {
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert caseHeader;
        } else {
            btnisdisabled = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
            return null;
        }
         PageReference CasePage = new PageReference('/' + caseHeader.Id);
         btnisdisabled = true;
         return CasePage;
      }
      catch(exception e)
      {
        btnisdisabled = false;
         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
      }
     
       return null;
    }


}