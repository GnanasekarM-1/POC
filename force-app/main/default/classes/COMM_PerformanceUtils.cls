global with sharing class COMM_PerformanceUtils 
{
    //============= Global Variables for over all calculation of Start, End time and TimeStamp for the Process =======================
    global Datetime beginTime;
    global Datetime endTime;
    global integer totalTimeStamp = 0;
    global boolean isCreateLog = false;
    global string emailID = '';
    
    //============= Inner Class for calculation of start, End Time and TimeStamp for inner parts of the process =======================
    public class internalPerformance
    {
        public Datetime startTime;
        public Datetime stopTime;
        public integer timeStamp = 0;
        public integer count = 0;
        
        public internalPerformance()
        {}
    }
    
    global map<string, map<integer, internalPerformance>> mapIDToPerformance = new map<string, map<integer, internalPerformance>>();
    
    //============= Static Map to maintain the start, stop Time and TimeStamps through out the Process =======================
    public static map<string, map<integer, internalPerformance>> mapIDToPerformance2 = new map<string, map<integer, internalPerformance>>();
    
    public COMM_PerformanceUtils()
    {}
    
    //============= Method to be called from the initialisation of the process =======================
    public void begin()
    {
        //system.debug('Performance testing Started.');
        mapIDToPerformance2 = new map<string, map<integer, internalPerformance>>();
        beginTime = Datetime.now();
        map<integer, internalPerformance> tempMap = new map<integer, internalPerformance>();
        internalPerformance tempObjPerf = new internalPerformance();
        tempObjPerf.startTime = beginTime;
        tempMap.put(0, tempObjPerf);
        mapIDToPerformance2.put('ProcessBegin', tempMap);
        //system.debug('Begin at: ' + beginTime + ' map initialised as: ' + mapIDToPerformance2 + ' and size is: ' + mapIDToPerformance2.size());
    }
    
    //======================= Method to be called at the end of the process with Record Id ===============================
    public void end(string strRecordId, string strProcessName)
    {
        //system.debug('Performance testing end method starts here.');
        Map<String, String> svmxSettingList = new Map<String,String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
        
        if(mapIDToPerformance2.containsKey('ProcessBegin'))
        {
            endTime = Datetime.now();
            totalTimeStamp = integer.valueOf(endTime.getTime() - beginTime.getTime());
            
            mapIDToPerformance2.get('ProcessBegin').get(0).stopTime = endTime;
            mapIDToPerformance2.get('ProcessBegin').get(0).timeStamp = totalTimeStamp;
            //system.debug('map Created through out the process: ' + mapIDToPerformance2);
            string addStr = '';
            addStr = 'Process begin at: ' + string.valueOf(beginTime);
            addStr += '\nProcess end at: ' + string.valueOf(endTime);
            addStr += '\nTotal time ellapsed: ' + string.valueOf(totalTimeStamp);
            addStr += '\n\nMethod, No. of Calls, Count, Started ?, Start Time, Stop Time, Time Ellapsed';
            for(string str : mapIDToPerformance2.keyset())
            {
                if(str != 'ProcessBegin')
                {
                    addStr += '\n' + str;
                    addStr += ', ' + mapIDToPerformance2.get(str).size();
                    for(integer i : mapIDToPerformance2.get(str).keyset())
                    {
                        if(i > 0)
                            addStr += '\n,,' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                        else
                            addStr += ', ' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                        if(mapIDToPerformance2.get(str).get(i).startTime != null)
                            addStr += ', yes, ' + string.valueOf(mapIDToPerformance2.get(str).get(i).startTime);
                        else
                            addStr += ', No, ';
                        addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).stopTime);
                        addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).timeStamp);
                    }
                }
            }
            if(boolean.valueOf(svmxSettingList.containsKey('GBL019')))
                isCreateLog = boolean.valueOf(svmxSettingList.get('GBL019'));
            
            if(isCreateLog == true)
            {
                if(strRecordId != null && strRecordId.length() > 0)
                {
                    string strAttachName = 'Performance LOG for: ' + strProcessName;
                    
                    List<Attachment> lstAttachTodelete = new List<Attachment>();
                    lstAttachTodelete = [select id from Attachment where ParentId =: strRecordId AND Name =: strAttachName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstAttachTodelete != null && lstAttachTodelete.size() > 0){
						if(COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' )){
							delete lstAttachTodelete; //SDL-SVMX-DELETE-FLS-ENFORCED
						}
						else{
							throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
						}
					}
					
                    Attachment attach = new Attachment();
                    attach.ParentId = strRecordId;
                    attach.Name = strAttachName;
                    attach.ContentType = 'text/plain';
                    attach.Body = Blob.valueof(addStr);
					if(COMM_SecurityUtils.getInstance().verifyFieldAccess(attach, COMM_SecurityUtils.Access.Createable)){
						insert attach; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
						throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
					}
                    //system.debug('Attachment created is: ' + attach);
                }
                
                if(boolean.valueOf(svmxSettingList.containsKey('GBL015')))
                    emailID = string.valueOf(svmxSettingList.get('GBL015'));
                
                //system.debug('Email Id to which the mail is sent: ' + emailID);
                
                if(emailID != null && emailID.length()>0)
                {
                    string sub = 'Performance Log for record: ' + strRecordId;
                    Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
                    objMailShpMessage.setToAddresses(new String[] {emailID});
                    objMailShpMessage.setSenderDisplayName('ServiceMax');
                    objMailShpMessage.setSubject(sub);
                    objMailShpMessage.setBccSender(false);
                    objMailShpMessage.setUseSignature(false);
                    objMailShpMessage.setPlainTextBody(addStr);
                    if(!test.isRunningTest())
                    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });   
                }
            }
            
            mapIDToPerformance2.clear();
        }
        else
        {
            //system.debug('map Created through out the process without begin: ' + mapIDToPerformance2);
            beginTime = null;
            endTime = Datetime.now();
            string addStr = '';
            addStr = '\nProcess does not begin.';
            addStr += '\nProcess end at: ' + string.valueOf(endTime);
            addStr += '\n\nMethod, No. of Calls, Count, Started ?, Start Time, Stop Time, Time Ellapsed';
            for(string str : mapIDToPerformance2.keyset())
            {
                addStr += '\n' + str;
                addStr += ', ' + mapIDToPerformance2.get(str).size();
                for(integer i : mapIDToPerformance2.get(str).keyset())
                {
                    if(i > 0)
                        addStr += '\n,,' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                    else
                        addStr += ', ' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                    if(mapIDToPerformance2.get(str).get(i).startTime != null)
                        addStr += ', Yes, ' + string.valueOf(mapIDToPerformance2.get(str).get(i).startTime);
                    else
                        addStr += ', No, ';
                    addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).stopTime);
                    addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).timeStamp);
                }
            }
            //system.debug('Log for process, which does not begin but have end: ' + addStr);
            
            if(boolean.valueOf(svmxSettingList.containsKey('GBL019')))
                isCreateLog = boolean.valueOf(svmxSettingList.get('GBL019'));
            
            if(isCreateLog == true)
            {
                if(strRecordId != null && strRecordId.length() > 0)
                {
                    Attachment attach = new Attachment();
                    attach.ParentId = strRecordId;
                    attach.Name = 'Performance LOG';
                    attach.ContentType = 'csv';
                    attach.Body = Blob.valueof(addStr);
					if(COMM_SecurityUtils.getInstance().verifyFieldAccess(attach, COMM_SecurityUtils.Access.Createable)){
						insert attach; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					}
					else{
						throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
					}
                    //system.debug('Attachment created is: ' + attach);
                } 
                
                if(boolean.valueOf(svmxSettingList.containsKey('GBL015')))
                    emailID = string.valueOf(svmxSettingList.get('GBL015'));
                
                //system.debug('Email Id to which the mail is sent: ' + emailID);
                
                if(emailID != null && emailID.length()>0)
                {
                    string sub = 'Performance Log for record: ' + strRecordId;
                    Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
                    objMailShpMessage.setToAddresses(new String[] {emailID});
                    objMailShpMessage.setSenderDisplayName('ServiceMax');
                    objMailShpMessage.setSubject(sub);
                    objMailShpMessage.setBccSender(false);
                    objMailShpMessage.setUseSignature(false);
                    objMailShpMessage.setPlainTextBody(addStr);
                    if(!test.isRunningTest())
                    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });   
                }
            }
            
            mapIDToPerformance2.clear();
        }
    }
    
    //======================= Method to be called at the end of the process With Email Id ===============================
    public void end(string strRecordId, string strProcessName, string emailID)
    {
        Map<String, String> svmxSettingList = new Map<String,String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
        
        if(mapIDToPerformance2.containsKey('ProcessBegin'))
        {
            endTime = Datetime.now();
            totalTimeStamp = integer.valueOf(endTime.getTime() - beginTime.getTime());
            
            mapIDToPerformance2.get('ProcessBegin').get(0).stopTime = endTime;
            mapIDToPerformance2.get('ProcessBegin').get(0).timeStamp = totalTimeStamp;
            string addStr = '';
            addStr = 'Process begin at: ' + string.valueOf(beginTime);
            addStr += '\nProcess end at: ' + string.valueOf(endTime);
            addStr += '\nTotal time ellapsed: ' + string.valueOf(totalTimeStamp);
            addStr += '\n\nMethod, No. of Calls, Count, Started ?, Start Time, Stop Time, Time Ellapsed';
            for(string str : mapIDToPerformance2.keyset())
            {
                if(str != 'ProcessBegin')
                {
                    addStr += '\n' + str;
                    addStr += ', ' + mapIDToPerformance2.get(str).size();
                    for(integer i : mapIDToPerformance2.get(str).keyset())
                    {
                        if(i > 0)
                            addStr += '\n,,' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                        else
                            addStr += ', ' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                        if(mapIDToPerformance2.get(str).get(i).startTime != null)
                            addStr += ', yes, ' + string.valueOf(mapIDToPerformance2.get(str).get(i).startTime);
                        else
                            addStr += ', No, ';
                        addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).stopTime);
                        addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).timeStamp);
                    }
                }
            }
            
            if(boolean.valueOf(svmxSettingList.containsKey('GBL019')))
                isCreateLog = boolean.valueOf(svmxSettingList.get('GBL019'));
            
            if(boolean.valueOf(svmxSettingList.containsKey('GBL015')))
                    emailID = string.valueOf(svmxSettingList.get('GBL015'));
            
            if(isCreateLog == true && emailID != null && emailID.length() > 0)
            {
                system.debug('Email Id to which the mail is sent: ' + emailID);
                string sub = strProcessName;
                Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
                objMailShpMessage.setToAddresses(new String[] {emailID});
                objMailShpMessage.setSenderDisplayName('ServiceMax');
                objMailShpMessage.setSubject(sub);
                objMailShpMessage.setBccSender(false);
                objMailShpMessage.setUseSignature(false);
                objMailShpMessage.setPlainTextBody(addStr);
                if(!test.isRunningTest())
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });
            }
            mapIDToPerformance2.clear();
        }
        else
        {
            beginTime = null;
            endTime = Datetime.now();
            string addStr = '';
            addStr = '\nProcess does not begin.';
            addStr += '\nProcess end at: ' + string.valueOf(endTime);
            addStr += '\n\nMethod, No. of Calls, Count, Started ?, Start Time, Stop Time, Time Ellapsed';
            for(string str : mapIDToPerformance2.keyset())
            {
                addStr += '\n' + str;
                addStr += ', ' + mapIDToPerformance2.get(str).size();
                for(integer i : mapIDToPerformance2.get(str).keyset())
                {
                    if(i > 0)
                        addStr += '\n,,' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                    else
                        addStr += ', ' + string.valueOf((mapIDToPerformance2.get(str).get(i).count+1));
                    if(mapIDToPerformance2.get(str).get(i).startTime != null)
                        addStr += ', Yes, ' + string.valueOf(mapIDToPerformance2.get(str).get(i).startTime);
                    else
                        addStr += ', No, ';
                    addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).stopTime);
                    addStr += ', ' + string.valueOf(mapIDToPerformance2.get(str).get(i).timeStamp);
                }
            }
            
            if(boolean.valueOf(svmxSettingList.containsKey('GBL019')))
                isCreateLog = boolean.valueOf(svmxSettingList.get('GBL019'));
            
            if(boolean.valueOf(svmxSettingList.containsKey('GBL015')))
                    emailID = string.valueOf(svmxSettingList.get('GBL015'));
                
            if(isCreateLog == true && emailID != null && emailID.length() > 0)
            {
                system.debug('Email Id to which the mail is sent: ' + emailID);
                string sub = strProcessName;
                Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
                objMailShpMessage.setToAddresses(new String[] {emailID});
                objMailShpMessage.setSenderDisplayName('ServiceMax');
                objMailShpMessage.setSubject(sub);
                objMailShpMessage.setBccSender(false);
                objMailShpMessage.setUseSignature(false);
                objMailShpMessage.setPlainTextBody(addStr);
                if(!test.isRunningTest())
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });
            }
            
            mapIDToPerformance2.clear();
        }
    }
    
    //======================= Method to be called at the start of the internal calculation in the process ===============================
    public static void start(string methodID)
    {
        //system.debug('start for Method: ' + methodID + ' is already there: ' + mapIDToPerformance2.containsKey(methodID));
        if(mapIDToPerformance2.containsKey(methodID))
        {
            internalPerformance internalObj = new internalPerformance();
            internalObj.count = mapIDToPerformance2.get(methodID).size();
            internalObj.startTime = Datetime.now();
            mapIDToPerformance2.get(methodID).put(internalObj.count, internalObj);
        }
        else
        {
            internalPerformance internalObj = new internalPerformance();
            internalObj.count = 0;
            internalObj.startTime = Datetime.now();
            map<integer, internalPerformance> tempMap = new map<integer, internalPerformance>();
            tempMap.put(internalObj.count, internalObj);
            mapIDToPerformance2.put(methodID, tempMap);
        }
        //system.debug('Map after start of Method: ' + methodID + ' is: ' + mapIDToPerformance2 + ' and size is: ' + mapIDToPerformance2.size());
    }
    
    //======================= Method to be called at the stop of the internal calculation in the process ===============================
    public static void stop(string methodID)
    {
        //system.debug('stop for Method: ' + methodID + ' is already there: ' + mapIDToPerformance2.containsKey(methodID));
        if(mapIDToPerformance2.containsKey(methodID))
        {
            internalPerformance internalObj = new internalPerformance();
            if(mapIDToPerformance2.get(methodID).size() > 1)
            {
                for(integer inte = (mapIDToPerformance2.get(methodID).size()-1); inte >= 0; inte--)
                {
                    if(mapIDToPerformance2.get(methodID).get(inte).stopTime == null)
                    {
                        internalObj = mapIDToPerformance2.get(methodID).get(inte);
                        break;
                    }
                }
            }
            else
            {
                internalObj = mapIDToPerformance2.get(methodID).get(0);
            }
            //system.debug('internalObj Stopped: ' + internalObj);
            internalObj.stopTime = Datetime.now();
            if(internalObj.startTime != null)
                internalObj.timeStamp = integer.valueOf(internalObj.stopTime.getTime() - internalObj.startTime.getTime());
            mapIDToPerformance2.get(methodID).put(internalObj.count, internalObj);
        }
        else
        {
            internalPerformance internalObj = new internalPerformance();
            internalObj.startTime = null;
            internalObj.stopTime = Datetime.now();
            internalObj.count = 0;
            map<integer, internalPerformance> tempMap = new map<integer, internalPerformance>();
            tempMap.put(internalObj.count, internalObj);
            mapIDToPerformance2.put(methodID, tempMap);
        }
        //system.debug('Map after stop of Method: ' + methodID + ' is: ' + mapIDToPerformance2 + ' and size is: ' + mapIDToPerformance2.size());
    }
}