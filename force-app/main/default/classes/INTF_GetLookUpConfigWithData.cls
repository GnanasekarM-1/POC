public with sharing class INTF_GetLookUpConfigWithData
{
    public INTF_GetLookUpConfigWithData(){}
    public INTF_WebServicesDef.INTF_LookUpConfigData getLookUpConfigWithData(INTF_WebServicesDef.INTF_Request prequest)
    {
        SVMXC.INTF_WebServicesDef.INTF_Response_NamedSearchInfo ResNamedSearch;
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();//member of SFM_Response_ProcessNodeInfo
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> processNodeSourceObject = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();//member of SFM_Response_ProcessNodeInfo
        SVMXC__ServiceMax_Processes__c processNodeObejct = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Processes__c > LstDflSearch = new list<SVMXC__ServiceMax_Processes__c >();
        set<String> DispFields = new set<String>();
        set<String> SearchFields = new set<String>();
        set<String> BubbleFields = new set<String>();
        set<String> DispFieldswithRef = new set<String>();
        set<String> SearchFieldswithRef = new set<String>();
        set<String> BubbleFieldswithRef = new set<String>();
        set<String> FinalFieldswithRef = new set<String>();
        Map<String, Schema.SObjectType> Allobjs = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        Map<String, String> mainDispfldnames = new Map<String, String>();
        Map<String, String> mainBubblefldnames = new Map<String, String>();
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        String LkUpCnfgId;
        String LookUpConfgId;
        String Keyword;
        String sobjtname;
        String Defltfield;
        Integer NoOfRec;
        String Query = '';
        String ContextVal;
        String fldName;
        String InfoType;
        String SrchRecId;
        List<sObject> Resultdata;
        List<SVMXC.INTF_WebServicesDef.bubble_wp> Resultdata1 = new List<SVMXC.INTF_WebServicesDef.bubble_wp>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Named Search');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        String ObjectName = '';
        SVMX_Debug log = new SVMX_Debug();
        String WhereClause = ' where ';
        String strLimit = '';
        String whereStr = '';
        String RltdobjName;
        String ObjectNameAPI;
        log.login('SFM_getLookUpConfigWithData', 'getLookUpConfigWithData(INTF_WebServicesDef.INTF_Request prequest)');
        SVMXC__ServiceMax_Processes__c hdrnamedsrch = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c objectDetails = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail> CloneprocessNodeSourceObject = new List<SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail oSFM_Exp;
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> NSI1 = new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        List<INTF_WebServicesDef.INTF_StringMap> strmap = new List<INTF_WebServicesDef.INTF_StringMap>();
        try
        {
            List<INTF_WebServicesDef.INTF_StringMap> requestedData = prequest.stringMap;
            for(INTF_WebServicesDef.INTF_StringMap req: requestedData)
            {
                if(req.key.toUpperCase() == 'RECORDID')
                   LkUpCnfgId = req.value;
                if(req.key.toUpperCase() == 'KEYWORD')
                   Keyword = req.value;
                if(req.key.toUpperCase() == 'OBJECTNAME')
                   sobjtname = req.value;
                if(req.key.toUpperCase() == 'DEFAULTCOLUMN')    
                   Defltfield=req.value;
                if(req.key.toUpperCase() == 'NOOFRECORDS')
                   NoOfRec =integer.ValueOf(req.value);
                if(req.key.toUpperCase() == 'CONTEXTVALUE')
                   ContextVal =req.value;
                if(req.key.toUpperCase() == 'FIELDNAME')
                   fldName =req.value;
                if(req.key.toUpperCase() == 'INFOTYPE')
                   InfoType =req.value;
                if(req.key.toUpperCase() == 'SEARCHRECORD')
                   SrchRecId =req.value;
                 if(req.key.toUpperCase() == 'RELATEDOBJECTNAME')
                   RltdobjName =req.value;
                    
            }
            system.debug('RECORDID'+LkUpCnfgId);
            system.debug('Keyword'+Keyword);
            system.debug('OBJECTNAME'+sobjtname);
            system.debug('DEFAULTCOLUMN'+Defltfield);
            system.debug('NOOFRECORDS'+NoOfRec);
            system.debug('ContextVal'+ContextVal);
            system.debug('FIELDNAME'+fldName);
            system.debug('InfoType'+InfoType);
            system.debug('SrchRecId'+SrchRecId);
            
            if(NoOfRec != null)
               strLimit = 'limit '+ NoOfRec;
            else
               strLimit = 'limit 50';
               
           if(LkUpCnfgId != null)
            {
                
                SVMXC.INTF_getNamedSearchInfo getnamedsearch = new SVMXC.INTF_getNamedSearchInfo();
                
                ResNamedSearch = getnamedsearch.getNamedSearchInfo(prequest);
                system.debug('0zzzzzzzzz'+prequest);
                system.debug('01zzzzzzzzz'+ResNamedSearch);
                for(INTF_WebServicesDef.INTF_NamedSearchInfo namedsrchinfo: ResNamedSearch.namedSearch)
                 {
                    processNodes = namedsrchinfo.namedSearchHdr;
                    processNodeSourceObject.addAll(namedsrchinfo.namedSearchDetails);
                  
                 }
                 system.debug('1zzzzzzzzz'+processNodeSourceObject.size());
                 system.debug('2zzzzzzzzz'+processNodeSourceObject);
                if(processNodeSourceObject.size()>0 && processNodeSourceObject!=null)
                 {
                for(Integer i = 0;i<processNodeSourceObject.size();i++)
                 {
                    SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail ProcessNodeDetail;
                    ProcessNodeDetail = processNodeSourceObject[i];
                    processNodeObejct = ProcessNodeDetail.objectDetails;
                    ObjectName=processNodeObejct.SVMXC__Source_Object_Name__c;
                for(Integer j = 0;j<ProcessNodeDetail.fields.size();j++)
                    {
                      SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                      tempconfigdata = ProcessNodeDetail.fields[j];
                      if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='RESULT')
                      {
                        DispFields.add(tempconfigdata.SVMXC__Field_Name__c);
                      if(tempconfigdata.SVMXC__Display_Type__c == null)
                        {
                          
                           DispFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                           mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                        }
                      else
                        {
                          String disp = '';
                          disp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                          mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,disp);
                          DispFieldswithRef.add(disp);
                        }
                      }
                      if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='SEARCH')
                      {
                        SearchFields.add(tempconfigdata.SVMXC__Field_Name__c);
                        
                        if(tempconfigdata.SVMXC__Display_Type__c == null)
                        {
                          SearchFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                        }
                        else
                        {
                          String srchp = '';
                          srchp = tempconfigdata.SVMXC__Field_Relationship_Name__c +'.'+ tempconfigdata.SVMXC__FKey_Name_Field__c;
                          SearchFieldswithRef.add(srchp);
                        }
                      }
                      if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='BUBBLE')
                      {
                        BubbleFields.add(tempconfigdata.SVMXC__Field_Name__c);
                        
                        if(tempconfigdata.SVMXC__Display_Type__c == null)
                        {
                          BubbleFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                          mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                        }
                        else
                        {
                           String Bubp = '';
                           Bubp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                           mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,Bubp);
                           BubbleFieldswithRef.add(Bubp);
                        }
                
                      }
                    
                    }
                
                 }
                 }
                 if(InfoType == null || InfoType == '')
                 {
                   if(Keyword != null)
                    {
                        system.debug('entered not null');
                    for(String sfield: SearchFieldswithRef)
                    {
                        if(sfield != '' || sfield != NULL)
                        {
                            if(whereStr != '')
                            whereStr += ' OR ';
                            
                            whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'%\'';
                            
                        }
                        
                    }
                    if(ContextVal != null)
                    {
                       WhereClause += ' ( '+whereStr+' ) '+' AND '+ fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                    }
                    else
                    {
                       WhereClause += ' ( '+whereStr+' ) '+ ' '+strLimit;
                    }
                        
                    
                    }
                    else
                    {
                        if(ContextVal != null)
                        WhereClause += fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                        else
                        WhereClause=' '+strLimit;
                    }
                    
                     if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() == 0)
                     {
                       if(DispFieldswithRef.contains(Defltfield))
                       {
                       Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       else
                       {
                         if(Defltfield != null)
                         Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                         else
                         Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       system.debug('Query'+Query);
                     Resultdata=database.query(Query);
                     }
                     if(DispFieldswithRef.size() == 0 && BubbleFieldswithRef.size() > 0)
                     {
                       if(BubbleFieldswithRef.contains(Defltfield))
                       {
                       Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       else
                       {
                         if(Defltfield != null)
                         Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                         else
                         Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       system.debug('Query'+Query);
                       Resultdata=database.query(Query);
                     }
                     if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() > 0)
                     {
                        system.debug('Entered 3rd Block');
                        
                        for (String field1 : DispFieldswithRef)
                         {
                           FinalFieldswithRef.add(field1);
                         }
                         for (String field2 : BubbleFieldswithRef)
                         {
                           FinalFieldswithRef.add(field2);
                         }
                         system.debug('FinalFieldswithRef'+FinalFieldswithRef);
                        if(FinalFieldswithRef.contains(Defltfield))
                        {
                           Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        }
                        else
                        {
                            if(Defltfield != null)
                            Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                            else
                            Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
              
                        }
                        system.debug('Query'+Query);
                        Resultdata=database.query(Query);
                        
                     } 
                     
                 if(!DispFieldswithRef.contains(Defltfield) && Defltfield != null)
                 {
                 mainDispfldnames.put(Defltfield,Defltfield);
                 }
                 mainDispfldnames.put('Id','Id');
       if(Resultdata != null)
            {
            for(sObject sobj: Resultdata)
            {
                List<INTF_WebServicesDef.INTF_StringFieldMap> strmap1 = new List<INTF_WebServicesDef.INTF_StringFieldMap>();
                
                if(mainDispfldnames.size() > 0)
                {
                    for (String field : mainDispfldnames.keyset())
                    {
                      INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                      strmap2.Key = field;
                      if(mainDispfldnames.get(field).contains('.'))
                      {
                        
                        String objval = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]));
                        if(objval == null)
                        {
                          strmap2.value = '';
                        }
                        else
                        {
                          strmap2.value = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]).get(mainDispfldnames.get(field).split('\\.')[1]));
                        }
                      }
                      else
                      {
                        strmap2.value = String.valueOf(sobj.get(mainDispfldnames.get(field)));
                      
                      }
                      strmap2.ftype = 'Result';
                      strmap1.add(strmap2);
                    }
                }
                if(mainBubblefldnames.size() > 0)
                {
                    for (String field : mainBubblefldnames.keyset())
                    {
                      INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                      strmap2.Key = field;
                      if(mainBubblefldnames.get(field).contains('.'))
                      {
                        String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                        if(objval == null)
                        {
                          strmap2.value = '';
                        }
                        else
                        {
                          strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                        }
                      }
                      else
                      {
                        
                        strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                      }
                      
                      strmap2.ftype = 'Bubble';
                      strmap1.add(strmap2);
                    }
                }
                system.debug('FinalListmap'+strmap1);
                SVMXC.INTF_WebServicesDef.bubble_wp bbl = new SVMXC.INTF_WebServicesDef.bubble_wp(strmap1);
                Resultdata1.add(bbl);
                   }
                 }
                 }//commneted for Keyword no null
                 //start
                 if(InfoType != null)
                 {
                    system.debug('InfoType'+InfoType);
                    if(InfoType.toUpperCase() == 'BUBBLE')
                     {
                        
                        if(BubbleFieldswithRef.size() > 0)
                        {
                            
                            Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+ ' FROM '+ ObjectName + ' where Id=\''+SrchRecId+'\'';
                            
                            Resultdata = database.query(Query);
                            
                            if(Resultdata != null)
                            {
                            for(sObject sobj: Resultdata)
                             {
                                 List<INTF_WebServicesDef.INTF_StringFieldMap> strmap1 = new List<INTF_WebServicesDef.INTF_StringFieldMap>();
                                if(mainBubblefldnames.size() > 0)
                                  {
                                     for (String field : mainBubblefldnames.keyset())
                                        {
                                            system.debug('TRYFIELD'+field);
                                           INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                                           
                                           strmap2.Key = field;
                                           
                                           if(mainBubblefldnames.get(field).contains('.'))
                                              {
                                               
                                                String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                                                system.debug('Entered DOT'+objval);
                                                if(objval == null)
                                                   strmap2.value = '';
                                                else
                                                   strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                                
                                              }
                                           else
                                              {
                                                 
                                                 strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                                                 
                                              }
                                    
                                             strmap2.ftype = 'Bubble';
                                             strmap1.add(strmap2);
                                         }
                                    }
                                     
                                     SVMXC.INTF_WebServicesDef.bubble_wp bbl = new SVMXC.INTF_WebServicesDef.bubble_wp(strmap1);
                                     Resultdata1.add(bbl);
                                     
                             }
                        }
                            
                        }
                        
                     }
                    
                    
                 }
                 //end
                 
            }
            
            if(sobjtname != null)
            {
                
                system.debug('Entered Object block');
                
                LstDflSearch = [SELECT Id, Name, SVMXC__Name__c,SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' AND SVMXC__Source_Object_Name__c = :sobjtname And SVMXC__IsDefault__C = true];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(LstDflSearch.size() > 0)
                {
                  system.debug('Entered Default');
                  for(SVMXC__ServiceMax_Processes__c p : LstDflSearch)
                   {
                       LookUpConfgId = p.Id;
                   }
                   system.debug('LookUpId'+ LookUpConfgId);
                   if(LookUpConfgId!=null)
                   {
                      List<INTF_WebServicesDef.INTF_StringMap> stringMap123=new List<INTF_WebServicesDef.INTF_StringMap>();
                      stringMap123.add(new INTF_WebServicesDef.INTF_StringMap ('RECORDID',LookUpConfgId));
                      INTF_WebServicesDef.INTF_Request request123 = new INTF_WebServicesDef.INTF_Request('','','',stringMap123);
                      SVMXC.INTF_getNamedSearchInfo getnamedsearch = new SVMXC.INTF_getNamedSearchInfo();
                      ResNamedSearch = getnamedsearch.getNamedSearchInfo(request123);
                                      
                for(INTF_WebServicesDef.INTF_NamedSearchInfo namedsrchinfo: ResNamedSearch.namedSearch)
                 {
                    processNodes = namedsrchinfo.namedSearchHdr;
                    processNodeSourceObject.addAll(namedsrchinfo.namedSearchDetails);
                  
                 }
                if(processNodeSourceObject.size()>0 && processNodeSourceObject!=null)
                 {
                for(Integer i = 0;i<processNodeSourceObject.size();i++)
                 {
                    SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail ProcessNodeDetail;
                    ProcessNodeDetail = processNodeSourceObject[i];
                    processNodeObejct = ProcessNodeDetail.objectDetails;
                    ObjectName=processNodeObejct.SVMXC__Source_Object_Name__c;
                for(Integer j = 0;j<ProcessNodeDetail.fields.size();j++)
                    {
                      SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                      tempconfigdata = ProcessNodeDetail.fields[j];
                      if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='RESULT')
                      {
                        DispFields.add(tempconfigdata.SVMXC__Field_Name__c);
                      if(tempconfigdata.SVMXC__Display_Type__c == null)
                        {
                          
                           DispFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                           mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                        }
                      else
                        {
                          String disp = '';
                          disp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                          mainDispfldnames.put(tempconfigdata.SVMXC__Field_Name__c,disp);
                          DispFieldswithRef.add(disp);
                        }
                      }
                      if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='SEARCH')
                      {
                        SearchFields.add(tempconfigdata.SVMXC__Field_Name__c);
                        
                        if(tempconfigdata.SVMXC__Display_Type__c == null)
                        {
                          SearchFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                        }
                        else
                        {
                          String srchp = '';
                          srchp = tempconfigdata.SVMXC__Field_Relationship_Name__c +'.'+ tempconfigdata.SVMXC__FKey_Name_Field__c;
                          SearchFieldswithRef.add(srchp);
                        }
                      }
                      if(tempconfigdata.SVMXC__Search_Object_Field_Type__c.toUpperCase()=='BUBBLE')
                      {
                        BubbleFields.add(tempconfigdata.SVMXC__Field_Name__c);
                        
                        if(tempconfigdata.SVMXC__Display_Type__c == null)
                        {
                          BubbleFieldswithRef.add(tempconfigdata.SVMXC__Field_Name__c);
                          mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,tempconfigdata.SVMXC__Field_Name__c);
                        }
                        else
                        {
                           String Bubp = '';
                           Bubp = tempconfigdata.SVMXC__Field_Relationship_Name__c+'.'+tempconfigdata.SVMXC__FKey_Name_Field__c;
                           mainBubblefldnames.put(tempconfigdata.SVMXC__Field_Name__c,Bubp);
                           BubbleFieldswithRef.add(Bubp);
                        }
                
                      }
                    
                    }
                
                 }
                 }
                 String strAndUserActive = '';
                String strUserActive = '';
                if(ObjectName.toUpperCase() == 'USER')
                {
                    strAndUserActive = ' and isActive = true ';
                    strUserActive = ' isActive = true ';
                }
                 if(InfoType == null || InfoType == '')
                 {
                   if(Keyword != null)
                    {
                        system.debug('entered not null');
                    for(String sfield: SearchFieldswithRef)
                    {
                        if(sfield != '' || sfield != NULL)
                        {
                            if(whereStr != '')
                            whereStr += ' OR ';
                            
                            whereStr += sfield+' like \'%'+string.escapeSingleQuotes(Keyword)+'%\'';
                            
                        }
                        
                    }
                    
                    if(ContextVal != null)
                    {
                       WhereClause += ' ( '+whereStr+' ) '+' AND '+ fldName +'='+'\''+ContextVal+'\''+ strAndUserActive + ' '+strLimit;
                    }
                    else
                    {
                       WhereClause += ' ( '+whereStr+' ) '+ ' '+ strAndUserActive +strLimit;
                    }
                        
                    
                    }
                    else
                    {
                        if(ContextVal != null)
                        WhereClause += fldName +'='+'\''+ContextVal+'\''+ ' '+ strAndUserActive + strLimit;
                        else
                        WhereClause=' '+ strUserActive + strLimit;
                    }
                     
                    
                     if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() == 0)
                     {
                       if(DispFieldswithRef.contains(Defltfield))
                       {
                       Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       else
                       {
                         if(Defltfield != null)
                         Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                         else
                         Query='SELECT '+SVMX_getFieldNamesFromList(DispFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       system.debug('Query'+Query);
                     Resultdata=database.query(Query);
                     }
                     if(DispFieldswithRef.size() == 0 && BubbleFieldswithRef.size() > 0)
                     {
                       if(BubbleFieldswithRef.contains(Defltfield))
                       {
                       Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       else
                       {
                         if(Defltfield != null)
                         Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                         else
                         Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                       }
                       system.debug('Query'+Query);
                       Resultdata=database.query(Query);
                     }
                     if(DispFieldswithRef.size() > 0 && BubbleFieldswithRef.size() > 0)
                     {
                        for (String field1 : DispFieldswithRef)
                         {
                           FinalFieldswithRef.add(field1);
                         }
                         for (String field2 : BubbleFieldswithRef)
                         {
                           FinalFieldswithRef.add(field2);
                         }
                        
                        if(FinalFieldswithRef.contains(Defltfield))
                        {
                           Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
                        }
                        else
                        {
                            if(Defltfield != null)
                            Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+ ','+Defltfield+',Id'+' FROM '+ ObjectName + +WhereClause;
                            else
                            Query='SELECT '+SVMX_getFieldNamesFromList(FinalFieldswithRef)+',Id'+' FROM '+ ObjectName + +WhereClause;
              
                        }
                        system.debug('Query'+Query);
                        Resultdata=database.query(Query);
                        
                     } 
                     
                 if(!DispFieldswithRef.contains(Defltfield) && Defltfield != null)
                 {
                 mainDispfldnames.put(Defltfield,Defltfield);
                 }
                 mainDispfldnames.put('Id','Id');
       if(Resultdata != null)
            {
            for(sObject sobj: Resultdata)
            {
                List<INTF_WebServicesDef.INTF_StringFieldMap> strmap1 = new List<INTF_WebServicesDef.INTF_StringFieldMap>();
                
                if(mainDispfldnames.size() > 0)
                {
                    for (String field : mainDispfldnames.keyset())
                    {
                      INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                      strmap2.Key = field;
                      if(mainDispfldnames.get(field).contains('.'))
                      {
                        
                        String objval = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]));
                        if(objval == null)
                        {
                          strmap2.value = '';
                        }
                        else
                        {
                          strmap2.value = String.valueOf(sobj.getSObject(mainDispfldnames.get(field).split('\\.')[0]).get(mainDispfldnames.get(field).split('\\.')[1]));
                        }
                      }
                      else
                      {
                        strmap2.value = String.valueOf(sobj.get(mainDispfldnames.get(field)));
                      
                      }
                      strmap2.ftype = 'Result';
                      strmap1.add(strmap2);
                    }
                }
                if(mainBubblefldnames.size() > 0)
                {
                    for (String field : mainBubblefldnames.keyset())
                    {
                      INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                      strmap2.Key = field;
                      if(mainBubblefldnames.get(field).contains('.'))
                      {
                        String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                        if(objval == null)
                        {
                          strmap2.value = '';
                        }
                        else
                        {
                          strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                        }
                      }
                      else
                      {
                        
                        strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                      }
                      
                      strmap2.ftype = 'Bubble';
                      strmap1.add(strmap2);
                    }
                }
                SVMXC.INTF_WebServicesDef.bubble_wp bbl = new SVMXC.INTF_WebServicesDef.bubble_wp(strmap1);
                Resultdata1.add(bbl);
                   }
                 }
                 }//commneted for Keyword no null
                 //start
                 if(InfoType != null)
                 {
                    system.debug('InfoType'+InfoType);
                    if(InfoType.toUpperCase() == 'BUBBLE')
                     {
                        
                        if(BubbleFieldswithRef.size() > 0)
                        {
                            Query='SELECT '+SVMX_getFieldNamesFromList(BubbleFieldswithRef)+ ' FROM '+ ObjectName + ' where Id=\''+SrchRecId+'\'';
                            system.debug('Query123'+Query);
                            Resultdata = database.query(Query);
                            if(Resultdata != null)
                            {
                            for(sObject sobj: Resultdata)
                             {
                                 List<INTF_WebServicesDef.INTF_StringFieldMap> strmap1 = new List<INTF_WebServicesDef.INTF_StringFieldMap>();
                                if(mainBubblefldnames.size() > 0)
                                  {
                                     for (String field : mainBubblefldnames.keyset())
                                        {
                                           INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                                           
                                           strmap2.Key = field;
                                           
                                           if(mainBubblefldnames.get(field).contains('.'))
                                              {
                                               
                                                String objval = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]));
                                                if(objval == null)
                                                   strmap2.value = '';
                                                else
                                                   strmap2.value = String.valueOf(sobj.getSObject(mainBubblefldnames.get(field).split('\\.')[0]).get(mainBubblefldnames.get(field).split('\\.')[1]));
                                
                                              }
                                           else
                                              {
                                                 strmap2.value = String.valueOf(sobj.get(mainBubblefldnames.get(field)));
                                              }
                                    
                                             strmap2.ftype = 'Bubble';
                                             strmap1.add(strmap2);
                                         }
                                    }
                                     SVMXC.INTF_WebServicesDef.bubble_wp bbl = new SVMXC.INTF_WebServicesDef.bubble_wp(strmap1);
                                     Resultdata1.add(bbl);
                             }
                        }
                            
                        }
                        
                     }
                    
                    
                 }
                    
                   }
                   //end of if id
                }
                //end123final
                else
                {
                    system.debug('Entered Object sec block');
                      String nameField;
                Allobjs = Schema.getGlobalDescribe();
                ObjectNameAPI = utils.getOriginalAPIName(sobjtname,Allobjs);
                system.debug('ObjectNameAPI'+ObjectNameAPI);
                if(Allobjs.containskey(ObjectNameAPI))
                {
                    if(Allobjs.get(ObjectNameAPI) == Account.SObjectType)
                        nameField = 'Name';
                    else
                    {   
                        FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                        
                        if(FieldMap.size() > 0)
                        {
                            for(String s :FieldMap.keyset())
                             {
                                Schema.DescribeFieldResult fieldDesc = FieldMap.get(s).getDescribe();
                                if(fieldDesc.isNameField())
                                 {
                                   nameField = fieldDesc.getName();
                                    break;
                                 }
                    
                             }
                
                        }
                    }
                    
                }
                system.debug('nameField'+nameField);
                 if(Keyword != null)
                 {
                    if(ContextVal != null)
                    Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname + ' where ' + nameField +' like \'%'+string.escapeSingleQuotes(Keyword)+'%\''+' AND '+ fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                    else
                    Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname + ' where ' + nameField +' like \'%'+string.escapeSingleQuotes(Keyword)+'%\''+ ' '+strLimit;
                 
                 }
                 else
                 {
                    if(ContextVal != null)
                    Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname + ' where ' + fldName +'='+'\''+ContextVal+'\''+ ' '+strLimit;
                    else
                    Query = 'SELECT Id,'+nameField+' FROM '+ sobjtname+ ' '+strLimit;
                 }
                    
                    system.debug('Query'+Query);
                    Resultdata = database.query(Query);
                    if(Resultdata != null)
                    {
                      for(sObject sobj: Resultdata)
                        {
                          List<INTF_WebServicesDef.INTF_StringFieldMap> strmap1 = new List<INTF_WebServicesDef.INTF_StringFieldMap>();
                          INTF_WebServicesDef.INTF_StringFieldMap strmap2 = new INTF_WebServicesDef.INTF_StringFieldMap();
                          strmap2.Key = nameField;
                          strmap2.value = String.valueOf(sobj.get(nameField));
                          strmap2.ftype = 'Result';
                
                          INTF_WebServicesDef.INTF_StringFieldMap strmap3 = new INTF_WebServicesDef.INTF_StringFieldMap();
                          strmap3.Key = 'Id';
                          strmap3.value = String.valueOf(sobj.get('Id'));
                          strmap3.ftype = 'Result';
            
                
                          strmap1.add(strmap2);
                          strmap1.add(strmap3);
                          SVMXC.INTF_WebServicesDef.bubble_wp bbl = new SVMXC.INTF_WebServicesDef.bubble_wp(strmap1);
                          Resultdata1.add(bbl);
                        }
                     }
                 
                 
                hdrnamedsrch.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                hdrnamedsrch.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
                hdrnamedsrch.SVMXC__Source_Object_Name__c = sobjtname;
                
                objectDetails.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Named Search');
                objectDetails.SVMXC__Source_Object_Name__c = sobjtname;
                
                SVMXC__ServiceMax_Config_Data__c obj7 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c=1,  
                SVMXC__Search_Object_Field_Type__c = 'Bubble',SVMXC__Field_Name__c = nameField);
                obj7.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                obj7.SVMXC__Expression_Type__c='SRCH_Object_Fields';
                fields.add(obj7);
                
                CloneprocessNodeSourceObject.add(new SVMXC.INTF_WebServicesDef.INTF_NamedSearchInfoDetail(objectDetails,fields));
                INTF_WebServicesDef.INTF_NamedSearchInfo oSFM_Exp1 = new INTF_WebServicesDef.INTF_NamedSearchInfo(hdrnamedsrch,CloneprocessNodeSourceObject);
                NSI1.add(oSFM_Exp1);
                ResNamedSearch = new INTF_WebServicesDef.INTF_Response_NamedSearchInfo(NSI1);
                }
            }
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            
        }
        log.logout();
        log.print();
        log.getlog();
        SVMXC.INTF_WebServicesDef.INTF_LookUpConfigData LKCD = new SVMXC.INTF_WebServicesDef.INTF_LookUpConfigData();
        LKCD.namesearchinfo = ResNamedSearch;
        system.debug('ResNamedSearch'+ResNamedSearch);
        system.debug('Resultdata1'+Resultdata1);
        LKCD.data = Resultdata1;
        return LKCD;
        
    }
    public String SVMX_getFieldNamesFromList(set<String> fieldList) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }
       return fieldNames;
        
    }
}