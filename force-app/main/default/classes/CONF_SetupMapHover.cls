public with sharing class CONF_SetupMapHover 
{

    //Variable Declaration.. 
    public String strRuleRtypeId = '';
    public String strExpressionRTypeId = '';
    public Boolean isHdrMsg = false;
    public list<SelectOption> lstWorkOrderUpdatableFields{get;set;}
    public list<SelectOption> lstLocationUpdatableFields{get;set;}
    public list<SelectOption> lstAccountUpdatableFields{get;set;}
    public list<SelectOption> lstTechnicianHoverFields {get;set;}
    public list<SelectOption> lstTeamHoverFields{get;set;}
    public String strWODisplayField1 {get;set;}
    public String strWODisplayField2 {get;set;}
    public String strWODisplayField3 {get;set;}
    public String strWODisplayField4 {get;set;}
    public String strWODisplayField5 {get;set;}
    public String strWODisplayField6 {get;set;}
    public String strWODisplayField7 {get;set;}
    public String strWODisplayField8 {get;set;}
    public String strWODisplayField9 {get;set;}
    public String strWODisplayField10 {get;set;}
    public String strLocDisplayField1 {get;set;}
    public String strLocDisplayField2 {get;set;}
    public String strLocDisplayField3 {get;set;}
    public String strLocDisplayField4 {get;set;}
    public String strLocDisplayField5 {get;set;}
    public String strLocDisplayField6 {get;set;}
    public String strLocDisplayField7 {get;set;}
    public String strLocDisplayField8 {get;set;}
    public String strLocDisplayField9 {get;set;}
    public String strLocDisplayField10 {get;set;}
    public String strAccDisplayField1 {get;set;}
    public String strAccDisplayField2 {get;set;}
    public String strAccDisplayField3 {get;set;}
    public String strAccDisplayField4 {get;set;}
    public String strAccDisplayField5 {get;set;}
    public String strAccDisplayField6 {get;set;}
    public String strAccDisplayField7 {get;set;}
    public String strAccDisplayField8 {get;set;}
    public String strAccDisplayField9 {get;set;}
    public String strAccDisplayField10 {get;set;}
    public String strTechDisplayField1 {get;set;}
    public String strTechDisplayField2 {get;set;}
    public String strTechDisplayField3 {get;set;}
    public String strTechDisplayField4 {get;set;}
    public String strTechDisplayField5 {get;set;}
    public String strTechDisplayField6 {get;set;}
    public String strTechDisplayField7 {get;set;}
    public String strTechDisplayField8 {get;set;}
    public String strTechDisplayField9 {get;set;}
    public String strTechDisplayField10 {get;set;}
    public String strTeamDisplayField1 {get;set;}
    public String strTeamDisplayField2 {get;set;}
    public String strTeamDisplayField3 {get;set;}
    public String strTeamDisplayField4 {get;set;}
    public String strTeamDisplayField5 {get;set;}
    public String strTeamDisplayField6 {get;set;}
    public String strTeamDisplayField7 {get;set;}
    public String strTeamDisplayField8 {get;set;}
    public String strTeamDisplayField9 {get;set;}
    public String strTeamDisplayField10 {get;set;}
    list<RecordType> lstRecordType = new list<RecordType>();
    public map<String,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<String,SVMXC__ServiceMax_Processes__c>(); 
    public list<SVMXC__ServiceMax_Processes__c> lstSVMXProcess = new list<SVMXC__ServiceMax_Processes__c>();
    public SVMXC__ServiceMax_Processes__c objProcessForWO = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c objProcessForLocation = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c objProcessForAccount = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c objProcessForTech = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c objProcessForTeam = new SVMXC__ServiceMax_Processes__c();
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForWO = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForLocation = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForAccount = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForTech = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForTeam = new list<SVMXC__ServiceMax_Config_Data__c>();
    public map<String,String> mapProIdObjectName = new map<String,String>();
    public map<String,Schema.SObjectField> mapWOFldDesc = new map<String,Schema.SObjectField>();
    public map<String,Schema.SObjectField> mapLocFldDesc = new map<String,Schema.SObjectField>();
    public map<String,Schema.SObjectField> mapAccFldDesc = new map<String,Schema.SObjectField>();
    public map<String,Schema.SObjectField> mapTechFldDesc = new map<String,Schema.SObjectField>();
    public map<String,Schema.SObjectField> mapTeamFldDesc = new map<String,Schema.SObjectField>();
    public map<Integer,String> mapWOFields = new map<Integer,String>();
    public map<Integer,String> mapLocFields = new map<Integer,String>();
    public map<Integer,String> mapAccFields = new map<Integer,String>();
    public map<Integer,String> mapTechFields = new map<Integer,String>();
    public map<Integer,String> mapTeamFields  = new map<Integer,String>();
    public map<String,String> mapQueryStringParameter = new map<String,String>();
    public Boolean getisHdrMsg(){return isHdrMsg;} 
    public String strReturnURL = '';
    
    


    // Constructor..
    public CONF_SetupMapHover()
    {
        
        mapQueryStringParameter = ApexPages.currentPage().getParameters();
        if(mapQueryStringParameter.containskey('SVMX_retURL'))
            strReturnURL = mapQueryStringParameter.get('SVMX_retURL');
        lstRecordType = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Processes__c' OR SObjectType='SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstRecordType.size() > 0)
        {
            for(RecordType r : lstRecordType)
            {
                if(r.Name == 'SVMX Rule')
                    strRuleRtypeId = r.id;
                if(r.Name == 'Expressions')
                    strExpressionRTypeId = r.id;    
            }    
        }
        //Work Order
        lstWorkOrderUpdatableFields = new List<SelectOption>();
        lstWorkOrderUpdatableFields.add(new SelectOption('--None--',getTAG013()));
        
        map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
        map<String,Schema.SObjectField> mapTempDesc = new map<String,Schema.SObjectField>();
        mapTempDesc = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();
        if(mapTempDesc.size() > 0)
        {
            for(String str : mapTempDesc.keyset())
            {
                Schema.DescribeFieldResult f = mapTempDesc.get(str).getDescribe();
                if(!f.isHtmlFormatted() || f.getType() != schema.Displaytype.TextArea)
                {
                    if(f.getType() == Schema.DisplayType.Reference)
                    {
                        if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                        {
                            if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                            {
                                continue;
                            }
                        }
                    }
                    mapWOFldDesc.put(f.getName(),mapTempDesc.get(str));
                    lstWorkOrderUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
                }   
            }
            lstWorkOrderUpdatableFields = sortingSelectOption(lstWorkOrderUpdatableFields); 
        }
        //Location..
        lstLocationUpdatableFields = new List<SelectOption>();
        lstLocationUpdatableFields.add(new SelectOption('--None--',getTAG013()));
        mapTempDesc = new map<String,Schema.SObjectField>();
        mapTempDesc = SVMXC__Site__c.SObjectType.getDescribe().fields.getMap();
        if(mapTempDesc.size() > 0)
        {
            for(String str : mapTempDesc.keyset())
            {
                Schema.DescribeFieldResult f = mapTempDesc.get(str).getDescribe();
                if(!f.isHtmlFormatted() || f.getType() != schema.Displaytype.TextArea)
                {
                    if(f.getType() == Schema.DisplayType.Reference)
                    {
                        if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                        {
                            if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                            {
                                continue;
                            }
                        }
                    }
                    mapLocFldDesc.put(f.getName(),mapTempDesc.get(str));
                    lstLocationUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
                }   
            }
            lstLocationUpdatableFields = sortingSelectOption(lstLocationUpdatableFields);   
        }
        //Account..
        lstAccountUpdatableFields = new List<SelectOption>();
        lstAccountUpdatableFields.add(new SelectOption('--None--',getTAG013()));
        mapTempDesc = new map<String,Schema.SObjectField>();
        mapTempDesc = Account.SObjectType.getDescribe().fields.getMap();
        if(mapTempDesc.size() > 0)
        {
            for(String str : mapTempDesc.keyset())
            {
                Schema.DescribeFieldResult f = mapTempDesc.get(str).getDescribe();
                if(!f.isHtmlFormatted() || f.getType() != schema.Displaytype.TextArea)
                {
                    if(f.getType() == Schema.DisplayType.Reference)
                    {
                        if((f.getReferenceTo()!= null && f.getReferenceTo().size()>0) && !comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                        {
                            if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                            {
                                continue;
                            }
                        }
                    }
                    mapAccFldDesc.put(f.getName(),mapTempDesc.get(str));
                    lstAccountUpdatableFields.add(new SelectOption(f.getName(),f.getLabel()));
                }   
            }
            lstAccountUpdatableFields = sortingSelectOption(lstAccountUpdatableFields); 
        }
        //Technician..
         lstTechnicianHoverFields = new List<SelectOption>();
        lstTechnicianHoverFields.add(new SelectOption('--None--',getTAG013()));
        mapTempDesc = new map<String,Schema.SObjectField>();
        mapTempDesc = SVMXC__Service_Group_Members__c.SObjectType.getDescribe().fields.getMap();
        if(mapTempDesc.size() > 0)
        {
            for(String str : mapTempDesc.keyset())
            {
                Schema.DescribeFieldResult f = mapTempDesc.get(str).getDescribe();
                if(!f.isHtmlFormatted() || f.getType() != schema.Displaytype.TextArea)
                {
                    if(f.getType() == Schema.DisplayType.Reference)
                    {
                        if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                        {
                            if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                            {
                                continue;
                            }
                        }
                    }
                  mapTechFldDesc.put(f.getName(),mapTempDesc.get(str));
                  lstTechnicianHoverFields.add(new SelectOption(f.getName(),f.getLabel()));
                }  
            }
            lstTechnicianHoverFields = sortingSelectOption(lstTechnicianHoverFields);   
        }
        lstTeamHoverFields = new List<SelectOption>();
        lstTeamHoverFields.add(new SelectOption('--None--',getTAG013()));
        mapTempDesc = new map<String,Schema.SObjectField>();
        mapTempDesc = SVMXC__Service_Group__c.SObjectType.getDescribe().fields.getMap();
        if(mapTempDesc.size() > 0)
        {
            for(String str : mapTempDesc.keyset())
            {
                Schema.DescribeFieldResult f = mapTempDesc.get(str).getDescribe();
                if(!f.isHtmlFormatted() || f.getType() != schema.Displaytype.TextArea)
                {
                    if(f.getType() == Schema.DisplayType.Reference)
                    {
                        if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                        {
                            if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                            {
                                continue;
                            }
                        }
                    }
                  mapTeamFldDesc.put(f.getName(),mapTempDesc.get(str));
                  lstTeamHoverFields.add(new SelectOption(f.getName(),f.getLabel()));
                }  
            }
            lstTeamHoverFields = sortingSelectOption(lstTeamHoverFields);   

        }

        //Query existing Servicemax Process
        lstSVMXProcess = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstSVMXProcess != null && lstSVMXProcess.size() > 0)
        {
            objProcessForWO = lstSVMXProcess[0];
            lstConfigDataForWO = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForWO.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        lstSVMXProcess.clear(); 
        lstSVMXProcess = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Site__c' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstSVMXProcess != null && lstSVMXProcess.size() > 0)
        {
            objProcessForLocation = lstSVMXProcess[0];
            lstConfigDataForLocation = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForLocation.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        lstSVMXProcess.clear(); 
        lstSVMXProcess = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'Account' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstSVMXProcess != null && lstSVMXProcess.size() > 0)
        {
            objProcessForAccount = lstSVMXProcess[0];
            lstConfigDataForAccount = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForAccount.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        lstSVMXProcess.clear(); 
        lstSVMXProcess = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group_Members__c' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstSVMXProcess != null && lstSVMXProcess.size() > 0)
        {
            objProcessForTech = lstSVMXProcess[0];
            lstConfigDataForTech = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForTech.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        lstSVMXProcess.clear(); 
        lstSVMXProcess = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group__c' limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstSVMXProcess != null && lstSVMXProcess.size() > 0)
        {
            objProcessForTeam = lstSVMXProcess[0];
            lstConfigDataForTeam = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForTeam.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        //Populate Work Order Fields
        map<Integer,String> mapTemp = new map<Integer,String>();
        if(lstConfigDataForWO.size() > 0)
        {
            for(integer i = 0;i<lstConfigDataForWO.size();i++)
            {
                if(lstConfigDataForWO[i].SVMXC__Field_Name__c != null)
                    mapTemp.put(i+1,lstConfigDataForWO[i].SVMXC__Field_Name__c);
            }
            if(mapTemp.size() > 0)
            {
                if(mapTemp.containskey(1) && mapTemp.get(1) != null)
                    strWODisplayField1 = mapTemp.get(1);
                if(mapTemp.containskey(2) && mapTemp.get(2) != null)
                    strWODisplayField2 = mapTemp.get(2);
                if(mapTemp.containskey(3) && mapTemp.get(3) != null)
                    strWODisplayField3 = mapTemp.get(3);
                if(mapTemp.containskey(4) && mapTemp.get(4) != null)
                    strWODisplayField4 = mapTemp.get(4);
                if(mapTemp.containskey(5) && mapTemp.get(5) != null)
                    strWODisplayField5 = mapTemp.get(5);
                if(mapTemp.containskey(6) && mapTemp.get(6) != null)
                    strWODisplayField6 = mapTemp.get(6);
                if(mapTemp.containskey(7) && mapTemp.get(7) != null)
                    strWODisplayField7 = mapTemp.get(7);
                if(mapTemp.containskey(8) && mapTemp.get(8) != null)
                    strWODisplayField8 = mapTemp.get(8);
                if(mapTemp.containskey(9) && mapTemp.get(9) != null)
                    strWODisplayField9 = mapTemp.get(9);
                if(mapTemp.containskey(10) && mapTemp.get(10) != null)
                    strWODisplayField10 = mapTemp.get(10);
            }
        }
        //Populate Location Fields
        if(lstConfigDataForLocation.size() > 0)
        {
            mapTemp = new map<Integer,String>();
            for(integer i = 0;i<lstConfigDataForLocation.size();i++)
            {
                if(lstConfigDataForLocation[i].SVMXC__Field_Name__c != null)
                    mapTemp.put(i+1,lstConfigDataForLocation[i].SVMXC__Field_Name__c);
            }
            if(mapTemp.size() > 0)
            {
                if(mapTemp.containskey(1) && mapTemp.get(1) != null)
                    strLocDisplayField1 = mapTemp.get(1);
                if(mapTemp.containskey(2) && mapTemp.get(2) != null)
                    strLocDisplayField2 = mapTemp.get(2);
                if(mapTemp.containskey(3) && mapTemp.get(3) != null)
                    strLocDisplayField3 = mapTemp.get(3);
                if(mapTemp.containskey(4) && mapTemp.get(4) != null)
                    strLocDisplayField4 = mapTemp.get(4);
                if(mapTemp.containskey(5) && mapTemp.get(5) != null)
                    strLocDisplayField5 = mapTemp.get(5);
                if(mapTemp.containskey(6) && mapTemp.get(6) != null)
                    strLocDisplayField6 = mapTemp.get(6);
                if(mapTemp.containskey(7) && mapTemp.get(7) != null)
                    strLocDisplayField7 = mapTemp.get(7);
                if(mapTemp.containskey(8) && mapTemp.get(8) != null)
                    strLocDisplayField8 = mapTemp.get(8);
                if(mapTemp.containskey(9) && mapTemp.get(9) != null)
                    strLocDisplayField9 = mapTemp.get(9);
                if(mapTemp.containskey(10) && mapTemp.get(10) != null)
                    strLocDisplayField10 = mapTemp.get(10);
            }
        }
        //Populate Account Fields
        if(lstConfigDataForAccount.size() > 0)
        {
            mapTemp = new map<Integer,String>();
            for(integer i = 0;i<lstConfigDataForAccount.size();i++)
            {
                if(lstConfigDataForAccount[i].SVMXC__Field_Name__c != null)
                    mapTemp.put(i+1,lstConfigDataForAccount[i].SVMXC__Field_Name__c);
            }
            if(mapTemp.size() > 0)
            {
                if(mapTemp.containskey(1) && mapTemp.get(1) != null)
                    strAccDisplayField1 = mapTemp.get(1);
                if(mapTemp.containskey(2) && mapTemp.get(2) != null)
                    strAccDisplayField2 = mapTemp.get(2);
                if(mapTemp.containskey(3) && mapTemp.get(3) != null)
                    strAccDisplayField3 = mapTemp.get(3);
                if(mapTemp.containskey(4) && mapTemp.get(4) != null)
                    strAccDisplayField4 = mapTemp.get(4);
                if(mapTemp.containskey(5) && mapTemp.get(5) != null)
                    strAccDisplayField5 = mapTemp.get(5);
                if(mapTemp.containskey(6) && mapTemp.get(6) != null)
                    strAccDisplayField6 = mapTemp.get(6);
                if(mapTemp.containskey(7) && mapTemp.get(7) != null)
                    strAccDisplayField7 = mapTemp.get(7);
                if(mapTemp.containskey(8) && mapTemp.get(8) != null)
                    strAccDisplayField8 = mapTemp.get(8);
                if(mapTemp.containskey(9) && mapTemp.get(9) != null)
                    strAccDisplayField9 = mapTemp.get(9);
                if(mapTemp.containskey(10) && mapTemp.get(10) != null)
                    strAccDisplayField10 = mapTemp.get(10);
            }
        }
        //Populate Technician Fields
        if(lstConfigDataForTech.size() > 0)
        {
            mapTemp = new map<Integer,String>();
            for(integer i = 0;i<lstConfigDataForTech.size();i++)
            {
                if(lstConfigDataForTech[i].SVMXC__Field_Name__c != null)
                    mapTemp.put(i+1,lstConfigDataForTech[i].SVMXC__Field_Name__c);
            }
            if(mapTemp.size() > 0)
            {
                if(mapTemp.containskey(1) && mapTemp.get(1) != null)
                    strTechDisplayField1 = mapTemp.get(1);
                if(mapTemp.containskey(2) && mapTemp.get(2) != null)
                    strTechDisplayField2 = mapTemp.get(2);
                if(mapTemp.containskey(3) && mapTemp.get(3) != null)
                    strTechDisplayField3 = mapTemp.get(3);
                if(mapTemp.containskey(4) && mapTemp.get(4) != null)
                    strTechDisplayField4 = mapTemp.get(4);
                if(mapTemp.containskey(5) && mapTemp.get(5) != null)
                    strTechDisplayField5 = mapTemp.get(5);
                if(mapTemp.containskey(6) && mapTemp.get(6) != null)
                    strTechDisplayField6 = mapTemp.get(6);
                if(mapTemp.containskey(7) && mapTemp.get(7) != null)
                    strTechDisplayField7 = mapTemp.get(7);
                if(mapTemp.containskey(8) && mapTemp.get(8) != null)
                    strTechDisplayField8 = mapTemp.get(8);
                if(mapTemp.containskey(9) && mapTemp.get(9) != null)
                    strTechDisplayField9 = mapTemp.get(9);
                if(mapTemp.containskey(10) && mapTemp.get(10) != null)
                    strTechDisplayField10 = mapTemp.get(10);
            }
        }
        
         //Populate Team Fields
        if(lstConfigDataForTeam.size() > 0)
        {
            mapTemp = new map<Integer,String>();
            for(integer i = 0;i<lstConfigDataForTeam.size();i++)
            {
                if(lstConfigDataForTeam[i].SVMXC__Field_Name__c != null)
                    mapTemp.put(i+1,lstConfigDataForTeam[i].SVMXC__Field_Name__c);
            }
            if(mapTemp.size() > 0)
            {
                if(mapTemp.containskey(1) && mapTemp.get(1) != null)
                    strTeamDisplayField1 = mapTemp.get(1);
                if(mapTemp.containskey(2) && mapTemp.get(2) != null)
                    strTeamDisplayField2 = mapTemp.get(2);
                if(mapTemp.containskey(3) && mapTemp.get(3) != null)
                    strTeamDisplayField3 = mapTemp.get(3);
                if(mapTemp.containskey(4) && mapTemp.get(4) != null)
                    strTeamDisplayField4 = mapTemp.get(4);
                if(mapTemp.containskey(5) && mapTemp.get(5) != null)
                    strTeamDisplayField5 = mapTemp.get(5);
                if(mapTemp.containskey(6) && mapTemp.get(6) != null)
                    strTeamDisplayField6 = mapTemp.get(6);
                if(mapTemp.containskey(7) && mapTemp.get(7) != null)
                    strTeamDisplayField7 = mapTemp.get(7);
                if(mapTemp.containskey(8) && mapTemp.get(8) != null)
                    strTeamDisplayField8 = mapTemp.get(8);
                if(mapTemp.containskey(9) && mapTemp.get(9) != null)
                    strTeamDisplayField9 = mapTemp.get(9);
                if(mapTemp.containskey(10) && mapTemp.get(10) != null)
                    strTeamDisplayField10 = mapTemp.get(10);
            }
        }
    }
 

    
    //Save Method
   public PageReference SVMX_Save()
    {
        isHdrMsg = false;
        PageReference myPage = new PageReference('/apex/CONF_SetupMapHover');
        if(isvalid())

        {
            SaveMapHoverForWO();
            SaveMapHoverForLocation();
            SaveMapHoverForAccount();
            //SaveMapHoverForTechnician();
            //SaveMapHoverForTeam();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Saved Successfully',''));
            isHdrMsg = true;
            return null;
        }
        else
        {
            system.debug('entered'+isHdrMsg);
            isHdrMsg = true;
            return null;
        }
    }
    public boolean isvalid()
    {
        boolean isvalidWOInfo = SVMX_ValidateWO();
        boolean isvalidLocInfo = SVMX_ValidateLoc();
        boolean isvalidAccInfo = SVMX_ValidateAcc();
        boolean isvalidTeamInfo = SVMX_ValidateTeam();
        boolean isvalidTechInfo = SVMX_ValidateTech();
        if(isvalidWOInfo && isvalidLocInfo && isvalidAccInfo && isvalidTeamInfo && isvalidTechInfo)
            return true;
        else
        return false;
    }    

    public PageReference SVMX_BackToSetupHome()
    {
        PageReference myPage;
        if(strReturnURL != null && strReturnURL.length() > 0)
        {
            String tempstrReturnURL = String.escapeSingleQuotes(strReturnURL);  
             //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                myPage = new PageReference('/lightning/n/SVMXC__ServiceMax_Setup');
            }else{
                myPage = new PageReference(tempstrReturnURL);
            }
        }
        else{
             if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                myPage = new PageReference('/lightning/n/SVMXC__ServiceMax_Setup');
            }else{
                myPage = new PageReference('/apex/CONF_SetupHome');
            }
        }
        //Security check
        //myPage = new PageReference(strReturnURL);
        return myPage;  
    }
    public void SaveMapHoverForWO()
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(objProcessForWO != null && objProcessForWO.id != null)
        {
            lstConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForWO.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstConfigData.size() > 0)
                delete lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else
        {
            objProcessForWO = new SVMXC__ServiceMax_Processes__c();
            objProcessForWO.SVMXC__Name__c = 'Map Hover For Work Order';
            objProcessForWO.RecordTypeId = strRuleRtypeId;
            objProcessForWO.SVMXC__Rule_Type__c = 'Column Info' ;
            objProcessForWO.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(objProcessForWO, COMM_SecurityUtils.Access.Createable)){
                insert objProcessForWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
            }
        }
        if(mapWOFields.size() > 0)
        {
            lstConfigData = SVMX_BuildConfigData('SVMXC__Service_Order__c',mapWOFields, objProcessForWO.id);
            if(lstConfigData.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigData, COMM_SecurityUtils.Access.Createable)){
                    insert lstConfigData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
        }   
    }
    public void SaveMapHoverForLocation()
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(objProcessForLocation != null && objProcessForLocation.id != null)
        {
            lstConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForLocation.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstConfigData.size() > 0)
                delete lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else
        {
            objProcessForLocation = new SVMXC__ServiceMax_Processes__c();
            objProcessForLocation.SVMXC__Name__c = 'Map Hover For Location';
            objProcessForLocation.RecordTypeId = strRuleRtypeId;
            objProcessForLocation.SVMXC__Rule_Type__c = 'Column Info' ;
            objProcessForLocation.SVMXC__Source_Object_Name__c = 'SVMXC__Site__c';
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(objProcessForLocation, COMM_SecurityUtils.Access.Createable)){
                insert objProcessForLocation; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
            }
        }
        if(mapLocFields.size() > 0)
        {
            lstConfigData = SVMX_BuildConfigData('SVMXC__Site__c',mapLocFields, objProcessForLocation.id);
            if(lstConfigData.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigData, COMM_SecurityUtils.Access.Createable)){
                    insert lstConfigData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
                }
            }
        }       
    }
    
    public void SaveMapHoverForAccount()
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(objProcessForAccount != null && objProcessForAccount.id != null)
        {
            lstConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForAccount.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstConfigData.size() > 0)
                delete lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else
        {
            objProcessForAccount = new SVMXC__ServiceMax_Processes__c();
            objProcessForAccount.SVMXC__Name__c = 'Map Hover For Account';
            objProcessForAccount.RecordTypeId = strRuleRtypeId;
            objProcessForAccount.SVMXC__Rule_Type__c = 'Column Info' ;
            objProcessForAccount.SVMXC__Source_Object_Name__c = 'Account';
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(objProcessForAccount, COMM_SecurityUtils.Access.Createable)){
                insert objProcessForAccount; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        if(mapAccFields.size() > 0)
        {
            lstConfigData = SVMX_BuildConfigData('Account',mapAccFields, objProcessForAccount.id);
            if(lstConfigData.size() > 0){
               if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigData, COMM_SecurityUtils.Access.Createable)){
                    insert lstConfigData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
                } 
            }
        }       
    }
    public void SaveMapHoverForTechnician()
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(objProcessForTech != null && objProcessForTech.id != null)
        {
            lstConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForTech.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstConfigData.size() > 0)
                delete lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else
        {
            objProcessForTech = new SVMXC__ServiceMax_Processes__c();
            objProcessForTech.SVMXC__Name__c = 'Map Hover For Technician';
            objProcessForTech.RecordTypeId = strRuleRtypeId;
            objProcessForTech.SVMXC__Rule_Type__c = 'Column Info' ;
            objProcessForTech.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group_Members__c';
            insert objProcessForTech; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        if(mapTechFields.size() > 0)
        {
            lstConfigData = SVMX_BuildConfigData('SVMXC__Service_Group_Members__c',mapTechFields, objProcessForTech.id);
            if(lstConfigData.size() > 0)
                insert lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }       
    }
    
    public void SaveMapHoverForTeam()
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(objProcessForTeam != null && objProcessForTeam.id != null)
        {
            lstConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c  = : objProcessForTeam.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstConfigData.size() > 0)
                delete lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else
        {
            objProcessForTeam = new SVMXC__ServiceMax_Processes__c();
            objProcessForTeam.SVMXC__Name__c = 'Map Hover For Team';
            objProcessForTeam.RecordTypeId = strRuleRtypeId;
            objProcessForTeam.SVMXC__Rule_Type__c = 'Column Info' ;
            objProcessForTeam.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group__c';
            insert objProcessForTeam; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        if(mapTeamFields.size() > 0)
        {
            lstConfigData = SVMX_BuildConfigData('SVMXC__Service_Group__c',mapTeamFields, objProcessForTeam.id);
          if(lstConfigData.size() > 0)
              insert lstConfigData; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }      
    }
   
    

    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    
    }
    
    
   //Validate WO Fields
     public Boolean SVMX_ValidateWO()
    {
        Boolean isValid = true;
        Integer i = 0;
        set<String> setWOFields = new set<String>();
        if(strWODisplayField1 != null && strWODisplayField1 != '--None--'){
            if(!setWOFields.contains(strWODisplayField1)){
                mapWOFields.put(1,strWODisplayField1);
                setWOFields.add(strWODisplayField1);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }




        if(strWODisplayField2 != null && strWODisplayField2 != '--None--'){
            if(!setWOFields.contains(strWODisplayField2)){
                mapWOFields.put(2,strWODisplayField2);
                setWOFields.add(strWODisplayField2);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }




        }
        if(strWODisplayField3 != null && strWODisplayField3 != '--None--'){
            if(!setWOFields.contains(strWODisplayField3)){
                mapWOFields.put(3,strWODisplayField3);
                setWOFields.add(strWODisplayField3);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }




        if(strWODisplayField4 != null && strWODisplayField4 != '--None--'){
            if(!setWOFields.contains(strWODisplayField4)){
                mapWOFields.put(4,strWODisplayField4);
                setWOFields.add(strWODisplayField4);
            }
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }




        if(strWODisplayField5 != null && strWODisplayField5 != '--None--'){
            if(!setWOFields.contains(strWODisplayField5)){
                mapWOFields.put(5,strWODisplayField5);
                setWOFields.add(strWODisplayField5);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }




        if(strWODisplayField6 != null && strWODisplayField6 != '--None--'){
            if(!setWOFields.contains(strWODisplayField6)){
                mapWOFields.put(6,strWODisplayField6);
                setWOFields.add(strWODisplayField6);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }




        if(strWODisplayField7 != null && strWODisplayField7 != '--None--'){
            if(!setWOFields.contains(strWODisplayField7)){
                mapWOFields.put(7,strWODisplayField7);
                setWOFields.add(strWODisplayField7);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }
        




        if(strWODisplayField8 != null && strWODisplayField8 != '--None--'){
            if(!setWOFields.contains(strWODisplayField8)){
                mapWOFields.put(8,strWODisplayField8);
                setWOFields.add(strWODisplayField8);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }
        




        if(strWODisplayField9 != null && strWODisplayField9 != '--None--'){
            if(!setWOFields.contains(strWODisplayField9)){
                mapWOFields.put(9,strWODisplayField9);
                setWOFields.add(strWODisplayField9);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }
        }




        if(strWODisplayField10 != null && strWODisplayField10 != '--None--') {
            if(!setWOFields.contains(strWODisplayField10)){
                mapWOFields.put(10,strWODisplayField10);
                setWOFields.add(strWODisplayField10);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
                return isValid;
            }










        }
        return isValid;
    }
    //Validate Location Fields
    public Boolean SVMX_ValidateLoc()
    {
        set<String> setLocFields = new set<String>();
        Integer i = 0;
        Boolean isValid = true;
        if(strLocDisplayField1 != null && strLocDisplayField1 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField1)){
                mapLocFields.put(1,strLocDisplayField1);
                setLocFields.add(strLocDisplayField1);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }




        if(strLocDisplayField2 != null && strLocDisplayField2 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField2)){
                mapLocFields.put(2,strLocDisplayField2);
                setLocFields.add(strLocDisplayField2);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }
      




        if(strLocDisplayField3 != null && strLocDisplayField3 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField3)){
                mapLocFields.put(3,strLocDisplayField3);
                setLocFields.add(strLocDisplayField3);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }
     




        if(strLocDisplayField4 != null && strLocDisplayField4 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField4)){
                mapLocFields.put(4,strLocDisplayField4);
                setLocFields.add(strLocDisplayField4);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }
        




        if(strLocDisplayField5 != null && strLocDisplayField5 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField5)){
                mapLocFields.put(5,strLocDisplayField5);
                setLocFields.add(strLocDisplayField5);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }
        




        if(strLocDisplayField6 != null && strLocDisplayField6 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField6)){
                mapLocFields.put(6,strLocDisplayField6);
                setLocFields.add(strLocDisplayField6);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }
        




        if(strLocDisplayField7 != null && strLocDisplayField7 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField7)){
                mapLocFields.put(7,strLocDisplayField7);
                setLocFields.add(strLocDisplayField7);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }




        }
        if(strLocDisplayField8 != null && strLocDisplayField8 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField8)){
                mapLocFields.put(8,strLocDisplayField8);
                setLocFields.add(strLocDisplayField8);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }
        




        if(strLocDisplayField9 != null && strLocDisplayField9 != '--None--'){
            if(!setLocFields.contains(strLocDisplayField9)){
                mapLocFields.put(9,strLocDisplayField9);
                setLocFields.add(strLocDisplayField9);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }     




        if(strLocDisplayField10 != null && strLocDisplayField10 != '--None--') {
            if(!setLocFields.contains(strLocDisplayField10)){
                mapLocFields.put(10,strLocDisplayField10);
                setLocFields.add(strLocDisplayField10);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG022,''));
                return isValid;
            }
        }     








        return isValid;
    }


    
    //Validate Account Fields
    public Boolean SVMX_ValidateAcc()
    {
        set<String> setAccFields = new set<String>();
        Boolean isValid = true;
        Integer i = 0;
        if(strAccDisplayField1 != null && strAccDisplayField1 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField1)){
                mapAccFields.put(1,strAccDisplayField1);
                setAccFields.add(strAccDisplayField1);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }
        }




        if(strAccDisplayField2 != null && strAccDisplayField2 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField2)){
                mapAccFields.put(2,strAccDisplayField2);
                setAccFields.add(strAccDisplayField2);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }
        }




        if(strAccDisplayField3 != null && strAccDisplayField3 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField3)){
                mapAccFields.put(3,strAccDisplayField3);
                setAccFields.add(strAccDisplayField3);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }




        }
        if(strAccDisplayField4 != null && strAccDisplayField4 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField4)){
                mapAccFields.put(4,strAccDisplayField4);
                setAccFields.add(strAccDisplayField4);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }




        }
        if(strAccDisplayField5 != null && strAccDisplayField5 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField5)){
                mapAccFields.put(5,strAccDisplayField5);
                setAccFields.add(strAccDisplayField5);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }
        }




        if(strAccDisplayField6 != null && strAccDisplayField6 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField6)){
                mapAccFields.put(6,strAccDisplayField6);
                setAccFields.add(strAccDisplayField6);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }
        }
        




        if(strAccDisplayField7 != null && strAccDisplayField7 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField7)){
                mapAccFields.put(7,strAccDisplayField7);
                setAccFields.add(strAccDisplayField7);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }




        }
        if(strAccDisplayField8 != null && strAccDisplayField8 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField8)){
                mapAccFields.put(8,strAccDisplayField8);
                setAccFields.add(strAccDisplayField8);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }
        }




        if(strAccDisplayField9 != null && strAccDisplayField9 != '--None--'){
            if(!setAccFields.contains(strAccDisplayField9)){
                mapAccFields.put(9,strAccDisplayField9);
                setAccFields.add(strAccDisplayField9);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }
        }




        if(strAccDisplayField10 != null && strAccDisplayField10 != '--None--') {
            if(!setAccFields.contains(strAccDisplayField10)){
                mapAccFields.put(10,strAccDisplayField10);
                setAccFields.add(strAccDisplayField10);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG023,''));
                return isValid;
            }










        }
        return isValid;
    }
    
    //Validate Technician Fields
    public Boolean SVMX_ValidateTech()
    {
        set<String> setTechFields = new set<String>();
        Boolean isValid = true;
        Integer i = 0;
        if(strTechDisplayField1 != null && strTechDisplayField1 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField1)){
                mapTechFields.put(1,strTechDisplayField1);
                setTechFields.add(strTechDisplayField1);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        } 




        if(strTechDisplayField2 != null && strTechDisplayField2 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField2)){
                mapTechFields.put(2,strTechDisplayField2);
                setTechFields.add(strTechDisplayField2);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }




        }
        if(strTechDisplayField3 != null && strTechDisplayField3 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField3)){
                mapTechFields.put(3,strTechDisplayField3);
                setTechFields.add(strTechDisplayField3);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }





        if(strTechDisplayField4 != null && strTechDisplayField4 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField4)){
                mapTechFields.put(4,strTechDisplayField4);
                setTechFields.add(strTechDisplayField4);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }
       




        if(strTechDisplayField5 != null && strTechDisplayField5 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField5)){
                mapTechFields.put(5,strTechDisplayField5);
                setTechFields.add(strTechDisplayField5);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }
        else if(strTechDisplayField5 == '--None--')
        {
          i++;
        }
        if(strTechDisplayField6 != null && strTechDisplayField6 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField6)){
                mapTechFields.put(6,strTechDisplayField6);
                setTechFields.add(strTechDisplayField6);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }




        if(strTechDisplayField7 != null && strTechDisplayField7 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField7)){
                mapTechFields.put(7,strTechDisplayField7);
                setTechFields.add(strTechDisplayField7);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }
        




        if(strTechDisplayField8 != null && strTechDisplayField8 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField8)){
                mapTechFields.put(8,strTechDisplayField8);
                setTechFields.add(strTechDisplayField8);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }
     




        if(strTechDisplayField9 != null && strTechDisplayField9 != '--None--'){
            if(!setTechFields.contains(strTechDisplayField9)){
                mapTechFields.put(9,strTechDisplayField9);
                setTechFields.add(strTechDisplayField9);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }
        




        if(strTechDisplayField10 != null && strTechDisplayField10 != '--None--') {
            if(!setTechFields.contains(strTechDisplayField10)){
                mapTechFields.put(10,strTechDisplayField10);
                setTechFields.add(strTechDisplayField10);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG025,''));
                return isValid;
            }
        }
        return isValid;
    }
    
    //Validate Team Fields
    
    public Boolean SVMX_ValidateTeam()

    {
        set<String> setTeamFields = new set<String>();
        Boolean isValid = true;
        Integer i = 0;
        if(strTeamDisplayField1 != null && strTeamDisplayField1 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField1)){
                mapTeamFields.put(1,strTeamDisplayField1);
                setTeamFields.add(strTeamDisplayField1);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField2 != null && strTeamDisplayField2 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField2)){
                mapTeamFields.put(2,strTeamDisplayField2);
                setTeamFields.add(strTeamDisplayField2);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField3 != null && strTeamDisplayField3 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField3)){
                mapTeamFields.put(3,strTeamDisplayField3);
                setTeamFields.add(strTeamDisplayField3);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField4 != null && strTeamDisplayField4 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField4)){
                mapTeamFields.put(4,strTeamDisplayField4);
                setTeamFields.add(strTeamDisplayField4);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField5 != null && strTeamDisplayField5 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField5)){
                mapTeamFields.put(5,strTeamDisplayField5);
                setTeamFields.add(strTeamDisplayField5);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField6 != null && strTeamDisplayField6 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField6)){
                mapTeamFields.put(6,strTeamDisplayField6);
                setTeamFields.add(strTeamDisplayField6);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField7 != null && strTeamDisplayField7 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField7)){
                mapTeamFields.put(7,strTeamDisplayField7);
                setTeamFields.add(strTeamDisplayField7);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField8 != null && strTeamDisplayField8 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField8)){
                mapTeamFields.put(8,strTeamDisplayField8);
                setTeamFields.add(strTeamDisplayField8);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField9 != null && strTeamDisplayField9 != '--None--'){
            if(!setTeamFields.contains(strTeamDisplayField9)){
                mapTeamFields.put(9,strTeamDisplayField9);
                setTeamFields.add(strTeamDisplayField9);
            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        if(strTeamDisplayField10 != null && strTeamDisplayField10 != '--None--') {
            if(!setTeamFields.contains(strTeamDisplayField10)){
                mapTeamFields.put(10,strTeamDisplayField10);
                setTeamFields.add(strTeamDisplayField10);

            }   
            else{
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.CONF037_TAG024,''));
                return isValid;
            }
        }
        
        return isValid;
    }
    public list<SVMXC__ServiceMax_Config_Data__c> SVMX_BuildConfigData(String strObjName,map<Integer,String> mapFieldName, String strProcessId)
    {
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        if(strObjName == 'SVMXC__Service_Order__c')
        {
            system.debug('mapFieldName'+mapFieldName);
            if(mapFieldName.size() > 0)
            {
                for(Integer i : mapFieldName.keyset())
                {
                    if(mapWOFldDesc.containskey(mapFieldName.get(i)))
                    {
                        SVMXC__ServiceMax_Config_Data__c objConfigData = new SVMXC__ServiceMax_Config_Data__c();
                        objConfigData.SVMXC__Expression_Rule__c = strProcessId;
                        objConfigData.SVMXC__Expression_Type__c = 'Column Field';
                        objConfigData.RecordTypeId = strExpressionRTypeId;
                        objConfigData.SVMXC__Sequence__c = i;
                        objConfigData.SVMXC__Field_Name__c = mapFieldName.get(i);
                        objConfigData.SVMXC__Display_Type__c = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getType().name().touppercase();
                        if(objConfigData.SVMXC__Display_Type__c.toupperCase() == 'REFERENCE')
                        {
                            objConfigData.SVMXC__Field_Relationship_Name__c = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getRelationshipName();//Object Name
                            //Schema.Sobjecttype sobj = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0];
                            map<String, Schema.SObjectField> mapfldDesc = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
                            if(mapfldDesc.size() > 0)
                            {
                                for(String str : mapfldDesc.keyset())
                                {
                                    if(mapfldDesc.get(str).getDescribe().isNameField())
                                    {
                                        objConfigData.SVMXC__FKey_Name_Field__c = mapfldDesc.get(str).getDescribe().getName();//object's Name field.
                                        break;
                                    }
                                }
                            }
                        }
                        lstConfigData.add(objConfigData);
                    }
                }   
            }   
        }
        else if(strObjName == 'SVMXC__Site__c')
        {
            if(mapFieldName.size() > 0)
            {
                for(Integer i : mapFieldName.keyset())
                {
                    if(mapLocFldDesc.containskey(mapFieldName.get(i)))
                    {
                        SVMXC__ServiceMax_Config_Data__c objConfigData = new SVMXC__ServiceMax_Config_Data__c();
                        objConfigData.SVMXC__Expression_Rule__c = strProcessId;
                        objConfigData.SVMXC__Expression_Type__c = 'Column Field';
                        objConfigData.RecordTypeId = strExpressionRTypeId;
                        objConfigData.SVMXC__Sequence__c = i;
                        objConfigData.SVMXC__Field_Name__c = mapFieldName.get(i);
                        objConfigData.SVMXC__Display_Type__c = mapLocFldDesc.get(mapFieldName.get(i)).getDescribe().getType().name().touppercase();
                        if(objConfigData.SVMXC__Display_Type__c.toupperCase() == 'REFERENCE')
                        {
                            objConfigData.SVMXC__Field_Relationship_Name__c = mapLocFldDesc.get(mapFieldName.get(i)).getDescribe().getRelationshipName();//Object Name
                            //Schema.Sobjecttype sobj = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0];
                            map<String, Schema.SObjectField> mapfldDesc = mapLocFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
                            if(mapfldDesc.size() > 0)
                            {
                                for(String str : mapfldDesc.keyset())
                                {
                                    if(mapfldDesc.get(str).getDescribe().isNameField())
                                    {
                                        objConfigData.SVMXC__FKey_Name_Field__c = mapfldDesc.get(str).getDescribe().getName();//object's Name field.
                                        break;
                                    }
                                }
                            }
                        }
                        lstConfigData.add(objConfigData);
                    }
                }   
            }
        }
        else if(strObjName == 'Account')
        {
            if(mapFieldName.size() > 0)
            {
                for(Integer i : mapFieldName.keyset())
                {
                    if(mapAccFldDesc.containskey(mapFieldName.get(i)))
                    {
                        SVMXC__ServiceMax_Config_Data__c objConfigData = new SVMXC__ServiceMax_Config_Data__c();
                        objConfigData.SVMXC__Expression_Rule__c = strProcessId;
                        objConfigData.SVMXC__Expression_Type__c = 'Column Field';
                        objConfigData.RecordTypeId = strExpressionRTypeId;
                        objConfigData.SVMXC__Sequence__c = i;
                        objConfigData.SVMXC__Field_Name__c = mapFieldName.get(i);
                        objConfigData.SVMXC__Display_Type__c = mapAccFldDesc.get(mapFieldName.get(i)).getDescribe().getType().name().touppercase();
                        if(objConfigData.SVMXC__Display_Type__c.toupperCase() == 'REFERENCE')
                        {
                            objConfigData.SVMXC__Field_Relationship_Name__c = mapAccFldDesc.get(mapFieldName.get(i)).getDescribe().getRelationshipName();//Object Name
                            //Schema.Sobjecttype sobj = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0];
                            map<String, Schema.SObjectField> mapfldDesc = mapAccFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
                            if(mapfldDesc.size() > 0)
                            {
                                for(String str : mapfldDesc.keyset())
                                {
                                    if(mapfldDesc.get(str).getDescribe().isNameField())
                                    {
                                        objConfigData.SVMXC__FKey_Name_Field__c = mapfldDesc.get(str).getDescribe().getName();//object's Name field.
                                        break;
                                    }
                                }
                            }
                        }
                        lstConfigData.add(objConfigData);
                    }
                }   
            }
        }
        else if(strObjName == 'SVMXC__Service_Group_Members__c')
        {
            if(mapFieldName.size() > 0)
            {
                for(Integer i : mapFieldName.keyset())
                {
                    if(mapTechFldDesc.containskey(mapFieldName.get(i)))
                    {
                        SVMXC__ServiceMax_Config_Data__c objConfigData = new SVMXC__ServiceMax_Config_Data__c();
                        objConfigData.SVMXC__Expression_Rule__c = strProcessId;
                        objConfigData.SVMXC__Expression_Type__c = 'Column Field';
                        objConfigData.RecordTypeId = strExpressionRTypeId;
                        objConfigData.SVMXC__Sequence__c = i;
                        objConfigData.SVMXC__Field_Name__c = mapFieldName.get(i);
                        objConfigData.SVMXC__Display_Type__c = mapTechFldDesc.get(mapFieldName.get(i)).getDescribe().getType().name().touppercase();
                        if(objConfigData.SVMXC__Display_Type__c.toupperCase() == 'REFERENCE')
                        {
                            objConfigData.SVMXC__Field_Relationship_Name__c = mapTechFldDesc.get(mapFieldName.get(i)).getDescribe().getRelationshipName();//Object Name
                            //Schema.Sobjecttype sobj = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0];
                            map<String, Schema.SObjectField> mapfldDesc = mapTechFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
                            if(mapfldDesc.size() > 0)
                            {
                                for(String str : mapfldDesc.keyset())
                                {
                                    if(mapfldDesc.get(str).getDescribe().isNameField())
                                    {
                                        objConfigData.SVMXC__FKey_Name_Field__c = mapfldDesc.get(str).getDescribe().getName();//object's Name field.
                                        break;
                                    }
                                }
                            }
                        }
                        lstConfigData.add(objConfigData);
                    }
                }   
            }
        }
         else if(strObjName == 'SVMXC__Service_Group__c')
        {
            if(mapFieldName.size() > 0)
            {
                for(Integer i : mapFieldName.keyset())
                {
                    if(mapTeamFldDesc.containskey(mapFieldName.get(i)))
                    {
                        SVMXC__ServiceMax_Config_Data__c objConfigData = new SVMXC__ServiceMax_Config_Data__c();
                        objConfigData.SVMXC__Expression_Rule__c = strProcessId;
                        objConfigData.SVMXC__Expression_Type__c = 'Column Field';
                        objConfigData.RecordTypeId = strExpressionRTypeId;
                        objConfigData.SVMXC__Sequence__c = i;
                        objConfigData.SVMXC__Field_Name__c = mapFieldName.get(i);
                        objConfigData.SVMXC__Display_Type__c = mapTeamFldDesc.get(mapFieldName.get(i)).getDescribe().getType().name().touppercase();
                        if(objConfigData.SVMXC__Display_Type__c.toupperCase() == 'REFERENCE')
                        {
                          objConfigData.SVMXC__Field_Relationship_Name__c = mapTeamFldDesc.get(mapFieldName.get(i)).getDescribe().getRelationshipName();//Object Name
                          //Schema.Sobjecttype sobj = mapWOFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0];
                          map<String, Schema.SObjectField> mapfldDesc = mapTeamFldDesc.get(mapFieldName.get(i)).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
                          if(mapfldDesc.size() > 0)
                          {
                            for(String str : mapfldDesc.keyset())
                            {
                              if(mapfldDesc.get(str).getDescribe().isNameField())
                              {
                                objConfigData.SVMXC__FKey_Name_Field__c = mapfldDesc.get(str).getDescribe().getName();//object's Name field.
                                break;
                              }
                            }
                          }
            }
                        lstConfigData.add(objConfigData);
                    }
                }   
            }
        }
        return lstConfigData;
    }
    public String getHLPURL() { return system.label.CONF037_HLPURL;}    

    public String getTAG001() { return system.label.CONF037_TAG001;}//'Configure Map Hover'
    public String getTAG002() { return system.label.CONF037_TAG002;}//'Choose Work Order fields to be displayed as map hover on Dispatch Console'
    public String getTAG003() { return system.label.CONF037_TAG003;}//'Map Hover Field 1'
    public String getTAG004() { return system.label.CONF037_TAG004;}//'Map Hover Field 2'
    public String getTAG005() { return system.label.CONF037_TAG005;}//'Map Hover Field 3'
    public String getTAG006() { return system.label.CONF037_TAG006;}//'Map Hover Field 4'
    public String getTAG007() { return system.label.CONF037_TAG007;}//'Map Hover Field 5'
    public String getTAG008() { return system.label.CONF037_TAG008;}//'Map Hover Field 6'
    public String getTAG009() { return system.label.CONF037_TAG009;}//'Map Hover Field 7'
    public String getTAG010() { return system.label.CONF037_TAG010;}//'Map Hover Field 8'
    public String getTAG011() { return system.label.CONF037_TAG011;}//'Map Hover Field 9'
    public String getTAG012() { return system.label.CONF037_TAG012;}//'Map Hover Field 10'
    public String getTAG013() { return system.label.COMM002_TAG005;}//'--None--'
    public String getTAG014() { return system.label.CONF037_TAG013;}//Choose Location fields to be displayed as map hover on Dispatch Console
    public String getTAG015() { return system.label.CONF037_TAG014;}//Choose Account fields to be displayed as map hover on Dispatch Console
    public String getTAG016() { return system.label.CONF037_TAG015;}//Choose Technician fields to be displayed as map hover on Dispatch Console
    public String getTAG017() { return system.label.CONF037_TAG021;}//'Please select a field only once for Work Order.
    public String getTAG018() { return system.label.COMM001_TAG041;}//'Processing...'
    public String getTAG019() { return system.label.CONF037_TAG016;}//'Configure Map Hover Help'
    public String getTAG020() { return system.label.CONF037_TAG026; }//'Choose fields for Team icon hover';
    public String getTAG021() { return system.label.CONF037_TAG022;}//'Select at least one field for Team hover';
}