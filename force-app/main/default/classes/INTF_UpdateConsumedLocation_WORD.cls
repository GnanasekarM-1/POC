public with sharing class INTF_UpdateConsumedLocation_WORD
{

    SVMXC.INTF_BuildSobjectFromKeyValue sobjectfromkevalue = new SVMXC.INTF_BuildSobjectFromKeyValue();
    
    //Constructor
    public INTF_UpdateConsumedLocation_WORD(){}
    
    public SVMXC.INTF_WebServicesDef.INTF_PageData setConsumedFrmLoc(SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec)
    {
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();    
        Map<String, String> mapSubModuleSettings = settings.SVMX_getSettingList('WORD005');
        String strSetngSetConsumeLoc = mapSubModuleSettings.get('SET014');
        set<String> setWorkDetailsID = new set<String>();
        list<SVMXC__Service_Order_Line__c> lstWorkDetail = new list<SVMXC__Service_Order_Line__c>();
        list<SVMXC__Service_Order_Line__c> lstWorkDetailtoUpsert = new list<SVMXC__Service_Order_Line__c>();
        list<string> lstWorkDetailsId = new list<string>();
        String strHeaderRecID;
            system.debug(LoggingLevel.WARN,'Inside Method started....');
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMapList = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
             List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            system.debug(LoggingLevel.WARN,'sfmtargetrec'+sfmtargetrec+'sfmtargetrec ID ');
             SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject  objWOHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject ();
            objWOHeaFromReq = sfmtargetrec.getheaderRecord();
            List<SVMXC.INTF_WebServicesDef.INTF_Record> objWOheaderrec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
            
            objWOheaderrec = objWOHeaFromReq.getrecords();
            if(objWOheaderrec != null && objWOheaderrec.size() > 0)
            lstHeaAsKeyValue = objWOheaderrec[0].targetRecordAsKeyValue;
            for(SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap : lstHeaAsKeyValue)
            {
                SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
                if(tempStrMap.key == 'id')
                {
                   strHeaderRecID = tempStrMap.value;
                }
               
            }
             system.debug(LoggingLevel.WARN,' strHeaderRecID'+ strHeaderRecID);
           /* for(Integer j = 0 ;j<sfmtargetrec.size();j++)
                    {
                        if(sfmtargetrec[j].key != null && sfmtargetrec[j].key.length() > 0 && sfmtargetrec[j].key == 'Id')
                        {
                        
                         system.debug(LoggingLevel.WARN,'sfmtargetrec ID '+sfmtargetrec[j].value);
                        }
                        
                    }   */
                        
            List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
            
            if(sfmtargetrec.detailRecords != null)   
                DtlTargetRecordObject = sfmtargetrec.detailRecords;
            String DetailObjName = '';
            List<SVMXC.INTF_WebServicesDef.INTF_Record> DetailRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
            system.debug(LoggingLevel.WARN,'DtlTargetRecordObject'+DtlTargetRecordObject);       
            if(DtlTargetRecordObject[0].objName != null)
                DetailObjName = DtlTargetRecordObject[0].objName;  
            
            if(DtlTargetRecordObject[0].records !=null)
                DetailRecord=DtlTargetRecordObject[0].records;
                

            system.debug(LoggingLevel.WARN,'DetailObjName '+DetailObjName);
            system.debug(LoggingLevel.WARN,'DetailRecord size '+DetailRecord.size());
             system.debug(LoggingLevel.WARN,'DetailRecord val '+DetailRecord);
            system.debug(LoggingLevel.WARN,'DetailRecord val '+DetailRecord);
        
            map<String,Sobject> DetailSobjMap = new map<String,Sobject>();
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> DtlTargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            
            
            List<SVMXC__Service_Group_Members__c> Technician = new List<SVMXC__Service_Group_Members__c>();
            String SOQLDetailx='Select s.SVMXC__Salesforce_User__c, s.SVMXC__Inventory_Location__c From SVMXC__Service_Group_Members__c s where s.SVMXC__Inventory_Location__c != null and s.SVMXC__Salesforce_User__c=\''+UserInfo.getUserId()+'\' Limit 1';
            Technician= Database.query(SOQLDetailx); 
            String strConsumedFrmLoc='';
            if (Technician.size() >0) 
            {
                strConsumedFrmLoc=Technician[0].SVMXC__Inventory_Location__c;
            }

            for(integer i=0;i<DetailRecord.size();i++)
            {
                
                if(DetailRecord.size() > 0)
                {
                    if(DetailRecord[i].targetRecordAsKeyValue != null && DetailRecord[i].targetRecordAsKeyValue.size() > 0 && DetailObjName != null && DetailObjName.length() > 0)
                    {
                        DtlTargetRecordAsKeyValue = DetailRecord[i].targetRecordAsKeyValue;
                        DetailSobjMap = sobjectfromkevalue.BuildSobjectFromKeyValue(DetailRecord[i].targetRecordAsKeyValue,DetailObjName,null,null);
                        if(DtlTargetRecordAsKeyValue[i].key == 'ID')
                         system.debug(LoggingLevel.WARN,'DetailRecord ID vAl '+i+'       '+DtlTargetRecordAsKeyValue[i].key);
                    }
                }
                    
                
                    
                    
                
                //update key/value for the Header object
                list<SVMXC.INTF_WebServicesDef.INTF_StringMap> TargetRecordAsKeyValue = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                if(DtlTargetRecordAsKeyValue.size() > 0 )
                {
                    for(Integer j = 0 ;j<DtlTargetRecordAsKeyValue.size();j++)
                    {
                        if(DtlTargetRecordAsKeyValue[j].key != null && DtlTargetRecordAsKeyValue[j].key.length() > 0 && DtlTargetRecordAsKeyValue[j].key == 'Id')
                        {
                            
                            lstWorkDetailsId.add(DtlTargetRecordAsKeyValue[j].value);
                        }   
                    }
                }
                
                
                
             
        } 
        system.debug(LoggingLevel.WARN,'lstWorkDetailsId'+lstWorkDetailsId+'Size:'+lstWorkDetailsId.size());
        
        //lstWorkDetailsId.addall(setWorkDetailsID);
        lstWorkDetail = [Select SVMXC__Consumed_From_Location__c, ID from SVMXC__Service_Order_Line__c where id in :lstWorkDetailsId and SVMXC__Consumed_From_Location__c = null];
        System.debug('lstWorkDetail'+lstWorkDetail+'Size:'+lstWorkDetail.size());
        for(SVMXC__Service_Order_Line__c WorkDet : lstWorkDetail)
        {
            if(strConsumedFrmLoc != null && strConsumedFrmLoc != '')
            {
                WorkDet.SVMXC__Consumed_From_Location__c = strConsumedFrmLoc;
                lstWorkDetailtoUpsert.add(WorkDet);
            }
        }
        system.debug(LoggingLevel.WARN,'lstWorkDetail'+lstWorkDetail+'Size:'+lstWorkDetail.size());
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWorkDetailtoUpsert , COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            upsert lstWorkDetailtoUpsert;
        }
        SVMXC.INTF_WebServicesDef.INTF_PageData PageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        PageData = buildpagedata.INTF_buildPageData(sfmtargetrec);
        PageData.response.success = true;
        system.debug(LoggingLevel.WARN,'PageData'+PageData);
        return PageData;
    }
}