public with sharing class CONF_EditObjectMappingDetails 
{
    public class wrapper 
        {
        public SVMXC__ServiceMax_Config_Data__c fldMapRec {get; set;}
        public String targetFldDesc {get; set;}
        public List<String> sourceFldsDesc {get; set;}
        public String targetFldName {get; set;}
        public String targetFldType {get; set;}
        public String targetFldLabel {get; set;}
        public String sourceFldName {get; set;}
        public List<SelectOption> sourceOptions = new List<SelectOption> ();
        public List<SelectOption> getsourceOptions() {  if(sourceOptions.size() == 0) sourceOptions.add(new SelectOption('--None--','--None--')); return sourceOptions;     }
    
        public wrapper(SVMXC__ServiceMax_Config_Data__c fMRec, String tFldDesc, List<String> sFldsDesc ,String none )
            {
            fldMapRec = fMRec;
            targetFldDesc = tFldDesc;
            sourceFldsDesc = sFldsDesc;
            List<String> tNameTypAr = new List<String>();
            tNameTypAr  = tFldDesc.split(':', 0); 
                targetFldName = tNameTypAr[0];
                if(tNameTypAr.size() >1)targetFldType = tNameTypAr[1];
                if(tNameTypAr.size() >2)targetFldLabel = tNameTypAr[2];
                String stNone = none;
                
            if(fMRec.SVMXC__Source_Field_Name__c != null)sourceFldName = fMRec.SVMXC__Source_Field_Name__c;
            else sourceFldName = stNone;
            
            //Loop and Create select Options of source Flds
            sourceOptions.add(new SelectOption(stNone,stNone));
            for(Integer i = 0; i < sFldsDesc.size();i++)
                {
                List<String> sNameTypAr = new List<String>();
                sNameTypAr  = sFldsDesc[i].split(':', 0); 
                String sFldName = '';
                if(sNameTypAr[0] != null)sFldName = sNameTypAr[0];
                if(sNameTypAr.size()>2)sourceOptions.add(new SelectOption(sFldName,sNameTypAr[2]));
                }
            }
        }        
    public Boolean showPageError =false;
    public Boolean getshowPageError() { return showPageError;}
    public void setshowPageError(Boolean b){ this.showPageError = b;}
    
    public String objMapId  = null; //ObjMapping ID
    public String sMode;
    public String fMapRT;
    public String oMapRT;    
    public Boolean readOnly;
    public Boolean readWrite;
    public Boolean disAllowChangeObj;
    public SVMXC__ServiceMax_Processes__c oMaprec = new SVMXC__ServiceMax_Processes__c();
    public List<SVMXC__ServiceMax_Config_Data__c> fldMapRecs  =  new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<wrapper> wrapFldMap = new List<wrapper>();   
    public Map<String, Schema.SObjectType> allObjs ;
    public Map<String,String> mapObjApiLocalName = new Map<String,String>();
    public Map<String,String> mapFldApiLocalName = new Map<String,String>();
    
        public String sourceObj ='';
        public String getsourceObj(){ return sourceObj;}
        public void setsourceObj(String s) {this.sourceObj =s;}
        public List<SelectOption> sourceObjOptions = new List<SelectOption>();
        public List<SelectOption> getsourceObjOptions() 
            {  
            return sortingSelectOption(sourceObjOptions);
            }
        public String targetObj = '';
        public String gettargetObj(){ return targetObj;}
        public void settargetObj(String s) {this.targetObj =s;}
        
        public List<SelectOption> targetObjOptions = new List<SelectOption>();
        public List<SelectOption> gettargetObjOptions() 
            { 
            
            return sortingSelectOption(targetObjOptions);     
            }
            
        public String targetRT{get; set;}
        public List<SelectOption> targetRTOptions = new List<SelectOption>();
        public List<SelectOption> gettargetRTOptions() 
            {  
            return sortingSelectOption(targetRTOptions);     
            }
   
        
        public  SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        
        public  SVMXC.COMM_Utils_ManageSettings commUtilSettings = new SVMXC.COMM_Utils_ManageSettings();
        public Map<String, String> svmxSettingList = commUtilSettings.SVMX_getSettingList('CONF012');

   
    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> so){
        SelectOption tempObj;               
               // System.debug('before Sorting:'+so);
                Integer size = so.size();
                Integer i,j;
                for(i=0;i<size;i++){
                  for(j=i+1;j<size;j++){
                      Integer result=so[i].getLabel().compareTo(so[j].getLabel());
                    //  System.debug('Result:'+result);
                        if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                            tempObj = so[j];
                            so[j] = so[i];
                            so[i] = tempObj;
                        }
                    }
                }
                return so;

    }
    
    public Boolean getreadOnly() 
        { 
        if(sMode == 'sView' )
            readOnly = true;
        else
            readOnly = false;
        return readOnly;
        }
    public Boolean getreadWrite() 
        { 
        if(sMode == 'sEdit' || sMode == 'SNew' || sMode == 'sClone' )
            readWrite = true;
        else
            readWrite = false;
        return readWrite;
        }
    public Boolean getdisAllowChangeObj() 
        { 
        if(sMode == 'sEdit' ||  sMode == 'sView')
            disAllowChangeObj = true;
        else
            disAllowChangeObj = false;
        return disAllowChangeObj;
        }

