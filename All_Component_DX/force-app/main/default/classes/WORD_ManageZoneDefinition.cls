global with sharing class WORD_ManageZoneDefinition
{ 
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/
    
    public static  list<SVMXC__Service_Order__c> lstWorkOrder{ get; set; }
    public string strSelectedTerritory =''; 
    public string getstrSelectedTerritory(){return strSelectedTerritory;}  
    public void setstrSelectedTerritory(string strval) {strSelectedTerritory = strval;} 
    public string strSelectedWOField {get;set;}     
    public string strLocalDateFormat{get;set;}   
    public static string strAddress { get; set; }
    public list<SVMXC__Service_Zone__c > lstZone = new list<SVMXC__Service_Zone__c >();   
    public list<SelectOption> lstTerritory = new List<SelectOption>();
    public list<SelectOption> getlstTerritory(){return lstTerritory;}
    public static List<SVMXC__Territory_Coverage__c> lstTerritoryCoverage = new List<SVMXC__Territory_Coverage__c>();
    public list<selectoption> lstWOfield = new List<selectoption>(); 
    public list<selectoption> getlstWOfield() {return lstWOfield;}
    public class latLng
    {
        public Double lat;
        public Double lng;
    }
    
    public class Polygon
    {
        public string id;
        public string name;
        public list<latLng> latLng ; 
        public string fillColor;
        public boolean clickable;
    }
    
    
    public class Circle
    {
        public string id;
        public string name;
        public latLng center;   
        public Double radius;   
        public string fillColor;
        
    }
    
    public class Rectangle
    {
        public string id;
        public string name;
        public latLng ne;   
        public latLng sw;   
        public string fillColor;        
    }
    
    //----------------------------------------- Constructor -------------------------------------------
    public WORD_ManageZoneDefinition()    
    {             
        populatePicklists();
        DCON_Utils objDCON_Utils = new DCON_Utils();
        strLocalDateFormat = objDCON_Utils .SVMX_getLocalDateFormat();
        strLocalDateFormat = strLocalDateFormat.toLowerCase();
        strLocalDateFormat = strLocalDateFormat.replace('yyyy','yy');
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().get('id') != null)
        {
            String strMode = System.currentPageReference().getParameters().get('id');
            system.debug(logginglevel.warn,'  strMode  '+strMode);
           
                strSelectedTerritory = strMode;
        }
    }
    //-------------------------------------Method to Populate Picklist -----------------------------------------------------
    public void populatePicklists()
    {
        lstWOfield.clear();
        lstWOfield.add(new SelectOption(getTAG001(),getTAG001()));
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = SVMXC__Service_order__c.SObjectType.getDescribe().fields.getMap();                        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if( f.getType().name() == 'DATETIME' || f.getType().name() == 'DATE')
                lstWOfield.add(new SelectOption(f.getName(),f.getLabel())); 
        }  
         if(!lstWOfield.isempty())
            lstWOfield = sortingSelectOption(lstWOfield);         

        objfieldMap.clear();
    }
    //---------------------------------------Method to retrive WO on specified date   --------------------------------------
    
    @RemoteAction
    global static list<SVMXC__Service_Order__c> GetWO(String FromDate, String ToDate, String StrWOFldTerrId)
    {
        lstWorkOrder = new list<SVMXC__Service_Order__c>();
        DCON_Utils objDCON_Utils = new DCON_Utils();
        string strLocalDateFmt = objDCON_Utils .SVMX_getLocalDateFormat();
        list<SVMXC__ServiceMax_Processes__c> lstDispPro = new list<SVMXC__ServiceMax_Processes__c>();
        list<String> lstWOFldTerrId = new list<String>();
        time startTime = Time.newInstance(00, 00, 00, 00);
        time endtime = Time.newInstance(23, 59, 59, 60);
        if(FromDate != null && ToDate  != null &&  StrWOFldTerrId != null && FromDate != '' && ToDate  != '' &&  StrWOFldTerrId != '')
        {
            datetime dtmFromDate =datetime.newInstance(date.valueof(FromDate),startTime);
            datetime dtmToDate =datetime.newInstance(date.valueof(ToDate),endtime);
            //string strStartDate = string.valueOf(dtmFromDate);
            //string strEndDate = string.valueOf(dtmToDate);
            dtmFromDate = datetime.valueOfGmt(dtmFromDate.format('yyyy-MM-dd HH:mm:ss'));
            dtmToDate = datetime.valueOfGmt(dtmToDate.format('yyyy-MM-dd HH:mm:ss'));
            system.debug(logginglevel.warn,'Start and end time  '+  dtmFromDate +'  '+ dtmToDate + '   ' + startTime + '   ' + endtime );  
           
            lstWOFldTerrId = StrWOFldTerrId.split(',');
            lstDispPro =  [Select SVMXC__Process__c From SVMXC__ServiceMax_Processes__c where SVMXC__Territory__c =: lstWOFldTerrId[1]  and SVMXC__Rule_Type__c ='Territory Access'];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug(logginglevel.warn,'DP For Selected Territory  '+ lstDispPro); //SVMXC__Dispatch_Process__c 
            system.debug(logginglevel.warn,'WO field to be Queried  '+  lstWOFldTerrId[0] );  
            
            String strQuerystring = '';
            if(lstDispPro != null && lstDispPro.size() > 0)
            {
                strQuerystring = 'SELECT SVMXC__Latitude__c,SVMXC__Longitude__c FROM SVMXC__Service_Order__c where '+ lstWOFldTerrId[0] +' >=: dtmFromDate and ' + lstWOFldTerrId[0] + ' <=: dtmToDate and SVMXC__Dispatch_Process__c = \''+lstDispPro[0].SVMXC__Process__c+'\'';
            }
            else
                strQuerystring = 'SELECT SVMXC__Latitude__c,SVMXC__Longitude__c FROM SVMXC__Service_Order__c where '+ lstWOFldTerrId[0] +' >=: dtmFromDate and ' + lstWOFldTerrId[0] + ' <=: dtmToDate';
            system.debug(logginglevel.warn,'Query String  '+ strQuerystring);     
            lstWorkOrder = database.query(strQuerystring);
            system.debug(logginglevel.warn,'List of WO  '+ lstWorkOrder);     
        }
        return lstWorkOrder;
        
    }
    // -------------------------------------  Method to save zone details for specific territory -------------------------
    @RemoteAction
    global static void SaveZones(String idTerritory, String strPolygonLyt, String strCirclelyt,String strRectangleLyt, String strZoneidDelete)
    {
        WORD_ManageZoneDefinition objZoneDef = new WORD_ManageZoneDefinition();
        list<SVMXC__Service_Zone__c > lstZonetoupdate = new list<SVMXC__Service_Zone__c >();
        list<SVMXC__Service_Zone__c > lstZonetoinsert = new list<SVMXC__Service_Zone__c >();
        list<Polygon> lstPolygon = new list<Polygon>();
        list<Circle> lstCircle = new list<Circle>();
        list<Rectangle> lstRectangle = new list<Rectangle>();
        list<string> lstZoneDelete = new list<string>();
        set<string> setZoneDelete = new set<string>();
        list<SVMXC__Service_Zone__c > lstZone = new list<SVMXC__Service_Zone__c >();
        system.debug(logginglevel.warn,'idTerritory   '+idTerritory);
        system.debug(logginglevel.warn,'strPolygonLyt   '+strPolygonLyt);
        system.debug(logginglevel.warn,'strCirclelyt   '+strCirclelyt);
        system.debug(logginglevel.warn,'strRectangleLyt   '+strRectangleLyt);
        system.debug(logginglevel.warn,'strZoneidDelete   '+strZoneidDelete);
        map<string,SVMXC__Service_Zone__c > mapZoneidRec = new map<string,SVMXC__Service_Zone__c >();
           
            //strPolygonLyt = strPolygonLyt.replace('\"[','[');
           // strPolygonLyt = strPolygonLyt.replace(']\"',']');
            lstPolygon = (List<Polygon>)JSON.deserialize(strPolygonLyt, List<Polygon>.class); 
            lstCircle = (List<Circle>)JSON.deserialize(strCirclelyt, List<Circle>.class);
            lstRectangle = (List<Rectangle>)JSON.deserialize(strRectangleLyt, List<Rectangle>.class);
            system.debug(logginglevel.warn,'lstPolygon   '+lstPolygon);
            system.debug(logginglevel.warn,'lstCircle   '+lstCircle);
            system.debug(logginglevel.warn,'lstRectangle   '+lstRectangle);
            if(strZoneidDelete != null && strZoneidDelete != '')
                lstZoneDelete = strZoneidDelete.split(';');
            if(lstZoneDelete.size()>0)
                lstZoneDelete.remove(0);
            if(lstZoneDelete != null && lstZoneDelete.size() > 0)
                setZoneDelete.addall(lstZoneDelete);
            lstZoneDelete.clear();      
            if(setZoneDelete.contains(null))
                setZoneDelete.remove(null);
            lstZoneDelete.addall(setZoneDelete); 
            system.debug(logginglevel.warn,'List of zone IDs to delete  '+lstZoneDelete);
            lstZone = [Select id,  SVMXC__Zone_Type__c from SVMXC__Service_Zone__c  where SVMXC__Territory__c =: idTerritory];
            
            for(SVMXC__Service_Zone__c  objzone: lstZone)
                mapZoneidRec.put(objzone.id,objzone);            
            if(lstPolygon != null && lstPolygon.size()>0)
            {
                for(Polygon objPolygon:lstPolygon)
                {
                    if(objPolygon.id.length()>10)
                    {
                        SVMXC__Service_Zone__c  objZonePolygon = new SVMXC__Service_Zone__c ();
                        if(mapZoneidRec.containskey(objPolygon.id))
                        {
                            objZonePolygon  = mapZoneidRec.get(objPolygon.id);  
                            objZonePolygon.SVMXC__Zone_Name__c = objZoneDef.SpecialCharParser(String.valueof(objPolygon.name));
                            system.debug(logginglevel.warn,'Zone name  '+ objZonePolygon.SVMXC__Zone_Name__c);                  
                            objZonePolygon.SVMXC__Zone_Definition__c = JSON.serialize(objPolygon);                  
                            lstZonetoupdate.add(objZonePolygon);
                        }
                    }
                    else
                    {
                      
                        SVMXC__Service_Zone__c  objZonePolygon = new SVMXC__Service_Zone__c ();
                        objZonePolygon.SVMXC__Zone_Name__c = objZoneDef.SpecialCharParser(String.valueof(objPolygon.name));
                        system.debug(logginglevel.warn,'Zone name  '+ objZonePolygon.SVMXC__Zone_Name__c);
                        objZonePolygon.SVMXC__Zone_Type__c = 'Polygon';      
                        objZonePolygon.SVMXC__Zone_Definition__c = JSON.serialize(objPolygon);
                        objZonePolygon.SVMXC__Territory__c = idTerritory;
                        lstZonetoinsert.add(objZonePolygon);
                    }
                }
            }
            if(lstCircle != null && lstCircle.size()>0)
            {
                for(Circle objCircle:lstCircle)
                {
                    if(objCircle.id.length()>10)
                    {   
                        SVMXC__Service_Zone__c  objZoneCircle = new SVMXC__Service_Zone__c ();
                        if(mapZoneidRec.containskey(objCircle.id))
                        {
                            objZoneCircle   = mapZoneidRec.get(objCircle.id);   
                            objZoneCircle.SVMXC__Zone_Name__c = objZoneDef.SpecialCharParser(String.valueof(objCircle.name));   
                            system.debug(logginglevel.warn,'Zone name  '+ objZoneCircle.SVMXC__Zone_Name__c);                 
                            objZoneCircle.SVMXC__Zone_Definition__c = JSON.serialize(objCircle);                    
                            lstZonetoupdate.add(objZoneCircle);
                        }
                    }
                  else
                  {                    
                        SVMXC__Service_Zone__c  objZoneCircle = new SVMXC__Service_Zone__c ();
                        objZoneCircle.SVMXC__Zone_Name__c =  objZoneDef.SpecialCharParser(String.valueof(objCircle.name));  
                        system.debug(logginglevel.warn,'Zone name  '+ objZoneCircle.SVMXC__Zone_Name__c); 
                        objZoneCircle.SVMXC__Zone_Type__c = 'Circle';
                        objZoneCircle.SVMXC__Zone_Definition__c = JSON.serialize(objCircle);
                        objZoneCircle.SVMXC__Territory__c = idTerritory;
                        lstZonetoinsert.add(objZoneCircle);
                    }   
                }
            }
            if(lstRectangle != null && lstRectangle.size()>0)
            {
                for(Rectangle objRectangle:lstRectangle)
                {
                    if(objRectangle.id.length()>10)
                    {
                       SVMXC__Service_Zone__c  objZoneRectangle = new SVMXC__Service_Zone__c ();
                        if(mapZoneidRec.containskey(objRectangle.id))
                        {
                            objZoneRectangle    = mapZoneidRec.get(objRectangle.id);
                            objZoneRectangle.SVMXC__Zone_Name__c =  objZoneDef.SpecialCharParser(String.valueof(objRectangle.name));
                            system.debug(logginglevel.warn,'Zone name  '+ objZoneRectangle.SVMXC__Zone_Name__c); 
                            objZoneRectangle.SVMXC__Zone_Definition__c = JSON.serialize(objRectangle);                  
                            lstZonetoupdate.add(objZoneRectangle);
                        }
                    }
                     else
                     {
                        SVMXC__Service_Zone__c  objZoneRectangle = new SVMXC__Service_Zone__c ();
                        objZoneRectangle.SVMXC__Zone_Name__c = objZoneDef.SpecialCharParser(String.valueof(objRectangle.name));
                        system.debug(logginglevel.warn,'Zone name  '+ objZoneRectangle.SVMXC__Zone_Name__c); 
                        objZoneRectangle.SVMXC__Zone_Type__c = 'Rectangle';
                        objZoneRectangle.SVMXC__Zone_Definition__c = JSON.serialize(objRectangle);
                        objZoneRectangle.SVMXC__Territory__c = idTerritory;                 
                        lstZonetoinsert.add(objZoneRectangle);
                    }
                   
                }
            
            }
            if(lstZonetoinsert.Size()>0) {
            	if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstZonetoinsert, COMM_SecurityUtils.Access.Createable)){	//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert lstZonetoinsert;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            
            if(lstZonetoupdate.Size()>0){
                //update lstZonetoupdate;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstZonetoupdate, COMM_SecurityUtils.Access.Updateable)){	//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update lstZonetoupdate;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            lstZone.clear();
            if(lstZoneDelete.size()>0)
                lstZone = [Select id  from SVMXC__Service_Zone__c  where id in : lstZoneDelete];
            if(lstZone.Size()>0) {
            	if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Service_Zone__c') ){		//SDL-SVMX-DELETE-FLS-ENFORCED
				   delete lstZone;
				} else {
				   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
				}  
            }
    }
    //------------------------------- To get the Coverage details ie address  for specific territory -----------------------
      @RemoteAction
    global static string getOrganizationAddress() 
    {   string strOrgAddress = '';
        list<Organization> lstOrganization = new list<Organization>();
        lstOrganization = [Select Street, State, PostalCode,Country,  City From Organization ];
        
        if(lstOrganization != null && lstOrganization.size() > 0)
        {
            if(lstOrganization[0].Street != null)
                strOrgAddress = lstOrganization[0].Street ;
            if(lstOrganization[0].City  != null)
                strOrgAddress = lstOrganization[0].City  ;
            if(lstOrganization[0].State  != null)
                strOrgAddress = lstOrganization[0].State  ;
            if(lstOrganization[0].Country  != null)
                strOrgAddress = lstOrganization[0].Country  ;
            if(lstOrganization[0].PostalCode  != null)
                strOrgAddress = lstOrganization[0].PostalCode  ;
             
        }
        return strOrgAddress;
    }
    @RemoteAction
    global static string getAddress(String strSelectedTerritoryval) 
    {
        System.debug(logginglevel.warn,'Territory selected  ' +strSelectedTerritoryval);
        string city,state,country,zip;
        city = '';
        state = '';
        country = '';
        zip = '';
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Territory_Coverage__c',new List<String>{'id','SVMXC__Type__c','SVMXC__Value__c'}, COMM_SecurityUtils.Access.Accessible)){
            lstTerritoryCoverage =[Select id, SVMXC__Type__c, SVMXC__Value__c from SVMXC__Territory_Coverage__c where SVMXC__Territory__c =: strSelectedTerritoryval];
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            return null;
        }
        for(SVMXC__Territory_Coverage__c objTerCov: lstTerritoryCoverage)
        {
            if(objTerCov.SVMXC__Type__c == 'City')
            {
                if(objTerCov.SVMXC__Value__c != '' && objTerCov.SVMXC__Value__c != null)
                   city = objTerCov.SVMXC__Value__c;
            }
            if(objTerCov.SVMXC__Type__c == 'State')
            {
                if(objTerCov.SVMXC__Value__c != '' && objTerCov.SVMXC__Value__c != null)
                    state = objTerCov.SVMXC__Value__c;
                
            }
            if(objTerCov.SVMXC__Type__c == 'Country')
            {
                if(objTerCov.SVMXC__Value__c != '' && objTerCov.SVMXC__Value__c != null)
                    country = objTerCov.SVMXC__Value__c;
            }
            if(objTerCov.SVMXC__Type__c == 'Zip')
            {
                if(objTerCov.SVMXC__Value__c != '' && objTerCov.SVMXC__Value__c != null)
                    zip = objTerCov.SVMXC__Value__c;
            }
        }
        
            strAddress = city;
            if(state != '' && state != null)
            {
                if(strAddress != null && strAddress != '')
                    strAddress = strAddress + ', ' + state;
                else
                    strAddress = state;
            }   
            if(country != '' && country != null)
            {
                if(strAddress != null && strAddress != '')
                    strAddress = strAddress + ', ' + country;
                else
                    strAddress = country;
            }
            if(zip != '' && zip != null)
            {
                if(strAddress != null && strAddress != '')
                    strAddress = strAddress + ', ' + zip;
                else
                    strAddress = zip;
            }
        System.debug(logginglevel.warn,'Address  '+strAddress);
        return strAddress;
    }
    //-----------------------------------Method to get Zone details for selected Territory  --------------------------
    @RemoteAction
    global static string getZones(string idTerritory)
    {
        list<SVMXC__Service_Zone__c > lstZone = new list<SVMXC__Service_Zone__c >();
        String strZoneLayout ;
        String strZonePolyLyt ;
        String strZoneCirLyt ;
        String strZoneRectLyt ;
        strZoneLayout='';
        strZonePolyLyt='';
        strZoneCirLyt='';
        strZoneRectLyt='';
        System.debug(logginglevel.warn,' Selected Id val  '+idTerritory);
        lstZone = [Select id, SVMXC__Zone_Definition__c, SVMXC__Zone_Type__c from SVMXC__Service_Zone__c  where SVMXC__Territory__c=:idTerritory ];
        for(SVMXC__Service_Zone__c  objZone:lstZone)
        {
            
            if(objZone.SVMXC__Zone_Type__c == 'Polygon')
            {
                String strLayout = objZone.SVMXC__Zone_Definition__c; 
                Polygon objplyg = (Polygon)JSON.deserialize(strLayout, Polygon.class);
                objplyg.id = objZone.id;
                if(strZonePolyLyt != '')
                strZonePolyLyt = strZonePolyLyt + ',' + JSON.serialize(objplyg);
                else
                strZonePolyLyt =JSON.serialize(objplyg);
                System.debug(logginglevel.warn,'Polygon  '+objZone.SVMXC__Zone_Definition__c);
            }
            if(objZone.SVMXC__Zone_Type__c == 'Circle')
            {
                String strLayout = objZone.SVMXC__Zone_Definition__c; 
                Circle  objCircle = (Circle)JSON.deserialize(strLayout, Circle.class);
                objCircle.id = objZone.id;
                if(strZoneCirLyt != '')
                 strZoneCirLyt = strZoneCirLyt + ',' + JSON.serialize(objCircle);
                else
                strZoneCirLyt = JSON.serialize(objCircle);
            }
            if(objZone.SVMXC__Zone_Type__c == 'Rectangle')
            {   
                String strLayout = objZone.SVMXC__Zone_Definition__c; 
                Rectangle   objRectangle = (Rectangle)JSON.deserialize(strLayout, Rectangle.class);
                objRectangle.id = objZone.id;
            
                if(strZoneRectLyt != '')              
                    strZoneRectLyt = strZoneRectLyt + ',' + JSON.serialize(objRectangle);
                else
                strZoneRectLyt = JSON.serialize(objRectangle);
            }
        }
        strZoneLayout ='['+ strZonePolyLyt +']' + '+' + '['+strZoneCirLyt + ']' + '+' + '[' + strZoneRectLyt +']';
        system.debug(logginglevel.warn,'Zones for selected territory  ' + strZoneLayout);
        return strZoneLayout;
        
    }
    //------------------------------------- Method to sort the Options of the PickList -------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList)
        {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys)
           resultList.addAll(tempLst.get(key)); 
        
        return resultList;
    }
    
      public String SpecialCharParser(String s)
    {
        System.debug(logginglevel.warn,'input string :'+s);
        if(s!=NULL)
        {
             s = s.replace('&','&#38;');
            s = s.replace('\'','&#39;');
            s = s.replace('<','&#60;');
            s = s.replace('>','&#62;');
            s = s.replace('\n',' ');
            // = s.replace('\'','&apos;');  
System.debug(logginglevel.warn,'After conversioninput string :'+s);
            return s;
        }
        return NULL;
    }
     public  Void onChangeTerritory1() { }
    //------------------------------------- Getter methods for the custom labels ----------------------------------
    public String getTAG001() {return system.label.COMM002_TAG005;}
    public String getTAG002() {return system.label.COMM001_TAG057;}
      
    
}