public with sharing class INTF_PORDAddress  
{
    SVMXC.INTF_getAddress address = new SVMXC.INTF_getAddress();
    SVMXC.INTF_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.INTF_BuildSobjectFromKeyValue();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public INTF_PORDAddress  ()
    {
        
    }
    //Method for Select From Address & Source is WorkOrder
    public SVMXC.INTF_WebServicesDef.INTF_PageData getSelFromAddressWO(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
         system.debug('HdrTargetRecordAsKeyValue'+HdrTargetRecordAsKeyValue);
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        if(HdrSObject != null && HdrSObject.get('SVMXC__Service_Order__c') != null)
        {
            HdrSObject.put('SVMXC__Source_Location__c',null);
            String RecId = String.valueof(HdrSObject.get('SVMXC__Service_Order__c'));
            if(RecId != null && RecId.length() > 0)
            {
                SVMXC__Service_Order__c WO = [Select id,SVMXC__Component__c from SVMXC__Service_Order__c Where id =: RecId];
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap1.key= 'IBID';
                strmap1.value = WO.SVMXC__Component__c;
                StringMapList.add(strmap1);
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap.key= 'ADDRESSTYPE';
                strmap.value = 'FROMADDRESS';
                StringMapList.add(strmap);
                HdrSObject = address.getAddress(HdrSObject,StringMapList);
            }           
        }
        system.debug('HdrSObject'+HdrSObject);
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0)//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    if(HdrTargetRecordAsKeyValue[i].key == 'SVMXC__Source_Location__c')
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        String Rid = String.valueof(HdrSObject.get('SVMXC__Source_Location__c'));
                        if(Rid != null && Rid.length() > 0)
                        {
                            SVMXC__Site__c Location = [select id,Name from SVMXC__Site__c where id =: Rid];
                            if(Location != null)    
                                temp.value1 = Location.Name;
                        }       
                        TargetRecordAsKeyValue.add(temp);
                    }
                    else
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        if(HdrTargetRecordAsKeyValue[i].value1 != null)
                            temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                        TargetRecordAsKeyValue.add(temp);
                    }    
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        system.debug('TargetRecordAsKeyValue'+TargetRecordAsKeyValue);
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    //Method for Select To Address & Source is WorkOrder
    public SVMXC.INTF_WebServicesDef.INTF_PageData getSelToAddressWO(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        if(HdrSObject != null && HdrSObject.get('SVMXC__Service_Order__c') != null)
        {
            HdrSObject.put('SVMXC__Destination_Location__c',null);
            String RecId = String.valueof(HdrSObject.get('SVMXC__Service_Order__c'));
            if(RecId != null && RecId.length() > 0)
            {
                SVMXC__Service_Order__c WO = [Select id,SVMXC__Component__c from SVMXC__Service_Order__c Where id =: RecId];
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap1.key= 'IBID';
                strmap1.value = WO.SVMXC__Component__c;
                StringMapList.add(strmap1);
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap.key= 'ADDRESSTYPE';
                strmap.value = 'TOADDRESS';
                StringMapList.add(strmap);
                HdrSObject = address.getAddress(HdrSObject,StringMapList);
            }           
        }
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    if(HdrTargetRecordAsKeyValue[i].key == 'SVMXC__Destination_Location__c')
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        String Rid = String.valueof(HdrSObject.get('SVMXC__Destination_Location__c'));
                        if(Rid != null && Rid.length() > 0)
                        {
                            SVMXC__Site__c Location = [select id,Name from SVMXC__Site__c where id =: Rid];
                            if(Location != null)    
                                temp.value1 = Location.Name;
                        }       
                        TargetRecordAsKeyValue.add(temp);
                    }
                    else
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        if(HdrTargetRecordAsKeyValue[i].value1 != null)
                            temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                        TargetRecordAsKeyValue.add(temp);
                    }    
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    //Method for Select From Address & Source is Case
    public SVMXC.INTF_WebServicesDef.INTF_PageData getSelFromAddressCase(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        system.debug('HeaderObjName'+HeaderObjName);    
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        system.debug('HeaderRecord'+HeaderRecord);    
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                system.debug('Enter111');
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        system.debug('HeaderSobjMap'+HeaderSobjMap);
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        system.debug('HdrSObject'+HdrSObject);
        if(HdrSObject != null && HdrSObject.get('SVMXC__Case__c') != null)
        {
            HdrSObject.put('SVMXC__Source_Location__c',null);
            String RecId = String.valueof(HdrSObject.get('SVMXC__Case__c'));
            system.debug('RecId'+RecId);
            if(RecId != null && RecId.length() > 0)
            {
                Case caseobj = [Select id,SVMXC__Component__c from Case Where id =: RecId];
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap1.key= 'IBID';
                strmap1.value = caseobj.SVMXC__Component__c;
                StringMapList.add(strmap1);
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap.key= 'ADDRESSTYPE';
                strmap.value = 'FROMADDRESS';
                StringMapList.add(strmap);
                HdrSObject = address.getAddress(HdrSObject,StringMapList);
            }           
        }
        system.debug('HdrSObject'+HdrSObject);
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    if(HdrTargetRecordAsKeyValue[i].key == 'SVMXC__Source_Location__c')
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        String Rid = String.valueof(HdrSObject.get('SVMXC__Source_Location__c'));
                        if(Rid != null && Rid.length() > 0)
                        {
                            SVMXC__Site__c Location = [select id,Name from SVMXC__Site__c where id =: Rid];
                            if(Location != null)    
                                temp.value1 = Location.Name;
                        }       
                        TargetRecordAsKeyValue.add(temp);
                    }
                    else
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        if(HdrTargetRecordAsKeyValue[i].value1 != null)
                            temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                        TargetRecordAsKeyValue.add(temp);
                    }    
                }   
            }
        }
        system.debug('TargetRecordAsKeyValue'+TargetRecordAsKeyValue);
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    //Method for Select To Address & Source is Case
    public SVMXC.INTF_WebServicesDef.INTF_PageData getSelToAddressCase(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        system.debug('HeaderObjName'+HeaderObjName);    
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        system.debug('HeaderRecord'+HeaderRecord);
        system.debug('HeaderRecord[0].targetRecordAsKeyValue'+HeaderRecord[0].targetRecordAsKeyValue);
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            system.debug('Entered...');
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        system.debug('HeaderSobjMap'+HeaderSobjMap); 
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        system.debug('HdrSObject'+HdrSObject);
        if(HdrSObject != null && HdrSObject.get('SVMXC__Case__c') != null)
        {
            HdrSObject.put('SVMXC__Destination_Location__c',null);
            String RecId = String.valueof(HdrSObject.get('SVMXC__Case__c'));
            if(RecId != null && RecId.length() > 0)
            {
                Case caseobj = [Select id,SVMXC__Component__c from Case Where id =: RecId];
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap1.key= 'IBID';
                strmap1.value = caseobj.SVMXC__Component__c;
                StringMapList.add(strmap1);
                SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                strmap.key= 'ADDRESSTYPE';
                strmap.value = 'TOADDRESS';
                StringMapList.add(strmap);
                HdrSObject = address.getAddress(HdrSObject,StringMapList);
            }           
        }
        system.debug('HdrSObject'+HdrSObject);
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    if(HdrTargetRecordAsKeyValue[i].key == 'SVMXC__Destination_Location__c')
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        String Rid = String.valueof(HdrSObject.get('SVMXC__Destination_Location__c'));
                        if(Rid != null && Rid.length() > 0)
                        {
                            SVMXC__Site__c Location = [select id,Name from SVMXC__Site__c where id =: Rid];
                            if(Location != null)    
                                temp.value1 = Location.Name;
                        }       
                        TargetRecordAsKeyValue.add(temp);
                    }
                    else
                    {
                        SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                        temp.key = HdrTargetRecordAsKeyValue[i].key;
                        temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                        if(HdrTargetRecordAsKeyValue[i].value1 != null)
                            temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                        TargetRecordAsKeyValue.add(temp);
                    }    
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    //Method to ppopulate TOLOCATION(SVMXC__Destination_Location__c)
    public SVMXC.INTF_WebServicesDef.INTF_PageData getPopulateToLocation(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        if(HdrSObject != null)
        {
            HdrSObject.put('SVMXC__Address_Type__c',null);//Null the Address Type Field
            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
            strmap.key= 'ADDRESSTYPE';
            strmap.value = 'TOLOCATION';
            StringMapList.add(strmap);
            HdrSObject = address.getAddress(HdrSObject,StringMapList);
        }
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    temp.key = HdrTargetRecordAsKeyValue[i].key;
                    temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                    if(HdrTargetRecordAsKeyValue[i].value1 != null)
                        temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                    TargetRecordAsKeyValue.add(temp);
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        system.debug('sfmtargetrec'+sfmtargetrec);
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    //Method for Populate FROMLOCATION(SVMXC__Source_Location__c)
    public SVMXC.INTF_WebServicesDef.INTF_PageData getPopulateFromLocation(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        if(HdrSObject != null)
        {
            HdrSObject.put('SVMXC__Address_Type__c',null);//Null the Address Type Field
            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
            strmap.key= 'ADDRESSTYPE';
            strmap.value = 'FROMLOCATION';
            StringMapList.add(strmap);
            HdrSObject = address.getAddress(HdrSObject,StringMapList);
        }
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    temp.key = HdrTargetRecordAsKeyValue[i].key;
                    temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                    if(HdrTargetRecordAsKeyValue[i].value1 != null)
                        temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                    TargetRecordAsKeyValue.add(temp);
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    //Method to ppopulate TOLOCATION for RMA(SVMXC__Destination_Location__c)
    public SVMXC.INTF_WebServicesDef.INTF_PageData getPopulateToLocation_RMA(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        if(HdrSObject != null)
        {
            //HdrSObject.put('SVMXC__Address_Type__c',null);//Null the Address Type Field
            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
            strmap.key= 'ADDRESSTYPE';
            strmap.value = 'TOLOCATION';
            StringMapList.add(strmap);
            HdrSObject = address.getAddress(HdrSObject,StringMapList);
        }
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    temp.key = HdrTargetRecordAsKeyValue[i].key;
                    temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                    if(HdrTargetRecordAsKeyValue[i].value1 != null)
                        temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                    TargetRecordAsKeyValue.add(temp);
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        system.debug('sfmtargetrec'+sfmtargetrec);
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
    
   //Method for Populate FROMLOCATION for Shipment(SVMXC__Source_Location__c)
    public SVMXC.INTF_WebServicesDef.INTF_PageData getPopulateFromLocation_Shipment(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        system.debug('sfmtargetrec'+sfmtargetrec);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject HdrTargetRecordObject = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();//Second member of the INTF_TargetRecord Class
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();//Third member of the INTF_TargetRecord Class
        if(sfmtargetrec.headerRecord != null)
            HdrTargetRecordObject = sfmtargetrec.headerRecord;
        if(sfmtargetrec.detailRecords != null)   
            DtlTargetRecordObject = sfmtargetrec.detailRecords;
        String HeaderObjName = '';
        List<SVMXC.INTF_WebServicesDef.INTF_Record> HeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        Sobject HdrSObject;
        //Get the Header SFM Records...
        if(HdrTargetRecordObject.objName != null)
            HeaderObjName = HdrTargetRecordObject.objName;  
        if(HdrTargetRecordObject.records.size() > 0)
            HeaderRecord = HdrTargetRecordObject.records;
        map<String,Sobject> HeaderSobjMap = new map<String,Sobject>();
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> HdrTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HeaderRecord.size() > 0)
        {
            if(HeaderRecord[0].targetRecordAsKeyValue != null && HeaderRecord[0].targetRecordAsKeyValue.size() > 0 && HeaderObjName != null && HeaderObjName.length() > 0)
            {
                HdrTargetRecordAsKeyValue = HeaderRecord[0].targetRecordAsKeyValue;
                HeaderSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(HeaderRecord[0].targetRecordAsKeyValue,HeaderObjName,null,null);        
            }
        }
        if(HeaderSobjMap.size() > 0)
        {
            HdrSObject = HeaderSobjMap.values();
        }
        if(HdrSObject != null)
        {
//            HdrSObject.put('SVMXC__Address_Type__c',null);//Null the Address Type Field
            SVMXC.INTF_WebServicesDef.INTF_StringMap strmap = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
            strmap.key= 'ADDRESSTYPE';
            strmap.value = 'FROMLOCATION';
            StringMapList.add(strmap);
            HdrSObject = address.getAddress(HdrSObject,StringMapList);
        }
        //Create update key/value for the Header object
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(HdrTargetRecordAsKeyValue.size() > 0 && HdrSObject != null)
        {
            for(Integer i = 0 ;i<HdrTargetRecordAsKeyValue.size();i++)
            {
                if(HdrTargetRecordAsKeyValue[i].key != null && HdrTargetRecordAsKeyValue[i].key.length() > 0 )//&& HdrTargetRecordAsKeyValue[i].value != null && HdrTargetRecordAsKeyValue[i].value.length() > 0
                {
                    SVMXC.INTF_WebServicesDef.INTF_StringMap temp = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    temp.key = HdrTargetRecordAsKeyValue[i].key;
                    temp.value = String.valueof(HdrSObject.get(HdrTargetRecordAsKeyValue[i].key));
                    if(HdrTargetRecordAsKeyValue[i].value1 != null)
                        temp.value1 = HdrTargetRecordAsKeyValue[i].value1;
                    TargetRecordAsKeyValue.add(temp);
                }   
            }
        }
        HeaderRecord[0].targetRecordAsKeyValue = null;
        HeaderRecord[0].targetRecordAsKeyValue = TargetRecordAsKeyValue;
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug('PageData'+PageData);
        return PageData;
    }
}