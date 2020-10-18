public with sharing class INTF_ParseProcess 
{
    //SVMXC.INTF_getNamedExpressionList NamedExpCall = new SVMXC.INTF_getNamedExpressionList();
    public INTF_ParseProcess(){}
    
    public map<String,List<Sobject>> getINTF_ParseProcess(String ProcessId,String RecId,map<String, Schema.SObjectType> allobjmap)
    {
        map<String,map<String, Schema.SObjectField>> AllFieldDescribe = new map<String,map<String, Schema.SObjectField>>();
        map<String,List<Sobject>> OutputMap = new map<String,List<Sobject>>();
        map<String,List<Sobject>> HeaderObjMap = new map<String,List<Sobject>>();
        map<String,List<Sobject>> DetailObjMap = new map<String,List<Sobject>>();
        String TargetManager = '';
        String ProcessNodeObj = '';
        List<RecordType> RecordTypes = new List<RecordType>();
        RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(RecordTypes.size() > 0 )
        {
            for(RecordType r : RecordTypes)
            {
                if(r.Name == 'Target Manager')
                {
                    TargetManager = r.id;
                }
                if(r.Name == 'Process Node Objects')
                {
                    ProcessNodeObj = r.id;
                }
            }
        }
        Sobject HeaderSobject;
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC.INTF_buildSobject BuildSobject = new SVMXC.INTF_buildSobject(); 
        SVMXC.INTF_applyMapping Applymapping = new SVMXC.INTF_applyMapping(); 
        SVMXC.INTF_parseExpression ExpParssig = new SVMXC.INTF_parseExpression(); 
        String HeaderTargetObject = '';
        String HeaderSourceObject = '';
        String HdrTargetObjMapId = '';
        String HdrSourceObjMapId = '';
        String HdrExpression = '';
        String HdrValueMapId = '';
        list<String> DetailTargetObject = new list<String>();
        map<String,SVMXC__ServiceMax_Processes__c> DetailTargetObjMap = new map<String,SVMXC__ServiceMax_Processes__c>();
        map<String,String> SourceObjParentColumnMap = new map<String,String>();
        system.debug('ProcessId'+ProcessId);
        if(ProcessId != null && ProcessId.length() > 0)
            SFMProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c, SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C, SVMXC__Installation_Key__c,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c,SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(SFMProcess != null && SFMProcess.id != null) 
            ProcessNodeObjects = [Select Name,SVMXC__ProcessID__c,SVMXC__Page_Layout__c,SVMXC__Final_Exception_Process__c,SVMXC__Parent_Column_Name__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: SFMProcess.id and RecordTypeId =: ProcessNodeObj];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('SFMProcess'+SFMProcess);
        system.debug('ProcessNodeObjects'+ProcessNodeObjects);
        if(ProcessNodeObjects.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects)
            {
                if(Pro.SVMXC__Type__c.touppercase() == 'TARGET')
                {
                    HeaderTargetObject = Pro.SVMXC__Source_Object_Name__c;
                    if(Pro.SVMXC__Module__c != null) 
                        HdrTargetObjMapId = Pro.SVMXC__Module__c; 
                    if(Pro.SVMXC__Submodule__c != null)
                        HdrExpression = Pro.SVMXC__Submodule__c;  
                    if(Pro.SVMXC__Final_Exception_Process__c != null)
                        HdrValueMapId = Pro.SVMXC__Final_Exception_Process__c;
                }
                if(Pro.SVMXC__Type__c.touppercase() == 'SOURCE')
                {
                    HeaderSourceObject = Pro.SVMXC__Source_Object_Name__c;
                    if(Pro.SVMXC__Module__c != null)
                        HdrSourceObjMapId = Pro.SVMXC__Module__c; 
                }
                if(Pro.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                {
                    DetailTargetObject.add(Pro.SVMXC__Source_Object_Name__c);
                    DetailTargetObjMap.put(String.valueof(Pro.SVMXC__Page_Layout__c).substring(0,15),Pro);
                }
                if(Pro.SVMXC__Type__c.touppercase() == 'TARGETCHILD' || Pro.SVMXC__Type__c.touppercase() == 'SOURCECHILD')
                {
                    if(Pro.SVMXC__Source_Object_Name__c != null && Pro.SVMXC__Parent_Column_Name__c != null)
                        SourceObjParentColumnMap.put(Pro.SVMXC__Source_Object_Name__c,Pro.SVMXC__Parent_Column_Name__c);
                }
            }
        }
        system.debug('HeaderTargetObject'+HeaderTargetObject); 
        system.debug('HeaderSourceObject'+HeaderSourceObject); 
        system.debug('HdrTargetObjMapId'+HdrTargetObjMapId);
        system.debug('HdrValueMapId'+HdrValueMapId);
        system.debug('HdrExpression'+HdrExpression+HdrExpression.length());
        system.debug('DetailTargetObjMap'+DetailTargetObjMap);
        system.debug('SourceObjParentColumnMap'+SourceObjParentColumnMap);
        
        //if its New Process(Mapping is applicable && Source Recored would be null (Only value map would be applicable))
        //Expression is also not applicable...
        if(SFMProcess.SVMXC__Purpose__c.touppercase() == 'STANDALONE CREATE')
        {
            system.debug('Enter in STANDALONE CREATE Process mode'); 
            //Create the Header Target...
            list<Sobject> HeaderSobjList = new list<Sobject>();
            HeaderSobjList =  BuildSobject.getINTF_BuildSobject(null,HeaderTargetObject,null,null);
            //Apply mapping if applicable
            system.debug('HeaderSobjList'+HeaderSobjList+HdrTargetObjMapId);
            if(HeaderSobjList.size() > 0 && HdrValueMapId != null && HdrValueMapId.length() > 0)
            {
                //HeaderSobjList = Applymapping.getApplyMapping(HeaderSobjList,HdrTargetObjMapId,null,true,allobjmap);
                HeaderSobjList = Applymapping.getValueMapping(HeaderSobjList,HdrValueMapId,allobjmap);
            }
            if(HeaderSobjList.size() > 0)
                HeaderObjMap.put(HeaderTargetObject,HeaderSobjList);
            //Create the Header Details...
            if(DetailTargetObjMap.size() > 0)
            {
                for(String s : DetailTargetObjMap.keyset())
                {
                    list<Sobject> DetSobjList = new list<Sobject>();
                    String TargetObject = '';
                    if(DetailTargetObjMap.Containskey(s)) 
                        TargetObject = DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c;
                    /* Bala(8/8/2011): An additional line was populated on iPad for child items, since its a create process we donot want child records
                    if(TargetObject != null && TargetObject.length() > 0)
                    {
                        DetSobjList =  BuildSobject.getINTF_BuildSobject(null,TargetObject,null,null);
                        //apply Value Mapping if its applicable
                        if(DetSobjList.size() > 0 && DetailTargetObjMap.get(s).SVMXC__Final_Exception_Process__c != null)
                        {
                            DetSobjList = Applymapping.getValueMapping(DetSobjList,DetailTargetObjMap.get(s).SVMXC__Final_Exception_Process__c,allobjmap);
                        }
                        if(DetSobjList.size() > 0)
                        {
                            DetailObjMap.put(s,DetSobjList);
                        }
                        system.debug('DetailObjMap'+DetailObjMap.size()+DetailObjMap);
                    }*/
                }
            }
        }
        //if its Edit Process ===> Mapping is not applicable 
                                 //Expression is applicable..
        if(SFMProcess.SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT' || SFMProcess.SVMXC__Purpose__c.touppercase() == 'VIEW RECORD')
        {
            system.debug('Enter in STANDALONE EDIT Process mode');
            //Get the Header Target..
            if(HeaderTargetObject != null && HeaderTargetObject.length() > 0)
            {
                list<Sobject> HeaderSobjList = new list<Sobject>();
                HeaderSobjList =  BuildSobject.getINTF_BuildSobject(RecId,HeaderTargetObject,null,null);
                system.debug('HeaderSobjList'+HeaderSobjList);
                //Expression Qualification...
                if(HdrExpression != null && HdrExpression.length() > 0 && HeaderSobjList.size() > 0)
                {
                    system.debug('Enter in Header Expression Qualification..');
                    SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                    Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :HdrExpression];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                    if(Expression != null) 
                    {
                        SFMExpression.namedExpression = Expression;
                    }
                    if(SFMExpression != null && SFMExpression.namedExpression != null)
                    {
                        system.debug('SFMExpression'+SFMExpression);
                        system.debug('HeaderSobjList'+HeaderSobjList);
                        HeaderSobjList = ExpParssig.INTF_ParseExpression(HeaderSobjList,SFMExpression);
                    } 
                    system.debug('HeaderSobjList'+HeaderSobjList);  
                }//if HeaderSobjList's size is greate then zeor then its Quelified OR if there is no expresion then its autometically quelify now go for apply mapping  
                if(HeaderSobjList.size() > 0 ||(HdrExpression == null && HdrExpression.length() == 0 && HeaderSobjList.size() > 0))
                {
                    HeaderObjMap.put(HeaderTargetObject,HeaderSobjList);
                    system.debug('HeaderObjMap'+HeaderObjMap);    
                }
            } 
            //get the Detail Targets..
            if(DetailTargetObjMap.size() > 0)
            {
                system.debug('Enter in Edit Process mode for Detail');
                for(String s : DetailTargetObjMap.keyset())
                {
                    list<Sobject> DetSobjList = new list<Sobject>();
                    if(DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c != null)//if detail is not available
                        DetSobjList = BuildSobject.getINTF_BuildSobject(RecId,DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c,DetailTargetObjMap.get(s).SVMXC__Parent_Column_Name__c,null);
                    system.debug('DetSobjList'+DetSobjList);
                    if(DetSobjList.size() > 0 && DetailTargetObjMap.get(s).SVMXC__Submodule__c != null)
                    {
                        system.debug('Enter in Header Expression Qualification for Detail..');
                        SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                        Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :DetailTargetObjMap.get(s).SVMXC__Submodule__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                        if(Expression != null)
                        {
                            SFMExpression.namedExpression = Expression;
                        }
                        if(SFMExpression != null && SFMExpression.namedExpression != null)
                            DetSobjList = ExpParssig.INTF_ParseExpression(DetSobjList,SFMExpression);   
                        system.debug('DetSobjList'+DetSobjList);
                    }//if HeaderSobjList's size is greate then zeor then its Quelified OR if there is no expresion then its autometically quelify now go for apply mapping
                    if(DetSobjList.size() > 0 ||(DetailTargetObjMap.get(s).SVMXC__Submodule__c == null && DetSobjList.size() > 0))
                        DetailObjMap.put(s,DetSobjList);
                    system.debug('DetailObjMap'+DetailObjMap.size()+DetailObjMap);    
                }
            }
        }
        if(SFMProcess.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL')
        {
            //first Check that Source object is Qualified for Expression or not
            system.debug('Enter in Source to Target Process mode');
            List<SObject> SourceSobjList = new List<SObject>();
            if(HdrExpression.length() > 0)
            {
                system.debug('Enterd for Expression Qualification....');
                //get the Source object Query to validate the Expression... 
                if(HeaderSourceObject != null && HeaderSourceObject.length() > 0)
                    SourceSobjList = BuildSobject.getINTF_BuildSobject(RecId,HeaderSourceObject,null,null);
                system.debug('SourceSobjList'+SourceSobjList);
                SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: HdrExpression];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                if(Expression != null)
                {
                    SFMExpression.namedExpression = Expression;
                }
                if(SFMExpression != null && SFMExpression.namedExpression != null)
                {
                    SourceSobjList = ExpParssig.INTF_ParseExpression(SourceSobjList,SFMExpression);
                    system.debug('SourceSobjList'+SourceSobjList);
                }
            }//if  SourceSobjList's size is greate then zeor then its Quelified and if then is no expresion then its autometically quelify now go for apply mapping
            if((SourceSobjList.size() > 0 && HeaderTargetObject != null && HeaderTargetObject.length() > 0) || (HdrExpression == null || HdrExpression.length() == 0))
            {
                system.debug('Expression is not appicable');
                //Create the Target Object..
                list<Sobject> TargetSobjList = new list<Sobject>();
                TargetSobjList = BuildSobject.getINTF_BuildSobject(null,HeaderTargetObject,null,null);
                system.debug('TargetSobjList'+TargetSobjList);      
                //apply mapping for the header target
                if(TargetSobjList.size() > 0 && HdrTargetObjMapId != null && HdrTargetObjMapId.length() > 0)
                {
                    system.debug('Enterd for apply mapping');   
                    TargetSobjList = Applymapping.getApplyMapping(TargetSobjList,HdrTargetObjMapId,RecId,true,allobjmap);
                    system.debug('TargetSobjList'+TargetSobjList);  
                }
                if(TargetSobjList.size() > 0)//if TargetSobjList's size is greate then zeor then it has applied mapping(put it in the final map)
                {
                    system.debug('Created Header');
                    HeaderObjMap.put(HeaderTargetObject,TargetSobjList);
                    system.debug('HeaderObjMap'+HeaderObjMap.size()+HeaderObjMap); 
                }
            }
            //Now Process Target Details 
            if(DetailTargetObjMap.size() > 0)
            {
                system.debug('Entered in Details');
                for(String s : DetailTargetObjMap.keyset())
                {
                    list<Sobject> DetSourceSobjList = new list<Sobject>(); 
                    list<Sobject> DetTargerSobjList = new list<Sobject>();
                    //if the SOURCE is not match with the SOURCECHILD then --> first get the no of source details records and then  besed on that create the no of target detail
                    if(HeaderSourceObject != null && DetailTargetObjMap.Containskey(s) && DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c != null && HeaderSourceObject.toUpperCase() != DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c.touppercase())
                    {
                        system.debug('Entered in SOURCE != SOURCECHILD');
                        //get the Sorce object Records to calculate how many target to be created
                        if(SourceObjParentColumnMap.containskey(DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c))
                        {
                            DetSourceSobjList = BuildSobject.getINTF_BuildSobject(RecId,DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c,SourceObjParentColumnMap.get(DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c),null);
                            system.debug('DetSourceSobjList'+DetSourceSobjList);
                        }
                        if(DetSourceSobjList.size() > 0 )
                        {
                            DetTargerSobjList = BuildSobject.getINTF_BuildSobject(null,DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c,null,DetSourceSobjList.size());
                            system.debug('DetTargerSobjList'+DetTargerSobjList);
                        }    
                        //Expression Qualification...   
                        if(DetSourceSobjList.size() > 0 && DetailTargetObjMap.get(s).SVMXC__Submodule__c != null)
                        {
                            system.debug('Expression Qualification...');
                            SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                            Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: DetailTargetObjMap.get(s).SVMXC__Submodule__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                            if(Expression != null)
                            {
                                SFMExpression.namedExpression = Expression;
                            }
                            if(SFMExpression != null && SFMExpression.namedExpression != null)
                            {
                                DetSourceSobjList = ExpParssig.INTF_ParseExpression(DetSourceSobjList,SFMExpression);
                            }    
                        }//if DetSourceSobjList's size is greate then zeor then its Quelified and if then is no expresion then its autometically quelify now go for apply mapping
                        if((DetTargerSobjList.size() > 0 && DetSourceSobjList.size() > 0) || (DetailTargetObjMap.get(s).SVMXC__Submodule__c == null && DetTargerSobjList.size() > 0))
                        {
                            if(DetailTargetObjMap.get(s).SVMXC__Module__c != null)
                            {
                                list<Sobject> FinalTargetSobjList = new list<Sobject>();
                                map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
                                for(Integer i = 0;i< DetSourceSobjList.size();i++)
                                {
                                    if(DetSourceSobjList[i].get('Id') != null)
                                        SourceRecIdTargetObjMap.put(String.valueof(DetSourceSobjList[i].get('Id')),DetTargerSobjList[i]);
                                }
                                FinalTargetSobjList.addall(Applymapping.getApplyMapping1(String.valueof(DetailTargetObjMap.get(s).SVMXC__Module__c),SourceRecIdTargetObjMap,false,allobjmap));
                                system.debug('FinalTargetSobjList'+FinalTargetSobjList);
                                DetailObjMap.put(s,FinalTargetSobjList);
                            }
                            else
                            {
                                DetailObjMap.put(s,DetTargerSobjList);
                            }   
                                
                        }
                        system.debug('DetailObjMap'+DetailObjMap.size()+DetailObjMap);
                    }
                    //if the SOURCE is match with the SOURCECHILD then 
                    if(HeaderSourceObject != null && DetailTargetObjMap.Containskey(s) && DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c != null && HeaderSourceObject.toUpperCase() == DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c.touppercase())
                    {
                        system.debug('Entered in SOURCE == SOURCECHILD');
                        //Create source to Check Expression Qualification..
                        DetSourceSobjList = BuildSobject.getINTF_BuildSobject(RecId,HeaderSourceObject,null,null);
                        system.debug('DetSourceSobjList'+DetSourceSobjList);
                        //Expression Qualification...
                        list<Sobject> ExpSobjList = new list<Sobject>();
                        if(DetSourceSobjList.size() > 0  && DetailTargetObjMap.get(s).SVMXC__Submodule__c != null)//&& DetTargerSobjList.size() > 0
                        {
                            system.debug('Entered in Detail Expression Qualification...');
                           /* //Create Request..
                            SVMXC.INTF_WebServicesDef.INTF_Request SFMRequest = new SVMXC.INTF_WebServicesDef.INTF_Request();  
                            //Create StringMap..
                            SVMXC.INTF_WebServicesDef.INTF_StringMap StringMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap('EXPRESSIONID',DetailTargetObjMap.get(s).SVMXC__Submodule__c);
                            List<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                            StringMapList.add(StringMap);
                            SFMRequest.stringMap = StringMapList;
                            //Create Return Type to handel response.. 
                            List<SVMXC.INTF_WebServicesDef.INTF_Expression> SFMExpression = new List<SVMXC.INTF_WebServicesDef.INTF_Expression>();
                            SVMXC.INTF_WebServicesDef.INTF_Response_Expression ResponseExpression = new SVMXC.INTF_WebServicesDef.INTF_Response_Expression(); 
                            ResponseExpression = NamedExpCall.INTF_getNamedExpressionList(SFMRequest);
                            SFMExpression = ResponseExpression.expressions;
                            system.debug('SFMExpression'+SFMExpression);
                            system.debug('DetSourceSobjList'+DetSourceSobjList);
                            system.debug('SFMExpression[0]'+SFMExpression[0]);
                            if(SFMExpression != null && SFMExpression.size() > 0)
                                ExpSobjList = ExpParssig.INTF_ParseExpression(DetSourceSobjList,SFMExpression[0]);*/
                            SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                            Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: DetailTargetObjMap.get(s).SVMXC__Submodule__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                            if(Expression != null)
                            {
                                SFMExpression.namedExpression = Expression;
                            }
                            if(SFMExpression != null && SFMExpression.namedExpression != null)
                            {    
                                ExpSobjList = ExpParssig.INTF_ParseExpression(DetSourceSobjList,SFMExpression);
                            }
                            system.debug('DetSourceSobjList'+DetSourceSobjList);    
                        }//if  DetSourceSobjList's size is greate then zeor then its Quelified and if then is no expresion then its autometically quelify now go for apply mapping
                        if((ExpSobjList.size() > 0  && DetSourceSobjList.size() > 0) || (DetailTargetObjMap.get(s).SVMXC__Submodule__c == null && DetSourceSobjList.size() > 0))//&& DetTargerSobjList.size() > 0
                        {
                            //Create Target..
                            system.debug('Test111::');
                            DetTargerSobjList = BuildSobject.getINTF_BuildSobject(null,DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c,null,null);
                            system.debug('DetTargerSobjList'+DetTargerSobjList);
                            if(DetailTargetObjMap.get(s).SVMXC__Module__c != null)
                            {
                                system.debug('Entered in Detail apply mapping...');
                                DetTargerSobjList = Applymapping.getApplyMapping(DetTargerSobjList,DetailTargetObjMap.get(s).SVMXC__Module__c,RecId,false,allobjmap);
                            }   
                            system.debug('DetTargerSobjList'+DetTargerSobjList);
                        }
                        system.debug('purav'+s);
                        system.debug('purav'+DetTargerSobjList);
                        DetailObjMap.put(s,DetTargerSobjList);
                        system.debug('DetailObjMap'+DetailObjMap);
                    }
                }
            }
        }
        if(SFMProcess.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')
        {
             system.debug('Enter in SOURCE TO TARGET CHILD Process mode');
            //Get the Header Target..
            if(HeaderTargetObject != null && HeaderTargetObject.length() > 0)
            {
                list<Sobject> HeaderSobjList = new list<Sobject>();
                HeaderSobjList =  BuildSobject.getINTF_BuildSobject(RecId,HeaderTargetObject,null,null);
                system.debug('HeaderSobjList'+HeaderSobjList);
                //Expression Qualification...
                if(HdrExpression != null && HdrExpression.length() > 0 && HeaderSobjList.size() > 0)
                {
                    system.debug('Enter in Header Expression Qualification..');
                    
                   /* //Create Request..
                    SVMXC.INTF_WebServicesDef.INTF_Request SFMRequest = new SVMXC.INTF_WebServicesDef.INTF_Request();  
                    //Create StringMap..
                    SVMXC.INTF_WebServicesDef.INTF_StringMap StringMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap('EXPRESSIONID',HdrExpression);
                    List<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    StringMapList.add(StringMap);
                    SFMRequest.stringMap = StringMapList;
                    //Create Return Type to handel response.. 
                    List<SVMXC.INTF_WebServicesDef.INTF_Expression> SFMExpression = new List<SVMXC.INTF_WebServicesDef.INTF_Expression>();
                    SVMXC.INTF_WebServicesDef.INTF_Response_Expression ResponseExpression = new SVMXC.INTF_WebServicesDef.INTF_Response_Expression(); 
                    ResponseExpression = NamedExpCall.INTF_getNamedExpressionList(SFMRequest);
                    SFMExpression = ResponseExpression.expressions;
                    if(SFMExpression != null && SFMExpression.size() > 0)
                    {
                        system.debug('SFMExpression'+SFMExpression[0]);
                        system.debug('HeaderSobjList'+HeaderSobjList);
                        HeaderSobjList = ExpParssig.INTF_ParseExpression(HeaderSobjList,SFMExpression[0]);
                    }  */
                    SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                    Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: HdrExpression];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                    if(Expression != null)
                    {
                        SFMExpression.namedExpression = Expression;
                    }
                    if(SFMExpression != null && SFMExpression.namedExpression != null)
                    { 
                        system.debug('SFMExpression'+SFMExpression);
                        system.debug('HeaderSobjList'+HeaderSobjList);
                        HeaderSobjList = ExpParssig.INTF_ParseExpression(HeaderSobjList,SFMExpression);
                    }
                    system.debug('HeaderSobjList'+HeaderSobjList);  
                }//if HeaderSobjList's size is greate then zeor then its Quelified OR if there is no expresion then its autometically quelify now go for apply mapping  
                if(HeaderSobjList.size() > 0 ||(HdrExpression == null && HdrExpression.length() == 0 && HeaderSobjList.size() > 0))
                {
                    HeaderObjMap.put(HeaderTargetObject,HeaderSobjList);
                    system.debug('HeaderObjMap'+HeaderObjMap);    
                }
            }
            for(String s : DetailTargetObjMap.keyset())
            {
                if(HeaderSourceObject != null && DetailTargetObjMap.Containskey(s) && DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c != null && HeaderSourceObject.toUpperCase() != DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c.touppercase())
                {
                    list<Sobject> DetailSourceSobjectList = new list<Sobject>(); 
                    list<Sobject> DetailTargetSobjectList = new list<Sobject>();
                    //get the Sorce object Records to calculate how many target to be created
                    if(SourceObjParentColumnMap.containskey(DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c))
                        DetailSourceSobjectList = BuildSobject.getINTF_BuildSobject(RecId,DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c,SourceObjParentColumnMap.get(DetailTargetObjMap.get(s).SVMXC__Node_Source_Object_API__c),null);
                    system.debug('DetailSourceSobjectList'+DetailSourceSobjectList.size()+DetailSourceSobjectList);
                    if(DetailSourceSobjectList.size() > 0 )
                        DetailTargetSobjectList = BuildSobject.getINTF_BuildSobject(null,DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c,null,DetailSourceSobjectList.size());
                    system.debug('DetailTargetSobjectList'+DetailTargetSobjectList.size()+DetailTargetSobjectList);
                    //Expression Qualification...   
                    if(DetailSourceSobjectList.size() > 0 && DetailTargetObjMap.get(s).SVMXC__Submodule__c != null)
                    {
                        system.debug('Expression Qualification...');
                        /*//Create Request..
                        SVMXC.INTF_WebServicesDef.INTF_Request SFMRequest = new SVMXC.INTF_WebServicesDef.INTF_Request();  
                        //Create StringMap..
                        SVMXC.INTF_WebServicesDef.INTF_StringMap StringMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap('EXPRESSIONID',DetailTargetObjMap.get(s).SVMXC__Submodule__c);
                        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                        StringMapList.add(StringMap);
                        SFMRequest.stringMap = StringMapList;
                        //Create Return Type to handel response.. 
                        List<SVMXC.INTF_WebServicesDef.INTF_Expression> SFMExpression = new List<SVMXC.INTF_WebServicesDef.INTF_Expression>();
                        SVMXC.INTF_WebServicesDef.INTF_Response_Expression ResponseExpression = new SVMXC.INTF_WebServicesDef.INTF_Response_Expression(); 
                        ResponseExpression = NamedExpCall.INTF_getNamedExpressionList(SFMRequest);
                        SFMExpression = ResponseExpression.expressions;
                        if(SFMExpression != null && SFMExpression.size() > 0)
                            DetailSourceSobjectList = ExpParssig.INTF_ParseExpression(DetailSourceSobjectList,SFMExpression[0]);*/
                        SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
                        Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: DetailTargetObjMap.get(s).SVMXC__Submodule__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                        if(Expression != null)
                        {
                            SFMExpression.namedExpression = Expression;
                        }
                        if(SFMExpression != null && SFMExpression.namedExpression != null)
                        {    
                            DetailSourceSobjectList = ExpParssig.INTF_ParseExpression(DetailSourceSobjectList,SFMExpression);
                        }    
                    }//if DetailSourceSobjectList's size is greate then zeor then its Quelified and if then is no expresion then its autometically quelify now go for apply mapping
                    system.debug('DetailSourceSobjectList'+DetailSourceSobjectList);
                    if((DetailTargetSobjectList.size() > 0 && DetailSourceSobjectList.size() > 0 ) || (DetailTargetObjMap.get(s).SVMXC__Submodule__c == null && DetailTargetSobjectList.size() > 0))
                    {
                        if(DetailTargetObjMap.get(s).SVMXC__Module__c != null)
                        {
                            list<Sobject> FinalTargetSobjList = new list<Sobject>();
                            map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject>();
                            for(Integer i = 0;i< DetailSourceSobjectList.size();i++)
                            {
                                if(DetailSourceSobjectList[i].get('Id') != null )
                                    SourceRecIdTargetObjMap.put(String.valueof(DetailSourceSobjectList[i].get('Id')),DetailTargetSobjectList[i]);
                            }
                            FinalTargetSobjList.addall(Applymapping.getApplyMapping1(String.valueof(DetailTargetObjMap.get(s).SVMXC__Module__c),SourceRecIdTargetObjMap,false,allobjmap));
                            DetailObjMap.put(s,FinalTargetSobjList);
                        }
                        else
                        {
                            DetailObjMap.put(s,DetailTargetSobjectList);
                        }    
                    }
                    system.debug('DetailObjMap'+DetailObjMap.size()+DetailObjMap);
                }
            }    
        }
        //Now Process For the DataTime...
        if(HeaderObjMap.size() > 0 && HeaderTargetObject != null && HeaderTargetObject.length() > 0)
        {
            list<Sobject> HdrSObject = new list<Sobject>();
            map<String, Schema.SObjectField> HeaderFieldMap = new map<String, Schema.SObjectField>();
            //get the Header Sobject from header map
            if(HeaderObjMap.containskey(HeaderTargetObject))
                HdrSObject = HeaderObjMap.get(HeaderTargetObject);
            //if the AllFieldDescribe is not haveing the data then Do the Hdr obj field describe an put in the AllFieldDescribe
            if(allobjmap.containskey(HeaderTargetObject) && AllFieldDescribe.containskey(HeaderTargetObject) == false)
            {
                map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
                map<String, Schema.SObjectField> TempFieldMap = new map<String, Schema.SObjectField>();
                FieldMap = allobjmap.get(HeaderTargetObject).getDescribe().fields.getMap();
                if(FieldMap.size() > 0)
                {
                    for(String s : FieldMap.keyset())
                    {
                        TempFieldMap.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
                    }
                    AllFieldDescribe.put(HeaderTargetObject,TempFieldMap);
                }
            }    
            if(AllFieldDescribe.containskey(HeaderTargetObject))
            {
                HeaderFieldMap = AllFieldDescribe.get(HeaderTargetObject);
                if(HdrSObject.size() > 0 && HeaderFieldMap.size() > 0)
                {
                    for(String s : HeaderFieldMap.keyset())
                    {
                        Schema.DescribeFieldResult f = HeaderFieldMap.get(s).getDescribe();
                        // Bala: we should not do conversion of datetime in parse process
                        /*if(f.isAccessible() && f.isCreateable() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//
                        {
                            if(HdrSObject[0].get(s) != null)
                            {
                                system.debug('zzzzzz'+HdrSObject[0].get(s));
                                String dat = (datetime.valueof(HdrSObject[0].get(s))).format('yyyy-MM-dd HH:mm:ss');
                                //system.debug('zzzzzz'+DateTime.valueof(HdrSObject.get(s)).dateGmt());
                                //system.debug('zzzzzz'+DateTime.valueof(HdrSObject.get(s)).timeGmt());
                                system.debug('zzzzzz'+dat); 
                                HdrSObject[0].put(s,Datetime.valueofgmt(dat));
                            }
                        }*/
                    }
                    OutputMap.put(HeaderTargetObject,HdrSObject);
                }   
            } 
        }
        if(DetailObjMap.size() > 0 && DetailTargetObjMap.size() > 0)
        {
            for(String s :DetailObjMap.keyset())
            {
                list<Sobject> DtlSObject = new list<Sobject>();
                String ObjName = '';
                DtlSObject = DetailObjMap.get(s);
                system.debug('DtlSObject'+DtlSObject);
                if(DetailTargetObjMap.containskey(s))
                    ObjName = DetailTargetObjMap.get(s).SVMXC__Source_Object_Name__c;
                if(ObjName != null & ObjName.length() > 0 && allobjmap.containskey(ObjName) && AllFieldDescribe.containskey(ObjName) == false)
                {
                    map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
                    map<String, Schema.SObjectField> TempFieldMap = new map<String, Schema.SObjectField>();
                    FieldMap = allobjmap.get(ObjName).getDescribe().fields.getMap();
                    if(FieldMap.size() > 0)
                    {
                        for(String s1 : FieldMap.keyset())
                        {
                            TempFieldMap.put(FieldMap.get(s1).getDescribe().getName(),FieldMap.get(s1));
                        }
                        if(TempFieldMap.size() > 0)
                            AllFieldDescribe.put(ObjName,TempFieldMap);
                    }
                }
                if(allobjmap.containskey(ObjName) && AllFieldDescribe.containskey(ObjName))
                {
                    map<String, Schema.SObjectField> DtlFieldMap = new map<String, Schema.SObjectField>();
                    DtlFieldMap = AllFieldDescribe.get(ObjName);
                    if(DtlFieldMap.size() > 0 && DtlSObject.size() > 0)
                    {
                        for(Integer i = 0;i<DtlSObject.size();i++)
                        {
                            for(String s2 : DtlFieldMap.keyset())
                            {
                                Schema.DescribeFieldResult f = DtlFieldMap.get(s2).getDescribe();
                                // Bala: we should not do conversion of datetime in parse process
                                /*if(f.isAccessible() && f.isCreateable() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()
                                {
                                    if(DtlSObject[i].get(s2) != null)
                                    {
                                        system.debug('zzzzzz'+DtlSObject[i].get(s2));
                                        String dat2 = (datetime.valueof(DtlSObject[i].get(s2))).format('yyyy-MM-dd HH:mm:ss');
                                        //system.debug('zzzzzz'+DateTime.valueof(DtlSObject[i].get(s2)).dateGmt());
                                        //system.debug('zzzzzz'+DateTime.valueof(DtlSObject[i].get(s2)).timeGmt());
                                        system.debug('zzzzzz'+dat2); 
                                        DtlSObject[i].put(s2,datetime.valueofgmt(dat2));
                                    }
                                }*/
                            }
                        }
                    }
                }
                OutputMap.put(s,DtlSObject);    
            }
        }
        system.debug('OutputMap'+OutputMap.size()+OutputMap);
        return OutputMap;
    }
}