//GM: 18Aug10: Apply License Check: 
 public boolean isEntLicense =true;
 public Map<String, Boolean> perStdObjMap =  new  Map<String, Boolean>();
    
    ////Constructor        
        public CONF_EditObjectMappingDetails()
        {
            try
            {
            	//GM: 18Aug10: Apply License Check: 
            	isEntLicense = utils.SVMX_isEnterpriseLicense(); //Check if isenterprise
            	if(!isEntLicense) perStdObjMap = utils.SVMX_getPermittedStandardObjectList(); //populate peritted objects to local map
            	
            allObjs = Schema.getGlobalDescribe();
            List<Schema.SObjectType> listObjNmae = allObjs.values();
            

            objMapId = Apexpages.currentPage().getParameters().get('objMapId');  
            sMode = Apexpages.currentPage().getParameters().get('sMode'); 
            
            fMapRT = getFMapRecordTypes().Id;
            oMapRT = getOMapRecordTypes().Id;
            if(sMode == 'sNew')
                {
                SVMXC__ServiceMax_Processes__c newOMaprec = new SVMXC__ServiceMax_Processes__c(
                                                            RecordTypeId = oMapRT,
                                                            SVMXC__ACTIVE__C = true,
                                                            SVMXC__IsStandard__c = false);
                oMaprec = newOMaprec;
                sourceObjOptions.add(new SelectOption(getTAG023(),getTAG023())); //adding --None--  to source object options
                sourceObj = getTAG023();
                targetObj = getTAG023();
                }
            else{
                //Changed to the static Query due to security review 2010 on 22/10/2010 by amar
                //String  soqlStrOMap = '  Select Id, SVMXC__Target_Record_Type__c, SVMXC__Active__c,SVMXC__Record_Type_Name__c,SVMXC__IsStandard__c,RecordTypeId,SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c   where Id =\''+objMapId+'\'';
                //oMaprec = Database.query(soqlStrOMap); 
                //String  soqlStrfldMap = '  Select RecordTypeId,SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__MapID__c, SVMXC__Active__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =\''+objMapId+'\'';  
                //fldMapRecs = Database.query(soqlStrfldMap);
				
				oMaprec = [Select Id, SVMXC__Target_Record_Type__c, SVMXC__Active__c,SVMXC__Record_Type_Name__c,SVMXC__IsStandard__c,RecordTypeId,SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c   where Id =: objMapId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
				fldMapRecs = [Select RecordTypeId,SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__MapID__c, SVMXC__Active__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: objMapId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
				
				
					
                sourceObj = oMaprec.SVMXC__Source_Object_Name__c;
                targetObj = oMaprec.SVMXC__Target_Object_Name__c;
                targetRT = oMaprec.SVMXC__Target_Record_Type__c;
                }
            if(sMode == 'sClone')
                {
                //Clone Obj Map Rec
                SVMXC__ServiceMax_Processes__c cloneOMap = oMaprec.clone(false,true); //Clone the existing line
                cloneOMap.put('SVMXC__IsStandard__c',false);
                oMaprec =cloneOMap; //Swap the oMap with the cloned rec
                //Clone Fld Map Recs
                List<SVMXC__ServiceMax_Config_Data__c> cloneFldMapRecs  =  new List<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Config_Data__c fMRec : fldMapRecs)
                    {
                    SVMXC__ServiceMax_Config_Data__c cloneFMRec = fMRec.clone(false,true); //Clone the existing line
                    cloneFldMapRecs.add(cloneFMRec);
                    }
                fldMapRecs = cloneFldMapRecs; //Swap the field Mapping recs
                }
            //Do the following For all Modes    
            for(Schema.SObjectType lON : listObjNmae) //Loop List of all Objects and describe each
                {
                Schema.DescribeSObjectResult D = lON.getDescribe();
                if(D.isAccessible() == true && D.isCreateable() == true && D.isCustom() == true )
                    {
                    mapObjApiLocalName.put(D.getName(),D.getLocalName());
                    sourceObjOptions.add(new SelectOption(D.getName(),D.getLabel())); //Builing select Options for source object
                    }
                }
            //Adding standard objs 
            	//GM: 18Aug10: Apply License Check before adding std objects
            	//1. Check if org is Enterprise? if not then check in permitted object list before adding here...
            if(perStdObjMap.containsKey('Case') || isEntLicense) sourceObjOptions.add(new SelectOption('Case','Case'));
            if(perStdObjMap.containsKey('Account') || isEntLicense) sourceObjOptions.add(new SelectOption('Account','Account'));
            if(perStdObjMap.containsKey('Product2') || isEntLicense) sourceObjOptions.add(new SelectOption('Product2','Product'));
            if(perStdObjMap.containsKey('Case') || isEntLicense) mapObjApiLocalName.put('Case','Case');
            if(perStdObjMap.containsKey('Account') || isEntLicense) mapObjApiLocalName.put('Account','Account');
            if(perStdObjMap.containsKey('Product2') || isEntLicense) mapObjApiLocalName.put('Product2','Product2');
            
            if(sMode == 'sNew') 
                {
                targetRTOptions.add(new SelectOption(getTAG025(),getTAG025())); //adding default
                targetRT = getTAG025(); //adding a default
                }
            else{
                buildRecordType();
                targetRT = oMaprec.SVMXC__Target_Record_Type__c;
                }
            
            if(targetObj != null && targetObj.length() >0)buildWrapperFldMapRecs();
            if(sourceObjOptions.size() == 0){sourceObjOptions.add(new SelectOption(getTAG023(),getTAG023()));}
                
            targetObjOptions = sourceObjOptions;
            }
            catch (Exception e) { ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag016(), e.getMessage()));}
        }
        
  		
        public void buildRecordType()
            {
                targetRTOptions.clear();
                ////if(targetObj != null)
                    ////{
                    List<RecordType> oMapRTypes = new List<RecordType>();
                    oMapRTypes = getOMapRecordTypes(targetObj);
                    if(oMapRTypes.size() >0){
                    for(RecordType oRT : oMapRTypes)
                        {
                        targetRTOptions.add(new SelectOption(oRT.Id,oRT.Name));
                        }
                    }
                    else
                    targetRTOptions.add(new SelectOption(getTAG025(),getTAG025())); // adding a Default
                    ////}
            }
        public PageReference doValidateOMapRec()
            {
                if(sMode != 'sNew'){
                    if(mapObjApiLocalName.get(sourceObj) == null  ||  mapObjApiLocalName.get(targetObj) == null)
                        {
                            showPageError = true;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag016(),getTAG026())); //'Corresponding Object not avilable in the Org.'
                        }                    
                }
                else showPageError = false;
                return null;
            }                   
        public List<String> tFldDesc = new List<String>();
        public List<String> sFldDesc = new List<String>();
        public void buildWrapperFldMapRecs()
            {
                try{
                if(targetObj != null && sourceObj != null &&  sourceObj != getTag023() &&  targetObj != getTag023() && mapObjApiLocalName.get(targetObj) != null) 
                    {
                    wrapFldMap.clear();
                    tFldDesc = SVMX_descObjAndGetFieldMap(mapObjApiLocalName.get(targetObj));
                    ////if(sourceObj == targetObj) sFldDesc = tFldDesc;
                    ////else sFldDesc = SVMX_descObjAndGetFieldMap(mapObjApiLocalName.get(sourceObj));
                    sFldDesc = SVMX_descObjAndGetFieldMapAllFields(mapObjApiLocalName.get(sourceObj)); //Need to have all fields in source fld, thats why different mathod
                    
                    tFldDesc.sort();
                    ////Build Map of already Saved Records against the target-fldName //By Gm 19Aug10
                    Map<String,SVMXC__ServiceMax_Config_Data__c> tfldMapRecMap = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
                    for(SVMXC__ServiceMax_Config_Data__c fMapRec : fldMapRecs)  //check and find matching fldRec
                        {
                        	tfldMapRecMap.put(fMapRec.SVMXC__Target_Field_Name__c,fMapRec);
                        }
                    ////Build Map fldType and ListOf SFlds //By Gm 19Aug10
                    Integer indOfIdFldInSource ;
                    Map<String,List<String>> sfldTypeFldListMap = new Map<String,List<String>>();
                    for(Integer j=0; j<sFldDesc.size(); j++)                //Loop source Fld Def and add the sourceOptions
                            {
                            List<String> sNameTypAr = new List<String>();
                            sNameTypAr = sFldDesc[j].split(':', 0); 
                            String sFldName = sNameTypAr[0];
                            String sFldType = '';
                            sFldType= sNameTypAr[1]; 
                            List<String> fList = new List<String>();	
                            if(sfldTypeFldListMap.containsKey(sFldType)){
                            	fList = sfldTypeFldListMap.get(sFldType);
                            	fList.add(String.valueOf(sFldDesc[j]));
                            	sfldTypeFldListMap.put(sFldType,fList);
                            }
                            	
                            else{
                            	fList.add(String.valueOf(sFldDesc[j]));
                            	sfldTypeFldListMap.put(sFldType,fList);
                            }
                            if(sFldName == 'Id')
                                indOfIdFldInSource = j;
                            }
                            
                    
                    for(Integer i=0; i< tFldDesc.size(); i++)               //Loop target Fld Def 
                        {
                        List<String> tNameTypAr = new List<String>();
                        tNameTypAr = tFldDesc[i].split(':', 0); 
                        String tFldName = tNameTypAr[0];
                        String tFldType = '';
                        if(tNameTypAr.size() >1) tFldType = tNameTypAr[1];
                        
                        SVMXC__ServiceMax_Config_Data__c selFldMapRec = new SVMXC__ServiceMax_Config_Data__c();
						if (tfldMapRecMap.containsKey(tFldName)) selFldMapRec = tfldMapRecMap.get(tFldName);
                        
                        /* commented by Gm : 19Aug10
                        for(SVMXC__ServiceMax_Config_Data__c fMapRec : fldMapRecs)  //check and find matching fldRec
                            {
                            if(tFldName == fMapRec.SVMXC__Target_Field_Name__c) //Matching found
                                {
                                selFldMapRec = fMapRec; 
                                break;
                                }
                            }
                        */ 
                        List<String> sFlds = new List<String>();
                        if(sfldTypeFldListMap.containsKey(tFldType)) sFlds = sfldTypeFldListMap.get(tFldType); //Take it from map created outside this loop//Gm:19AUG10
                        //////Integer indOfIdFldInSource ;
                        ////system.debug('sFldDesc'+sFldDesc.size()+sFldDesc);
                        /* commented by Gm : 19Aug10
                        for(Integer j=0; j<sFldDesc.size(); j++)                //Loop source Fld Def and add the sourceOptions
                            {
                            List<String> sNameTypAr = new List<String>();
                            sNameTypAr = sFldDesc[j].split(':', 0); 
                            String sFldName = sNameTypAr[0];
                            String sFldType = '';
                            if(tNameTypAr.size() >1) 
                            	sFldType= sNameTypAr[1];
                            if(tFldType == sFldType) //Check if Type of Field is same/ add to Desc list
                                sFlds.add(sFldDesc[j]);

                            if(sFldName == 'Id')
                                indOfIdFldInSource = j;
                                
                                ////System.debug(sFldName + ' ZZZZZZZ '+ sFldDesc[j]);
                            }
                        */
                        List<String> fldTypeReffToAr = new List<String>();
                        if(tFldType != null && tFldType.length() >0 )
                            {
                            	if(tFldType.contains(';') == true )
                            	{
                                 	fldTypeReffToAr =  tFldType.split(';',0); //Seprate fldType and referenceTo  
	                            	if(fldTypeReffToAr.size() == 2 )
	                                    {
	                                    	String str1 = String.valueOf(fldTypeReffToAr[1]); 
	                                    	str1 = str1.replace('(',' ');
	                                    	str1 = str1.replace(')',' ');
	                                    	str1 = str1.trim();
                                            if(str1 == sourceObj) //mapObjApiLocalName.get(sourceObj)) //mapObjApiLocalName.get(sourceObj) //Check if Type of target Field is reference to source object then add 'Id' to the list
                                            {
                                             if(indOfIdFldInSource != null)sFlds.add(sFldDesc[indOfIdFldInSource]);
                                            }

	                                    }
                            	}
                            }
                        sFlds.sort();
                        wrapper tmpWrap; //for each target fld add one row in wrapper class
                        tmpWrap = new wrapper(selFldMapRec,tFldDesc[i],sFlds,getTAG023());
                        wrapFldMap.add(tmpWrap) ;
                        }
                    }
                }catch (Exception e) {ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag016(),e.getMessage()));}
            }
        
        public List<String> SVMX_descObjAndGetFieldMap(String objName)
            {
            ////System.debug('objNameobjNameobjNameAAAAAAAA: ' + objName);
            List<String> fldList = new List<String>();
            try
            {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            Schema.SObjectType objT = allObjs.get(objName) ;
            objfieldMap = objT.getDescribe().fields.getMap();

        
            for (String fieldKey : objfieldMap.keySet()) 
                {
                Map<String,String> fMap = new Map<String,String>();
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.isCreateable()  == true  && f.isUpdateable() == true && f.isCalculated() == false)
                    {
                    String nameTypeStr ='';
                    if(f.getType() == Schema.DisplayType.REFERENCE){
                    	////system.debug('AAAAAAAAA' +f.getName() + f.getReferenceTo());
                    	String refObjName = '';
                    	system.debug('ZZZZZZZZZ:' + refObjName);
                    	if (f.getReferenceTo() != null) refObjName = String.valueOf(f.getReferenceTo()[0]);
                    	if(utils.SVMX_isObjectCustom(refObjName) || perStdObjMap.containsKey(refObjName) || isEntLicense)
                    		nameTypeStr = f.getName() + ':' +f.getType() + ';' + f.getReferenceTo()+ ':' +f.getLabel() ; 
                    }
                    else if(f.getName() == 'CurrencyIsoCode') 
                    	nameTypeStr = f.getName() + ':' +f.getType() + '_CurrencyIsoCode'+ ':' +f.getLabel() ;
                    else 
                    	nameTypeStr = f.getName() + ':' +f.getType() + ':' +f.getLabel() ;
                    	
                    if(nameTypeStr != null && nameTypeStr.length() >0)fldList.add(nameTypeStr);
                    }
                }
            } catch(Exception e){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag016(), e.getMessage()));}
            return fldList;
            }
         
        public List<String> SVMX_descObjAndGetFieldMapAllFields(String objName)
            {
          ////System.debug('objNameobjNameobjNameBBBBBB: ' + objName);
            List<String> fldList = new List<String>();
            try
            {
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            Schema.SObjectType objT = allObjs.get(objName) ;
            objfieldMap = objT.getDescribe().fields.getMap();

        
            for (String fieldKey : objfieldMap.keySet()) 
                {
                Map<String,String> fMap = new Map<String,String>();
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.isAccessible ()  == true )
                    {
                    String nameTypeStr ='';
                    if(f.getType() == Schema.DisplayType.REFERENCE){
                    		nameTypeStr = f.getName() + ':' +f.getType() + ';' + f.getReferenceTo()+ ':' +f.getLabel() ; 
                    }
                    else if(f.getName() == 'CurrencyIsoCode') 
                    	nameTypeStr = f.getName() + ':' +f.getType() + '_CurrencyIsoCode'+ ':' +f.getLabel() ;
                    else 
                    	nameTypeStr = f.getName() + ':' +f.getType() + ':' +f.getLabel() ;
                    fldList.add(nameTypeStr);
                    }
                }
            } catch(Exception e){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag016(), e.getMessage()));}
            return fldList;
            }
        
        public SVMXC__ServiceMax_Processes__c getoMaprec(){
                return oMaprec ;
        } 
        public List<SVMXC__ServiceMax_Config_Data__c> getfldMapRecs(){
                return fldMapRecs;
        } 
        public List<wrapper> getwrapFldMap(){
                return wrapFldMap;
        } 
       public void setwrapFldMap(List<wrapper> w){
                    wrapFldMap = w;
            } 
            
        public PageReference SVMX_doSave() //Called on Save from VF Page
        {
                try
                {
                     Boolean res = SVMX_processSave();
                     if(res == true) {
                        String retURL = '/';
                        if(svmxSettingList.containsKey('SET001') == true)                  
                            retURL = svmxSettingList.get('SET001');                 
                        
                        PageReference scrn = new PageReference(retUrl);
                        scrn.setRedirect(true);
                        return scrn;
                     }
                     else return null;
                 }
                catch (Exception e) {ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag016(), e.getmessage())) ;return null;}
                
            return null;
        }
     public PageReference SVMX_doQuickSave() //Called on 'Quick Save' from VF page
    {
        Boolean res = SVMX_processSave();
        return null;
    }
    public Boolean SVMX_processSave() 
    {
        try
            {
            //Upsert objMap
                    if(oMaprec.SVMXC__MapID__c ==null ||oMaprec.SVMXC__Name__c == null){
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag016(),getTAG021()));
                        return false;
                    }
                
					
                    String  soqlStr = '  SELECT Id, Name FROM SVMXC__ServiceMax_Processes__c   where SVMXC__MapID__c=\''+String.escapeSingleQuotes(oMaprec.SVMXC__MapID__c)+'\'';  
                    List<SVMXC__ServiceMax_Processes__c> sizeToCheck = Database.query(soqlStr); 
                    if(sMode != 'sEdit'){
                        if(sizeToCheck.size()> 0){
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag016(), getTAG020()));
                            return false;
                        }
                    }
                    oMaprec.SVMXC__Source_Object_Name__c = getsourceObj();
                    oMaprec.SVMXC__Target_Object_Name__c = gettargetObj();
                   
                    if(targetRT == getTAG025())
                    oMaprec.SVMXC__Target_Record_Type__c =null;
                    else oMaprec.SVMXC__Target_Record_Type__c =targetRT;
                    
                    
                                
            //Upsert FldMap
            List<SVMXC__ServiceMax_Config_Data__c> fldMapRecToUpsert = new List<SVMXC__ServiceMax_Config_Data__c>();
            //Delete FldMap if Source Set to None
            List<SVMXC__ServiceMax_Config_Data__c> fldMapRecToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            for(wrapper w : wrapFldMap)
                {
                if(w.sourceFldName == getTAG023())
                    w.fldMapRec.SVMXC__Source_Field_Name__c = null;
                else        
                    w.fldMapRec.SVMXC__Source_Field_Name__c = w.sourceFldName;

                if(w.targetFldName != getTAG023())
                    w.fldMapRec.SVMXC__Target_Field_Name__c = w.targetFldName;
                
                //w.fldMapRec.SVMXC__MapID__c = oMaprec.Id;
                w.fldMapRec.RecordTypeId = fMapRT;
                w.fldMapRec.SVMXC__Active__c = true;
                
                if(w.fldMapRec.SVMXC__Target_Field_Name__c != null || w.fldMapRec.SVMXC__Target_Field_Name__c != '--None--')
                {
                    if(w.fldMapRec.SVMXC__Source_Field_Name__c != null && w.fldMapRec.SVMXC__Source_Field_Name__c != '--None--')
                        fldMapRecToUpsert.add(w.fldMapRec); //if clause added by GM in 2.6.1 release //Updated in 2.6.3
                    else if(w.fldMapRec.SVMXC__Source_Field_Name__c == null || w.fldMapRec.SVMXC__Source_Field_Name__c == '--None--') // else if clause added by GM in 2.6.3 release
                        if(w.fldMapRec.Id != null )fldMapRecToDelete.add(w.fldMapRec); //Delete the recs which are set to None; This is Updated in 2.6.3 release by GM
                 }

                }
                
                Integer noneCount =0;
                for(SVMXC__ServiceMax_Config_Data__c rtu :fldMapRecToUpsert)
                {
                   // rtu.SVMXC__MapID__c = oMaprec.Id; //hari added the code
                 //   System.debug('!!!!!'+rtu.SVMXC__Source_Field_Name__c);
                    if(rtu.SVMXC__Source_Field_Name__c ==null)
                    {
                       // rtu.SVMXC__Source_Field_Name__c =null;
                        noneCount ++;
                    }
                }
                
                if(noneCount == fldMapRecToUpsert.size()) 
                    
                    {
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTag016(),getTAG018())) ; //one field mapping should be done
                        return false;
                    }
                else{
					try{
						//upsert oMaprec;
						if(COMM_SecurityUtils.getInstance().verifyFieldAccess(oMaprec, COMM_SecurityUtils.Access.Upsertable)){
							upsert oMaprec; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
						}
						else{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
							return false;
						}
                    }
					catch(Exception e){
						ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag016(), e.getMessage()));
						return false;
					}
                   
                    //   System.debug('######### second '+fldMapRecToUpsert);
                       for(SVMXC__ServiceMax_Config_Data__c fldMapRec : fldMapRecToUpsert){
                            fldMapRec.SVMXC__MapID__c = oMaprec.Id; //append the id to field maps
                            fldMapRec.SVMXC__Configuration_Type__c = 'Field Mapping'; //Populate FieldMapping Type
                            
                       }
                        //upsert fldMapRecToUpsert;
						if(COMM_SecurityUtils.getInstance().verifyFieldAccess(fldMapRecToUpsert, COMM_SecurityUtils.Access.Upsertable)){
							upsert fldMapRecToUpsert; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
						}
						else{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
							return false;
						}
						
						//delete fldMapRecToDelete;
						if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
							delete fldMapRecToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
						}
						else{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
							return false;
						}
                       
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'',getTAG017()));
                    if(sMode =='sNew' || sMode == 'sClone'){
                        sMode='sEdit';
                    }
                    return true;
                }
            }
            catch (Exception e) {ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag016(), e.getmessage())) ; return false;}
        
        return false;
    }
  
        public PageReference SVMX_populateRT() 
            {
            buildRecordType();
            buildWrapperFldMapRecs();
            return null;
            }

        public PageReference SVMX_populateFMap() 
            {
            buildWrapperFldMapRecs();
            return null;
            }
  
        
        public PageReference SVMX_doCancel() 
            {
                String retURL = '/';
                 if(svmxSettingList.containsKey('SET001') == true)                  
                 retURL = svmxSettingList.get('SET001'); 
                
            PageReference scrn = new PageReference( retUrl);
            scrn.setRedirect(true);
            return scrn;
            }
        
    public RecordType getFMapRecordTypes()
        {
        RecordType erTypes;
        try
            {
            	//Changed to the static Query due to security review 2010 on 22/10/2010 by amar
            	//String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Field Mapping\'';       
                //erTypes = Database.query(SOQL);
                erTypes = [SELECT Id,Name  FROM RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name= 'Field Mapping'];      
            }
        catch (Exception e){}   
        return erTypes;
        }
    public RecordType getOMapRecordTypes()
    {
        RecordType erTypes;
        try
        {
            //Changed to the static Query due to security review 2010 on 22/10/2010 by amar
            //String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Processes__c\' and Name=\'Object Mapping\'';       
            //erTypes = Database.query(SOQL);
            erTypes = [SELECT Id,Name  FROM RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name ='Object Mapping'];      
        }
        catch (Exception e){}   
        return erTypes;
        }
    public List<RecordType> getOMapRecordTypes(String objName)
        {
        List<RecordType> erTypes = new List<RecordType>();
        try
            {
            	//Changed to the static Query due to security review 2010 on 22/10/2010 by amar
            	//String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+ objName +'\'';     //Getting Apiname for Local Name  
                //erTypes = Database.query(SOQL);
                erTypes = [SELECT Id,Name  FROM RecordType where SobjectType =: objName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        catch (Exception e){}   
        return erTypes;
        }
        
     public Boolean  hasDuplicateInList(List<SObject> listOfRecs, String fldNameInList,Object valToChk ){
        Integer duplicateFound = 0;
        for(SObject recToChk : listOfRecs){
                if(recToChk.get(fldNameInList) == valToChk ) {duplicateFound++ ;}
        }
        if(duplicateFound >1) return true;
        else return false;
    }

                public String getTAG001() {  return System.Label.CONF012_TAG001; }//'Configure Mapping For Automation'
        public String getTAG002() {return System.Label.CONF012_TAG002;}//Quick Save 
        public String getTAG003() {return System.Label.CONF012_TAG003;}//Cancle
        public String getTAG004() {return System.Label.CONF012_TAG004;}//Confingure Field Mapping Help
        public String getTAG005() {return System.Label.CONF012_TAG005;}//Map Name
        public String getTAG006() {return System.Label.CONF012_TAG006;}//Map ID
        public String getTAG007() {return System.Label.CONF012_TAG007;}//Description
        public String getTAG008() {return System.Label.CONF012_TAG008;}//Source Object Name
        public String getTAG009() {return System.Label.CONF012_TAG009;}//Target Object Name
        public String getTAG010() {return System.Label.CONF012_TAG010;}//Target Record Type
        public String getTAG011(){ return System.Label.CONF012_TAG011;}//Target Field Name 
        public String getTAG012(){ return System.Label.CONF012_TAG012;} //Field API Name
        public String getTAG013(){ return System.Label.CONF012_TAG013;} //Data Type
        public String getTAG014(){ return System.Label.CONF012_TAG014;} //Source Field Name
        public String getTAG015(){ return System.Label.CONF012_TAG015;} //Review all error messages below and click save
        public String getTAG016(){ return System.Label.CONF012_TAG016;} //Save:
        public String getTAG017(){ return System.Label.CONF012_TAG017;} //Record saved sucessfully
        public String getTAG018(){ return System.Label.CONF012_TAG018;} //Atleast Change One Mapping        
        public String getTAG020(){ return System.Label.CONF012_TAG020;} //Duplicate Error
        public String getTAG021(){ return System.Label.CONF012_TAG021;}//Please fill the Required Fields
        public String getTAG023(){ return System.Label.CONF012_TAG023;}//--NONE--
        public String getTAG024(){ return System.Label.CONF012_TAG024;}//Active
        public String getTAG025(){ return System.Label.CONF012_TAG025;}//Master
        public String getTAG026(){ return System.Label.CONF012_TAG026;}// Error: Corresponding Object not avilable in the Org.
        public String getTAG027(){ return System.Label.CONF012_TAG027;}//  Save
        public String getTAG028(){ return System.Label.CONF012_TAG028;}// Quick Save
        public String getHLPURL() {return System.Label.CONF012_HLPURL;}        
            
        
        
   
}