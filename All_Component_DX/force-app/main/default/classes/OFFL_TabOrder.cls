public with sharing class OFFL_TabOrder 
{

SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
//public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('OFFL002');

public String getTAG038() {return system.label.OFFL002_TAG038;}//Edit Tab Order';}
public String getTAG039() {return system.label.OFFL002_TAG039;}//Done';}
public String getTAG040() {return system.label.OFFL002_TAG040;}//Cancel';}
public String getTAG041() {return system.label.OFFL002_TAG041;}//Top';}
public String getTAG042() {return system.label.OFFL002_TAG042;}//Up';}
public String getTAG043() {return system.label.OFFL002_TAG043;}//Down';}
public String getTAG044() {return system.label.OFFL002_TAG044;}//Bottom';}
public String getTAG045() {return system.label.OFFL002_TAG045;}//Loading..';}

//========================================= Settings =============================================//
public String getSET001() {return '/apex/OFFL_TabOrder';}
public String getSET002() {return '/apex/OFFL_ManageDataSets';}
public String getSET003() {return '/apex/OFFL_OfflineProfiles';}
public String getSET004() {return '/apex/OFFL_ManageOfflineProfile';}

    public String ProfId = system.currentPageReference().getParameters().get('pid');
    private final Offline_Object__c obj;
    public string ProfileName;
    public boolean flag=false;
    public string[] items = new String[]{};
    public string[] SelectedItems;
    public List<SelectOption> options = new List<SelectOption>();
    public List<Offline_Object__c> OfflineObjlst = new List<Offline_Object__c>();
    public Map<string,Integer> MyMap = new  Map<string,Integer>();
    public integer selectedIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    public Map<String, Schema.SObjectType> allObjs;
            
    
    
    public OFFL_TabOrder(ApexPages.StandardController stdController){
        this.obj = (Offline_Object__c)stdController.getRecord();
        getOfflineObjlst();
        allObjs = Schema.getGlobalDescribe();
    }
    
    
    public string getProfileName(){
        user u= [Select Profile.Name, ProfileId From User where Id=:userinfo.getuserid()];
        ProfileName = u.Profile.Name;       
        return ProfileName;
    }
    
    
    public List<Offline_Object__c> getOfflineObjlst(){
        if(OfflineObjlst.size()>0){ 
            OfflineObjlst = OfflineObjlst;
        }
        else{
            OfflineObjlst = [Select SVMXC__Tab_Order__c, SVMXC__Select__c, SVMXC__Ownership_Limit__c, SVMXC__Object_Name__c, SVMXC__Allow_Upload__c, SVMXC__Allow_Tab__c, Id From SVMXC__Offline_Object__c where SVMXC__Offline_Profile__c=:ProfId and SVMXC__Allow_Tab__c=true order by SVMXC__Tab_Order__c];
            Map<String, Schema.SObjectType> allObjs;
            allObjs = Schema.getGlobalDescribe();
            
            /*for(integer a=0;a<OfflineObjlst.size();a++)
            {           
                string name = OfflineObjlst[a].SVMXC__Object_Name__c;
                Schema.SObjectType objT = allObjs.get(name);
                string s= objT.getDescribe().getLabel() ;
                system.debug('s........... '+s);
                OfflineObjlst[a].SVMXC__Object_Name__c = s;    
            }*/
            
        }
        return OfflineObjlst;
    }
    
    
    public  List<SelectOption> getoptions(){    
        options = new List<SelectOption>();            
        if (OfflineObjlst.Size() >0)
        {
            for(Offline_Object__c o:OfflineObjlst)
            {
                string name = o.SVMXC__Object_Name__c;                 
                 if(name.contains('SVMXC')==true){
                 	name = name.substring(7);
                 }                
                Schema.SObjectType objT = allObjs.get(name);                
                if (o.SVMXC__Object_Name__c != null){
                    options.add(new SelectOption(o.Id,objT.getDescribe().getLabel()));                	
                }
           }
        }        
        return options; 
    }
    
    
    public string[] getitems(){
        return items;
    }    
    public void setitems(string[] o){
        this.items=o;
    }
    
    
    public void shuffle(integer selIndex, boolean isTop ){
        Offline_Object__c temp;
            if(isTop){
                temp = OfflineObjlst[selIndex];
                
                for(integer j=selIndex;j>0;j--)
                {
                        OfflineObjlst[j] = OfflineObjlst[j-1];
                }
                OfflineObjlst[0] = temp;
               
            }else {
                temp = OfflineObjlst[selIndex];
                
                for(integer j=selIndex;j<OfflineObjlst.size()-1;j++)
                {
                        OfflineObjlst[j] = OfflineObjlst[j+1];
                }
                OfflineObjlst[OfflineObjlst.size()-1] = temp;

            }
    }
   
   
    public void UP(){    
        Offline_Object__c temp;
        
        for(integer j=0;j<OfflineObjlst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {               
                if(items[i]==OfflineObjlst[0].Id)
                {
                 OfflineObjlst[j] = OfflineObjlst[j];
                 break;
                }
                else if(items[i]==OfflineObjlst[j].Id)           
                {
                    temp = OfflineObjlst[j]; 
                    OfflineObjlst[j] = OfflineObjlst[j-1];
                    OfflineObjlst[j-1]=temp;                    
                    selectedIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    OfflineObjlst[selectedIndex-1].SVMXC__Tab_Order__c=selectedIndex-1;
                    OfflineObjlst[selectedIndex].SVMXC__Tab_Order__c = selectedIndex;
                }
            }
        }     
    }
     
     
    public void Down(){        
        Offline_Object__c temp;
        for(integer i=0;i<items.size();i++)
        {
            MyMap.Put(items[i],i);
        }
        
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<OfflineObjlst.size()-1;k++)
            {
                if(items[i]==OfflineObjlst[k].Id){
                    temp = OfflineObjlst[k];
                    OfflineObjlst[k] = OfflineObjlst[k+1];
                    OfflineObjlst[k+1]=temp;
                    selectedIndex = k;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    OfflineObjlst[selectedIndex+1].SVMXC__Tab_Order__c=selectedIndex+1;
                    OfflineObjlst[selectedIndex].SVMXC__Tab_Order__c = selectedIndex;
                    break;                         
                }
            }
            
        }   
    }
    
    public void Top(){
        Offline_Object__c temp;        
                
        for(integer j=OfflineObjlst.size()-1;j>0;j--)
        {           
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == OfflineObjlst[j].Id)            
                {
                    selectedIndex = j;
                    isUpAction = false;
                    isDownAction=false;
                    isTopAction=true;
                    isBottomAction=false;
                    shuffle(selectedIndex, true);                   
                }
            }
        }       
    }
    
    
    public void Bottom(){
        Offline_Object__c temp;

        for(integer j=0;j<OfflineObjlst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == OfflineObjlst[j].Id){
                    selectedIndex = j;
                    isUpAction = false;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=true;                    
                    shuffle(selectedIndex, false); 
                }
            }
        }       
    }
        
    
    public pagereference sel(){
        Offline_Object__c temp;
        double t;
        if(isUpAction){           
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OfflineObjlst, COMM_SecurityUtils.Access.Updateable ) ) {
                update OfflineObjlst;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }else if(isDownAction){            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OfflineObjlst, COMM_SecurityUtils.Access.Updateable ) ) {
                update OfflineObjlst;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }else if(isTopAction){
            for(integer i=0;i<OfflineObjlst.size();i++)
            {
                OfflineObjlst[i].SVMXC__Tab_Order__c=i;
            }                              
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OfflineObjlst, COMM_SecurityUtils.Access.Updateable ) ) {
                update OfflineObjlst;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }         
        }else if(isBottomAction){
            for(integer i=0;i<OfflineObjlst.size();i++)
            {
                OfflineObjlst[i].SVMXC__Tab_Order__c=i;
            }                              
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( OfflineObjlst, COMM_SecurityUtils.Access.Updateable ) ) {
                update OfflineObjlst;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        return cancel();
    }

    
    public pageReference cancel(){
      String url = '/';
      url =getSET004();
      //if(svmxSettingList.containsKey('SET004') == true) url =svmxSettingList.get('SET004');
      PageReference ManageOffPro = new PageReference(url);
      ManageOffPro.getparameters().put('pid',ProfId);
      ManageOffPro.setRedirect(true);
      return ManageOffPro;   
    }
}