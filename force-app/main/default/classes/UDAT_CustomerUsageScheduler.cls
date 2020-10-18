global with sharing class UDAT_CustomerUsageScheduler implements Schedulable
{
    /*
    Private String emailid;
    Private Datetime lastrundate;
    Private Datetime hrRunDate;
    Private Datetime runDtaTime;
    Private Integer DaysSendMail;*/
    
    global void execute(SchedulableContext SC)
    {
		/*
        DaysSendMail = 7;
        Map<String, String> svmxSettingList = new Map<String,String>();//commSettings.SVMX_getSettingList('UDAT001');
        Map<String, String> saveRcrdCunts = new Map<String, String>();
        Map<String, Integer> RcrdCunts = new Map<String, Integer>();
        List<SVMXC__ServiceMax_List__c> lstSvmxlst = new List<SVMXC__ServiceMax_List__c>();
    
        
        try
        {
            CronTrigger ctFrForwardShipmentEngine = null;
            ctFrForwardShipmentEngine = [SELECT Id, CronExpression, NextFireTime From CronTrigger WHERE Id = :SC.getTriggerId()];
            hrRunDate = ctFrForwardShipmentEngine.NextFireTime.addHours(-2);
            runDtaTime = ctFrForwardShipmentEngine.NextFireTime.addHours(-1);
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
        }
        
        svmxSettingList = getSetting();
        calculateHRD(svmxSettingList);
        lstSvmxlst = getRcrdCounts();
        RcrdCunts = countObjects(svmxSettingList);
        addNSaveCounts(RcrdCunts, lstSvmxlst, svmxSettingList);
        
        svmxSettingList.clear();
        saveRcrdCunts.clear();
        RcrdCunts.clear();
        lstSvmxlst.clear();
        */
    }
    /*
    // method getStart call from execute method and here we hardcode all the setting USET if it is not comming from seed then we use these hardcoded setting
    public Map<String, String>  getSetting()
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = new Map<String, String>();
        Map<String, String> svmxSettingListTmp = new Map<String, String>();
        try
        {   
            emailid = 'udat_customerusagetracking@75ak5s9fhzkp97j6oahdwbcai.8m5jgea0.8.apex.salesforce.com';
            svmxSettingList.put('SET001','udat_customerusagetracking@75ak5s9fhzkp97j6oahdwbcai.8m5jgea0.8.apex.salesforce.com');
            svmxSettingList.put('SET002','NA');
            svmxSettingList.put('SET004','7');
            svmxSettingList.put('USET001','SVMXC__Service_Order__c,SVMXC__Order_Type__c,,Y');
            svmxSettingList.put('USET002','SVMXC__Service_Order__c,SVMXC__Order_Type__c,SVMXC__Closed_On__c < LAST_N_DAYS:7,N,SVMXC__Closed_On__c');//
            svmxSettingList.put('USET003','Account,,,Y');
            svmxSettingList.put('USET004','SVMXC__Installed_Product__c,,,Y');
            svmxSettingList.put('USET005','SVMXC__Service_Order_Line__c,,,Y');
            svmxSettingListTmp = commSettings.SVMX_getSettingList('UDAT001');
            if (svmxSettingListTmp != null && svmxSettingListTmp.size() >0)
            {
                svmxSettingList.clear();
                svmxSettingList.putall(svmxSettingListTmp);
            }
            
            if(svmxSettingList.containsKey('SET001') && svmxSettingList.get('SET001').length() > 0)
                emailid = svmxSettingList.get('SET001');
                
            if(svmxSettingList.containsKey('SET004') && svmxSettingList.get('SET004').length() > 0)
                DaysSendMail = Integer.valueOf(svmxSettingList.get('SET004'));
             
       }catch(Exception ex)
       {
           sendException(ex.getMessage());
       }
       return svmxSettingList;
    }

    public void calculateHRD(Map<String, String> svmxSettingList)
    {
        try
        {
            lastrundate = hrRunDate;
            if(svmxSettingList.containsKey('SET002'))
            {
                if( svmxSettingList.get('SET002') == Null || svmxSettingList.get('SET002').length() < 1 || svmxSettingList.get('SET002') == 'NA') 
                {
                    updateLRD(hrRunDate);
                }
                else if( svmxSettingList.get('SET002') != Null && svmxSettingList.get('SET002').length() > 0 && svmxSettingList.get('SET002') != 'NA' ) 
                {
                    lastrundate = Datetime.valueOf(svmxSettingList.get('SET002'));
                }
            }
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
        }
    }

    public void updateLRD(Datetime dtime)
    {
        try
        {
          List<SVMXC__ServiceMax_Config_Data__c> lstUdatLrdSettingVal = new List<SVMXC__ServiceMax_Config_Data__c>();
          lstUdatLrdSettingVal = [SELECT Id, SVMXC__SETTING_CONFIGURATION_PROFILE__C, SVMXC__SETTING_ID__C, SVMXC__INTERNAL_VALUE__C, SVMXC__DISPLAY_VALUE__C, SVMXC__ACTIVE__C, SVMXC__ISDEFAULT__C, SVMXC__Setting_Unique_ID__c , SVMXC__Setting_ID__r.SVMXC__Setting_Unique_ID__c FROM SVMXC__SERVICEMAX_CONFIG_DATA__C WHERE RecordType.Name = 'Setting Value' and SVMXC__Setting_Unique_ID__c ='UDAT001_SET002'];
             for (SVMXC__ServiceMax_Config_Data__c objCnfgDta : lstUdatLrdSettingVal) 
             {
                objCnfgDta.SVMXC__INTERNAL_VALUE__C = String.valueOf(dtime);
                objCnfgDta.SVMXC__DISPLAY_VALUE__C = String.valueOf(dtime);
             }
        
            Update lstUdatLrdSettingVal;
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
        }
    }
    

    public List<SVMXC__ServiceMax_List__c> getRcrdCounts()
    {
        List<SVMXC__ServiceMax_List__c> lstSvmxlst = new List<SVMXC__ServiceMax_List__c>(); 
        try
        {
            lstSvmxlst = [select Id, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_List__c where SVMXC__Activity_Type__c = 'Usage Data'];   
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
        }
        return lstSvmxlst;
    }
    
    
    public Map<String, Integer> countObjects(Map<String, String> svmxSettingList)
    {
        Map<String, Integer> RcrdCunts = new Map<String, Integer>();
        try
        {
            for(String strKey : svmxSettingList.keySet())
            {
                if(strKey.contains('USET'))
                {
                    String wrtQury;
                    String getFieldNm = ''; 
                    String settingValue = svmxSettingList.get(strKey);
                    List<String> lstsettng = settingValue.split(',');
                    String ObjNam = lstsettng[0];
                    String fieldNam = lstsettng[1]; 
                    String wherClaus = lstsettng[2];
                    String CheckUseWhre = lstsettng[3];
                    if(lstsettng.size() == 5)
                        getFieldNm = lstsettng[4];
                    ObjNam = ObjNam.trim();
                    fieldNam = fieldNam.trim();
                    CheckUseWhre = CheckUseWhre.trim();
                    ObjNam = ObjNam.trim();
                    getFieldNm = getFieldNm.trim();
                    String hedrQry1 = 'select Count(Id) ';
                    String hedrQry2 = '';
                    String hedrQry3 = '';//'where CreatedDate >: lastrundate';
                    String hedrQry5 = '';

                    if(ObjNam.length() > 0 )
                    {
                        if(fieldNam.length() >0 )
                        {
                            hedrQry2 = ', '+fieldNam+' from '+ObjNam+' ';
                            hedrQry5 = ' group by '+fieldNam ;
                        }
                        else
                        {
                            hedrQry2 = ' from '+ObjNam+' ';
                            hedrQry5 = '';
                        }
                    }
                    
                    if(CheckUseWhre == 'Y')
                    {
                        hedrQry3 = 'where CreatedDate >: hrRunDate And CreatedDate <: runDtaTime';
                    }   
                    else if( CheckUseWhre == 'N' && getFieldNm.length() > 0)
                        hedrQry3 = ' where '+getFieldNm+' >: hrRunDate And '+getFieldNm+' <: runDtaTime';
                    else
                        hedrQry3 = 'where CreatedDate >: hrRunDate And CreatedDate <: runDtaTime';
                        
                    wrtQury = hedrQry1+hedrQry2+hedrQry3+hedrQry5;
                    
                    List<AggregateResult> agResultLst = new List<AggregateResult>();
                    agResultLst = Database.query(wrtQury);
                    if(agResultLst.size() != 0)
                    {
                        for(AggregateResult agResult : agResultLst)
                        {
                            if(fieldNam != null && fieldNam.length() > 0)
                            {
                                String key;
                                if( CheckUseWhre == 'N' && getFieldNm.length() > 0)
                                    key = ObjNam+'.'+agResult.get(fieldNam)+'.'+getFieldNm;
                                else
                                    key = ObjNam+'.'+agResult.get(fieldNam);
                                
                                RcrdCunts.put(key, Integer.valueOf(agResult.get('expr0')));
                            }
                            else
                            {
                                String key;
                                if( CheckUseWhre == 'N' && getFieldNm.length() > 0)
                                    key = ObjNam+'.'+getFieldNm;
                                else
                                    key = ObjNam;
                                
                                RcrdCunts.put(key, Integer.valueOf(agResult.get('expr0')));
                            }
                        }
                    }
                } 
            }
            return RcrdCunts;
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
            return RcrdCunts;
        }
    }
    
    public void addNSaveCounts(Map<String, Integer> RcrdCunts, List<SVMXC__ServiceMax_List__c> lstSvmxlst, Map<String, String> svmxSettingList)
    {
        try
        {
            Map<String, String> saveRcrdCunts = new Map<String, String>();
            for(SVMXC__ServiceMax_List__c objSvmxLst : lstSvmxlst)
            {
                saveRcrdCunts.put(objSvmxLst.SVMXC__Key__c , objSvmxLst.SVMXC__Value__c);
            }
            Map<String, String> tempMap = new Map<String, String>();
            List<SVMXC__ServiceMax_List__c> lstObjToSave = new List<SVMXC__ServiceMax_List__c>();
            for(String key : RcrdCunts.keySet())
            {
                if(saveRcrdCunts.containsKey(key))
                {
                    Integer sCunt = Integer.valueOf(saveRcrdCunts.get(key));
                    sCunt = sCunt + RcrdCunts.get(key);
                    tempMap.put(key, String.valueOf(sCunt));
                }
                else
                    tempMap.put(key, String.valueOf(RcrdCunts.get(key)));
            
            }
            saveRcrdCunts.putAll(tempMap);
            
            if(lstSvmxlst != null && lstSvmxlst.size() > 0)
                Delete lstSvmxlst;
            
            
            lastrundate = lastrundate + DaysSendMail ;
            
            if(lastrundate.date() == runDtaTime.date() && lastrundate.hour() <= runDtaTime.hour())
            {
                creatXMLNSendMail(svmxSettingList, saveRcrdCunts);
            }
            else
            {
                for(String key : saveRcrdCunts.keySet())
                {
                    SVMXC__ServiceMax_List__c objTmp = new SVMXC__ServiceMax_List__c();
                    objTmp.SVMXC__Key__c = key;
                    objTmp.SVMXC__Value__c = saveRcrdCunts.get(key);
                    objTmp.SVMXC__Activity_Type__c = 'Usage Data';
                    lstObjToSave.add(objTmp);
                }
                
                if(lstObjToSave != null && lstObjToSave.size() > 0)
                    Insert lstObjToSave;
            }
            
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
        }
    }
    
    public void creatXMLNSendMail(Map<String, String> svmxSettingList, Map<String, String> saveRcrdCunts)
    {
        try
        {
            updateLRD(runDtaTime);
        
            List<String> lstArgNm = new List<String>();
            for(String strKey : svmxSettingList.keySet())
            {
                if(strKey.contains('USET'))
                {
                    String getFieldNm = ''; 
                    String settingValue = svmxSettingList.get(strKey);
                    List<String> lstsettng = settingValue.split(',');
                    String ObjNam = lstsettng[0];
                    String fieldNam = lstsettng[1]; 
                    String wherClaus = lstsettng[2];
                    String CheckUseWhre = lstsettng[3];
                    if(lstsettng.size() == 5)
                        getFieldNm = lstsettng[4];
                    ObjNam = ObjNam.trim();
                    fieldNam = fieldNam.trim();
                    CheckUseWhre = CheckUseWhre.trim();
                    ObjNam = ObjNam.trim();
                    getFieldNm = getFieldNm.trim();
                    
                    if(ObjNam.length() > 0)
                    {
                        if(fieldNam.length() > 0)
                        {
                            SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
                            String objectName = ObjNam ;
                            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                            objectName = utils.getOriginalAPIName(objectName, allObjs);
                            Schema.SObjectType selectedObject = allObjs.get(objectName);
                            Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
                            Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
                            system.debug('fieldNam' + fieldNam);
                            for(Schema.SObjectField fieldMap: fieldMapping.values())
                            {
                                if(fieldMap.getDescribe().getName() == fieldNam)
                                {
                                    List<Schema.PicklistEntry> Pik = fieldMap.getDescribe().getPicklistValues();
                                    for(Schema.PicklistEntry ss : Pik)
                                    {
                                        if( CheckUseWhre == 'N' && getFieldNm.length() > 0)
                                            lstArgNm.add(ObjNam+'.'+ss.getValue()+'.'+getFieldNm);
                                        else
                                            lstArgNm.add(ObjNam+'.'+ss.getValue());
                                    }
                                }
                            }
                        }
                        else
                        {
                            if( CheckUseWhre == 'N' && getFieldNm.length() > 0)
                                lstArgNm.add(ObjNam+'.'+getFieldNm);
                            else
                                lstArgNm.add(ObjNam);
                        }
                    }
                }
            }
            
            for(String key : lstArgNm)
            {
                if(saveRcrdCunts.containsKey(key) == false)
                    saveRcrdCunts.put(key, '0');
            }
            
        
            XmlStreamWriter xmlStr = new XmlStreamWriter();
            xmlStr.writeStartDocument(null, '1.0');
            xmlStr.writeStartElement(null, 'UsageData', null);
            xmlStr.writeAttribute('','','OrgID',UserInfo.getOrganizationId());
            xmlStr.writeAttribute('','','RunDate',String.valueOf(runDtaTime));
            xmlStr.writeAttribute('','','RunType','Incremental');
            for(String key : saveRcrdCunts.keySet())
            {
                xmlStr.writeStartElement(null, 'Data', null);
                    xmlStr.writeStartElement(null, 'Key', null);
                    xmlStr.writeCharacters(key);
                    xmlStr.writeEndElement();
                    xmlStr.writeStartElement(null, 'Value', null);
                    xmlStr.writeCharacters(saveRcrdCunts.get(key));
                    xmlStr.writeEndElement();
                xmlStr.writeEndElement();
            }
            xmlStr.writeEndElement();
            xmlStr.writeEndDocument();
            String finalXmlString =  xmlStr.getXmlString();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {emailid, 'configure@servicemax.com'};//
            mail.setToAddresses(toAddresses);
            mail.setSubject('Usage Data');
            mail.setPlainTextBody(finalXmlString);
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex)
        {
            sendException(ex.getMessage());
        }
        
    }

    // method sendException is only for if any exception come in code the it send mail to configure@servicemax.com with that exception message
    public void sendException(String msg)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailid , 'configure@servicemax.com'};//
        mail.setToAddresses(toAddresses);
        mail.setSubject('Exception mail from UDAT');
        String mailBody = 'Error Message: ' + msg + ' \n';
        mail.setPlainTextBody(mailBody);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    */
}