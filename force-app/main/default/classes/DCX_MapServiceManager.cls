/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Service manager which has business logic for all the services, related to map functionality, re-written for DCx
 * @author Vinay Vijay, Bhagyashree Aratti
 * @version 19.2000
 * @since 2019
 */
public with sharing class DCX_MapServiceManager {
    
    Public static map<String,String> mapReplacementNameFieldLocsss = new map<String,String>();
    Public static map<String,String> mapReplacementRefWO = new map<String,String>();
   
    Public static map<String,String> mapReplacementNameFieldWO = new map<String,String>();
    Public static map<String,String> mapReplacementRefAcc = new map<String,String>();
    Public static map<String,String> mapReplacementNameFieldAcc = new map<String,String>();
    Public static map<String,String> mapReplacementRefLoc = new map<String,String>();
    Public static map<String,String> mapReplacementNameFieldLoc = new map<String,String>();
    Public static list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigDataWO = new list<SVMXC__ServiceMax_Config_Data__c>();
    Public static list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigDataLoc = new list<SVMXC__ServiceMax_Config_Data__c>();
    Public static list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigDataAcc = new list<SVMXC__ServiceMax_Config_Data__c>();

   
    
   public  static SVMXC.INTF_WebServicesDef.INTF_Response getMapData(string objectname,string viewId,Integer recordlimit,Double latitude,Double longitude,Double radius)
    {
                   
        String strObjectName = objectname;
        String strViewId = viewId;
        
        
       
        Double dblLatitude = 0;
        Double dblLongitude = 0;
        Double dblRadius = 0;
        Integer intNoOfRecords = 0;
        
        dblLatitude = latitude;
        dblLongitude = longitude;
        dblRadius = radius;
        intNoOfRecords = recordlimit;
        SVMXC__ServiceMax_Processes__c objView = new SVMXC__ServiceMax_Processes__c();
        map <string,SVMXC__ServiceMax_Processes__c> objView1 = new map<string,SVMXC__ServiceMax_Processes__c>();
        
        list<string>viewIds = new list<string>();
        SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
        list<string> lstSubModuleId = new list<string>{'DCON001'};
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        list<SVMXC.INTF_WebServicesDef.INTF_StringListMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringListMap>();
        map<string, Map<String, String>> mapDCSetting = settings.SVMX_getSettingList(lstSubModuleId);
         map<String, Schema.SObjectType> mapAllobjDesc  = new map<String, Schema.SObjectType>();
      /*  for(Schema.SObjectType s : Schema.getGlobalDescribe().values())
        {
             Schema.DescribeSObjectResult result = s.getDescribe();
             mapAllobjDesc.put(result.getName(),s);
        } */
        
        Schema.Describesobjectresult woDefinitions = SVMXC__Service_Order__c.sObjectType.getDescribe();
        mapAllobjDesc.put(woDefinitions.getName(), woDefinitions.getSobjectType());
        Schema.Describesobjectresult SiteDefinitions = SVMXC__Site__c.sObjectType.getDescribe();
        mapAllobjDesc.put(SiteDefinitions.getName(), SiteDefinitions.getSobjectType());
        Schema.Describesobjectresult AccountDefinitions = Account.sObjectType.getDescribe();
        mapAllobjDesc.put(AccountDefinitions.getName(), AccountDefinitions.getSobjectType());

        
        
        if(strViewId !=null)
        {
            viewIds = strViewId.split(',');
        }
        
       for(ServiceMax_Processes__c ViewRec :[Select Id, SVMXC__Name__c, SVMXC__Ownership_Type__c,  SVMXC__Parent_Object_Criteria__c, SVMXC__Source_Object_Name__c, SVMXC__View_For__c, SVMXC__Values__c From SVMXC__ServiceMax_Processes__c where Id =:viewIds] )
       {
           objView1.put(ViewRec.id,ViewRec);
       }
        
       /* if(request != null && request.stringMap != null && request.stringMap.size() > 0)
        {
            for(Integer i = 0;i<request.stringMap.size();i++)
            {
                if(request.stringMap[i].key != null && request.stringMap[i].key.touppercase() == 'OBJECTNAME' && request.stringMap[i].value != null)
                {
                    strObjectName = request.stringMap[i].value;
                }
                else if (request.stringMap[i].key != null && request.stringMap[i].key.touppercase() == 'VIEWID' && request.stringMap[i].value != null)
                {
                     strViewId = request.stringMap[i].value;
                     viewIds = strViewId.split(',');
                }
                else if(request.stringMap[i].key != null && request.stringMap[i].key.touppercase() == 'RECORDLIMIT' && request.stringMap[i].value != null)
                {
                    intNoOfRecords = Integer.valueof(request.stringMap[i].value);
                }
                else if(request.stringMap[i].key != null && request.stringMap[i].key.touppercase() == 'LATITUDE'  && request.stringMap[i].value != null)
                {
                    dblLatitude = Double.valueof(request.stringMap[i].value);
                }
                else if(request.stringMap[i].key != null && request.stringMap[i].key.touppercase() == 'LONGITUDE'  && request.stringMap[i].value != null)
                {
                    dblLongitude = Double.valueof(request.stringMap[i].value);
                }
                else if(request.stringMap[i].key != null && request.stringMap[i].key.touppercase() == 'RADIUS'  && request.stringMap[i].value != null)
                {
                    dblRadius = Double.valueof(request.stringMap[i].value);
                }
            }
        }*/
                    
        
       for(Integer m = 0; m<viewIds.size();m++ )
       {
                    String strQueryFields = '';
                     String strWhereClouse = '';
                     String strOwnerShipType = '';
                     Set<String> setFields = new set<String>();
                     list<SVMXC__ServiceMax_Processes__c> lstHoverHeader = new list<SVMXC__ServiceMax_Processes__c>();
                     SVMXC__ServiceMax_Processes__c objHoverHeader = new SVMXC__ServiceMax_Processes__c();
                     list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
                    
                    map<String, SObjectField> mapFieldDesc = new map<String, SObjectField>();
                    map<String, String> mapAPINameLabel = new map<String, String>();
                    map<String,String> mapReplacementRef = new map<String,String>();
                    map<String,String> mapReplacementNameField = new map<String,String>();
                                        list<Sobject> lstSobject = new list<Sobject>();
                    map<Double,list<String>> mapDistanceWOIds = new map<Double,list<String>>();
                    map<String,Sobject> mapIdSobject = new map<String,Sobject>();
                    DCX_Utils dcUtils = new DCX_Utils();
                    
                    
                if(viewIds.size() > 0)
                {
                     
                    try
                    {
                         //objView = [Select Id, SVMXC__Name__c, SVMXC__Ownership_Type__c,  SVMXC__Parent_Object_Criteria__c, SVMXC__Source_Object_Name__c, SVMXC__View_For__c, SVMXC__Values__c From SVMXC__ServiceMax_Processes__c where Id =: viewIds[m]];
                         objView =objView1.get(viewIds[m]);
                         system.debug('objView ::' +objView);
                    }
                    catch(Exception ex)
                    {
                        response.success = false;
                        response.message = ex.getmessage();
                        return response;
                    }
                    if(objView.SVMXC__Values__c != null)
                    {
                        strQueryFields = objView.SVMXC__Values__c;
                        list<String> lstfld = new list<String>();
                        lstfld = objView.SVMXC__Values__c.split(',');
                        if(lstfld != null && lstfld.size() > 0)
                            setFields.addall(lstfld);
                    }
                    //system.debug(logginglevel.warn,'setFields: '+setFields);
                    if(objView.SVMXC__Parent_Object_Criteria__c != null)
                        strWhereClouse = objView.SVMXC__Parent_Object_Criteria__c;
                    if(objView.SVMXC__Ownership_Type__c != null)
                        strOwnerShipType = objView.SVMXC__Ownership_Type__c;
                    system.debug(logginglevel.warn,'strWhereClouse'+m+' : '+strWhereClouse);
                    system.debug(logginglevel.warn,'strOwnerShipType'+m+' : '+strOwnerShipType);
                    if( strOwnerShipType != null && strOwnerShipType.length() > 0 && strOwnerShipType == 'User\'s Records')//isView &&
                    {
                        String strUserId = Userinfo.getUserId();
                        if(strWhereClouse != null && strWhereClouse.length() > 0)
                            strWhereClouse = ' ( ' + strWhereClouse + ' ) ' + ' AND OwnerId =: strUserId';
                        else 
                            strWhereClouse += 'OwnerId =: strUserId';
                    }
                    system.debug(logginglevel.warn,'strWhereClouse'+strWhereClouse);  
                    if(strWhereClouse != '')
                        strWhereClouse = '( ' + strWhereClouse + ' )';
                    if(strObjectName != null && strObjectName.length() > 0)
                    {
                        //try
                        //{
                            /* lstHoverHeader = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c =: strObjectName];
                            //system.debug(logginglevel.warn,'objHoverHeader: '+objHoverHeader);
                            if(lstHoverHeader != null && lstHoverHeader.size() > 0)
                            {
                                objHoverHeader = lstHoverHeader[0];
                            }
                            if(objHoverHeader != null && objHoverHeader.id != null)
                                lstHoverConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objHoverHeader.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field' order by SVMXC__Sequence__c];
                            system.debug(logginglevel.warn,'lstHoverConfigData'+lstHoverConfigData); */
                            if(strObjectName =='SVMXC__Service_Order__c' && lstHoverConfigDataWO.isempty())
                            {
                                lstHoverConfigDataWO = GetHoverConfigdata(strObjectName);
                               
                            }
                            
                            if(strObjectName =='SVMXC__Site__c' && lstHoverConfigDataLoc.isempty())
                            {
                                lstHoverConfigDataLoc = GetHoverConfigdata(strObjectName);
                               
                            }
                            
                            if(strObjectName =='Account' && lstHoverConfigDataLoc.isempty())
                            {
                                lstHoverConfigDataAcc = GetHoverConfigdata(strObjectName);
                               
                            }
                            
                           if(lstHoverConfigDataWO != null && lstHoverConfigDataWO.size() > 0) 
                           {
                              lstHoverConfigData = lstHoverConfigDataWO;

                           }
                           else if (lstHoverConfigDataLoc != null && lstHoverConfigDataLoc.size() > 0)
                           {
                               lstHoverConfigData = lstHoverConfigDataLoc;
                           }
                           else
                           {
                               lstHoverConfigData = lstHoverConfigDataAcc;
                           }
                            
                            //lstHoverConfigData = GetHoverConfigdata(strObjectName);
                            
                            if(lstHoverConfigData != null && lstHoverConfigData.size() > 0)
                            {
                                for(SVMXC__ServiceMax_Config_Data__c cg : lstHoverConfigData)
                                {
                                    if(cg.SVMXC__Field_Name__c != null && cg.SVMXC__Display_Type__c != null && cg.SVMXC__Display_Type__c != 'REFERENCE' && !setFields.contains(cg.SVMXC__Field_Name__c))
                                    {
                                        setFields.add(cg.SVMXC__Field_Name__c);
                                        if(strQueryFields != null && strQueryFields.length() > 0)
                                            strQueryFields += ','+cg.SVMXC__Field_Name__c;
                                        else 
                                            strQueryFields  +=  cg.SVMXC__Field_Name__c;
                                    }
                                    else if(cg.SVMXC__Field_Name__c != null && cg.SVMXC__Display_Type__c != null && cg.SVMXC__Display_Type__c == 'REFERENCE' && cg.SVMXC__Field_Relationship_Name__c != null && cg.SVMXC__FKey_Name_Field__c != null && !setFields.contains(cg.SVMXC__Field_Relationship_Name__c+'.'+cg.SVMXC__FKey_Name_Field__c))
                                    {
                                        setFields.add(cg.SVMXC__Field_Relationship_Name__c+'.'+cg.SVMXC__FKey_Name_Field__c);
                                        if(strQueryFields != null && strQueryFields.length() > 0)
                                            strQueryFields += ','+cg.SVMXC__Field_Relationship_Name__c+'.'+cg.SVMXC__FKey_Name_Field__c;
                                        else 
                                            strQueryFields  +=  cg.SVMXC__Field_Relationship_Name__c+'.'+cg.SVMXC__FKey_Name_Field__c;
                                    }       
                                }
                            }   
                        /*}
                        catch(Exception ex)
                        {
                            response.success = false;
                            response.message = ex.getmessage();
                            return response;
                        }   */
                    }
                
                }
                double distance;
                
                
                if(mapDCSetting.containsKey('DCON001') && mapDCSetting.get('DCON001').containsKey('SET055')&&  mapDCSetting.get('DCON001').get('SET055') == 'Miles')
                {
                    system.debug('if');
                    distance = 0.009 * 1.60934 * dblRadius;
                }
                else
                {
                    system.debug('else');
                     distance = 0.009 *  dblRadius;
                }
                double lat_min1 = dblLatitude - distance;
                double lat_max1 = dblLatitude + distance;
                double long_min1 = dblLongitude - (distance / Math.cos(dblLatitude*Math.PI/180));
                double long_max1 = dblLongitude + (distance / Math.cos(dblLatitude*Math.PI/180));
                
                string lat_min = string.valueOf(lat_min1);
                string lat_max = string.valueOf(lat_max1);
                string long_min = string.valueOf(long_min1);
                string long_max = string.valueOf(long_max1);
                
                system.debug('lat_min' + lat_min);
                system.debug('lat_max' + lat_max);
                system.debug('long_min' + long_min);
                system.debug('long_max' + long_max);
                
                 String strWhereClouse1 = ' AND SVMXC__Latitude__c >= '+lat_min+' AND SVMXC__Latitude__c <='+ lat_max +'AND SVMXC__Longitude__c>= '+long_min + ' AND SVMXC__Longitude__c<= ' +long_max;
                

                if(strObjectName != null && strObjectName.length() > 0 && strObjectName == 'SVMXC__Service_Order__c')
                {
                    if(!setFields.contains('SVMXC__Latitude__c'))
                    {
                        setFields.add('SVMXC__Latitude__c');
                        if(strQueryFields != null && strQueryFields.length() > 0)
                            strQueryFields += ', SVMXC__Latitude__c';
                        else 
                            strQueryFields += 'SVMXC__Latitude__c';
                    }
                    if(!setFields.contains('SVMXC__Longitude__c'))
                    {
                        setFields.add('SVMXC__Longitude__c');
                        strQueryFields += ', SVMXC__Longitude__c';
                    }           
                    if(strWhereClouse != null && strWhereClouse.length() > 0)
                        strWhereClouse += ' AND SVMXC__Latitude__c != null AND SVMXC__Longitude__c != null ';
                    else 
                        strWhereClouse += ' SVMXC__Latitude__c != null AND SVMXC__Longitude__c != null ';
                       
                    String[] arrFlds = strQueryFields.split(',');
                    COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
                    arrFlds = objCOMM_UtilV2.checkDuplicateFields(arrFlds, 'SVMXC__Service_Order__c');
                    strQueryFields = dcUtils.SVMX_getFieldNamesFromList(arrFlds);            
    
                    String strQuery = 'Select '+strQueryFields+' From SVMXC__Service_Order__c where '+strWhereClouse +strWhereClouse1 ;
                    system.debug(logginglevel.warn,'strQuery: '+strQuery);
                    lstSobject = database.query(strQuery);  
                    system.debug('lstSobject size:'+lstSobject.size()+'  '+lstSobject);
                    if(mapAllobjDesc.containskey(strObjectName))
                    {
                        mapFieldDesc = mapAllobjDesc.get(strObjectName).getDescribe().fields.getMap();
                        system.debug('mapFieldDesc'+mapFieldDesc);
                        if(mapFieldDesc.size() > 0)
                        {
                            for(String str : mapFieldDesc.keyset())
                            {
                                mapAPINameLabel.put(mapFieldDesc.get(str).getDescribe().getName(),mapFieldDesc.get(str).getDescribe().getLabel());
                            }
                        }
                        system.debug(logginglevel.warn,'mapAPINameLabel'+mapAPINameLabel);
                        system.debug('number of iteration 9988 -> '+mapReplacementRefWO );
                        if(mapReplacementRefWO.isempty() && mapReplacementNameFieldWO.isempty())
                        { 
                          DCX_Utils.referenceFields_WP reference_MWO = dcUtils.SVMX_getReferenceFields(mapFieldDesc,true);
                          mapReplacementRefWO = reference_MWO.replacementReference_M;  //Get the replacement reference field map
                          mapReplacementNameFieldWO = reference_MWO.replacementField_M;  //Get the name field for reference map
                          system.debug('number of iteration 9999 -> '+mapReplacementRefWO );
                          //system.debug(logginglevel.warn,'mapReplacementRef'+mapReplacementRef);
                          //system.debug(logginglevel.warn,'mapReplacementNameField'+mapReplacementNameField);
                        }
                       
                       
                    }   
                }
                 else if(strObjectName != null &&  strObjectName.length() > 0 && strObjectName == 'SVMXC__Site__c')
                {
                    if(!setFields.contains('SVMXC__Latitude__c'))
                    {
                        setFields.add('SVMXC__Latitude__c');
                        if(strQueryFields != null && strQueryFields.length() > 0)
                            strQueryFields += ', SVMXC__Latitude__c';
                        else 
                            strQueryFields += 'SVMXC__Latitude__c';
                    }
                    if(!setFields.contains('SVMXC__Longitude__c'))
                    {
                        setFields.add('SVMXC__Longitude__c');
                        strQueryFields += ', SVMXC__Longitude__c';
                    }           
                    if(strWhereClouse != null && strWhereClouse.length() > 0)
                        strWhereClouse += ' AND SVMXC__Latitude__c != null AND SVMXC__Longitude__c != null ';
                    else 
                        strWhereClouse += ' SVMXC__Latitude__c != null AND SVMXC__Longitude__c != null ';
                        
                    String strQuery = 'Select '+strQueryFields+' From SVMXC__Site__c where '+strWhereClouse+strWhereClouse1;
                    system.debug(logginglevel.warn,'strQuery: '+strQuery);
                    lstSobject = database.query(strQuery);
                    if(mapAllobjDesc.containskey(strObjectName))
                    {
                        mapFieldDesc = mapAllobjDesc.get(strObjectName).getDescribe().fields.getMap();
                        if(mapFieldDesc.size() > 0)
                        {
                            for(String str : mapFieldDesc.keyset())
                            {
                                mapAPINameLabel.put(mapFieldDesc.get(str).getDescribe().getName(),mapFieldDesc.get(str).getDescribe().getLabel());
                            }
                        }
                        if(mapReplacementRefLoc.isempty() && mapReplacementNameFieldLoc.isempty())
                        {
                        DCX_Utils.referenceFields_WP reference_MLoc = dcUtils.SVMX_getReferenceFields(mapFieldDesc,true);
                        mapReplacementRefLoc = reference_MLoc.replacementReference_M;  //Get the replacement reference field map
                        mapReplacementNameFieldLoc = reference_MLoc.replacementField_M;  //Get the name field for reference map
                        }
                    }   
                }
                else if(strObjectName != null &&  strObjectName.length() > 0 && strObjectName == 'Account')
                {
                    if(!setFields.contains('SVMXC__Latitude__c'))
                    {
                        setFields.add('SVMXC__Latitude__c');
                        if(strQueryFields != null && strQueryFields.length() > 0)
                            strQueryFields += ', SVMXC__Latitude__c';
                        else 
                            strQueryFields += 'SVMXC__Latitude__c';
                    }
                    if(!setFields.contains('SVMXC__Longitude__c'))
                    {
                        setFields.add('SVMXC__Longitude__c');
                        strQueryFields += ', SVMXC__Longitude__c';
                    }           
                    if(strWhereClouse != null && strWhereClouse.length() > 0)
                        strWhereClouse += ' AND SVMXC__Latitude__c != null AND SVMXC__Longitude__c != null ';
                    else 
                        strWhereClouse += ' SVMXC__Latitude__c != null AND SVMXC__Longitude__c != null ';
                        
                    String strQuery = 'Select '+strQueryFields+' From Account where '+strWhereClouse +strWhereClouse1;
                    system.debug(logginglevel.warn,'strQuery: '+strQuery);
                    lstSobject = database.query(strQuery);
                    if(mapAllobjDesc.containskey(strObjectName))
                    {
                        mapFieldDesc = mapAllobjDesc.get(strObjectName).getDescribe().fields.getMap();
                        if(mapFieldDesc.size() > 0)
                        {
                            for(String str : mapFieldDesc.keyset())
                            {
                                mapAPINameLabel.put(mapFieldDesc.get(str).getDescribe().getName(),mapFieldDesc.get(str).getDescribe().getLabel());
                            }
                        }
                        
                        if(mapReplacementRefAcc.isempty() && mapReplacementNameFieldAcc.isempty())
                        {
                        DCX_Utils.referenceFields_WP reference_MAcc = dcUtils.SVMX_getReferenceFields(mapFieldDesc,true);
                        mapReplacementRefAcc = reference_MAcc.replacementReference_M;  //Get the replacement reference field map
                        mapReplacementNameFieldAcc = reference_MAcc.replacementField_M;  //Get the name field for reference map
                        }
                    }   
                }
                
            if(lstSobject.size() > 0)
            {
                for(Integer i =0;i<lstSobject.size();i++)
                {
                    mapIdSobject.put(lstSobject[i].id,lstSobject[i]);
                    
                    Sobject obj = lstSobject[i];
                  //  system.debug('lstSobject[i] '+ii+lstSobject[i]);
                    Double dblDistance = dcUtils.getDistanceBetween(dblLatitude, dblLongitude, Double.valueOf(obj.get('SVMXC__Latitude__c')), Double.valueof(obj.get('SVMXC__Longitude__c')));
                    //40533 - added following if condition to convert KM to miles, if the DC setting in map is miles
                    if(mapDCSetting.containsKey('DCON001') && mapDCSetting.get('DCON001').containsKey('SET055')&& 
                mapDCSetting.get('DCON001').get('SET055') == 'Miles')
                    {
                        double kmToMiles = 0.621371;
                        dblDistance = dblDistance * kmToMiles;
                    } 
                                
                    if(dblDistance <= dblRadius)
                    {
                        if(mapDistanceWOIds.containskey(dblDistance))
                        {
                            mapDistanceWOIds.get(dblDistance).add(lstSobject[i].id);
                        }
                        else
                        {
                            mapDistanceWOIds.put(dblDistance,new list<String>());
                            mapDistanceWOIds.get(dblDistance).add(lstSobject[i].id);
                        }
                    }   
                }
            }
            
            lstSobject.clear();
            if(mapDistanceWOIds.size() > 0)
            {
                list<Double> lstDistance = new list<Double>();
                lstDistance.addall(mapDistanceWOIds.keyset());
                lstDistance.sort();
                for(integer i = 0;i<lstDistance.size();i++)
                {
                    if(mapDistanceWOIds.containskey(lstDistance[i]))
                    {
                        list<String> lstIds = new list<String>();
                        lstIds = mapDistanceWOIds.get(lstDistance[i]);
                        if(lstIds.size() > 0)
                        {
                            for(Integer j = 0;j<lstIds.size();j++)
                            {
                                if(mapIdSobject.containskey(lstIds[j]))
                                    lstSobject.add(mapIdSobject.get(lstIds[j]));
                            }
                        }
                    }
                }
            }   
           system.debug('lstSobject 1:'+lstSobject); 
           if(lstSobject.size() > 0)
            {
                for(Integer i = 0;i<lstSobject.size();i++)
                {
                    Sobject obj = lstSobject[i];
                    system.debug('obj >>> '+obj.getSObjectType());
                    list<String> lstHover = new list<String>();
                    
                    for(Integer j = 0;j<lstHoverConfigData.size();j++)
                {
                  String str = '';
                  if(lstHoverConfigData[j].SVMXC__Field_Name__c != null && mapAPINameLabel.containskey(lstHoverConfigData[j].SVMXC__Field_Name__c))
                  {
                    str = '<B>'+mapAPINameLabel.get(lstHoverConfigData[j].SVMXC__Field_Name__c) + '</B>: ' ;
                    if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() == 'REFERENCE' )//obj.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null
                    {
                        system.debug('strObjectName -> '+ strObjectName);
                        if(strObjectName =='SVMXC__Service_Order__c')
                        {
                        system.debug(logginglevel.warn,'map Replacement Ref'+mapReplacementRefWO.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                        Sobject objRef = obj.getSobject(mapReplacementRefWO.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                            if(objRef!=NULL)
                            {
                                str = str +String.valueof(objRef.get(mapReplacementNameFieldWO.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                            }
                        }
                        if(strObjectName == 'SVMXC__Site__c')
                        {
                        system.debug(logginglevel.warn,'map Replacement RefLOC '+mapReplacementRefLoc.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                        Sobject objRef = obj.getSobject(mapReplacementRefLoc.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                            if(objRef!=NULL)
                            {
                                str = str +String.valueof(objRef.get(mapReplacementNameFieldLoc.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                            }
                        }
                        
                        if(strObjectName == 'Account')
                        {
                        system.debug(logginglevel.warn,'map Replacement RefAcc '+mapReplacementRefAcc.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                        Sobject objRef = obj.getSobject(mapReplacementRefAcc.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                            if(objRef!=NULL)
                            {
                                str = str +String.valueof(objRef.get(mapReplacementNameFieldLoc.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                            }
                        }
                        
                    }
                    else if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() != 'REFERENCE' && obj.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                    {
                       str = str + String.valueof(obj.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                    }
                    lstHover.add(str);
                  }  
                }
                 SVMXC.INTF_WebServicesDef.INTF_StringListMap stringLstMap = new SVMXC.INTF_WebServicesDef.INTF_StringListMap();
                   stringLstMap.key = viewIds[m];
                    stringLstMap.valueList = lstHover;
                    stringLstMap.sobj = obj;
                    lstStringMap.add(stringLstMap);
                    if((i+1) == intNoOfRecords)
                    {
                        break;  
                    }
                }   
            } 
        }
       if(lstStringMap.size() > 0)
            response.StringLstMap = lstStringMap;
        system.debug(logginglevel.warn,'response: '+response);
        return response; 
    }
    
    
    // This is created for optimization of hover function . 
   private static list<SVMXC__ServiceMax_Config_Data__c> GetHoverConfigdata(string strObjectName)
   {
      list<SVMXC__ServiceMax_Processes__c> lstHoverHeader = new list<SVMXC__ServiceMax_Processes__c>();
      SVMXC__ServiceMax_Processes__c objHoverHeader = new SVMXC__ServiceMax_Processes__c();
      list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
 
      lstHoverHeader = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c =: strObjectName];
      //system.debug(logginglevel.warn,'objHoverHeader: '+objHoverHeader);
      if(lstHoverHeader != null && lstHoverHeader.size() > 0)
      {
          objHoverHeader = lstHoverHeader[0];
      }
      if(objHoverHeader != null && objHoverHeader.id != null)
       lstHoverConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objHoverHeader.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field' order by SVMXC__Sequence__c];
       system.debug(logginglevel.warn,'lstHoverConfigData'+lstHoverConfigData);


     return lstHoverConfigData;
   
   } 

   /*public SVMXC.INTF_WebServicesDef.INTF_Response getViewDefinition(SVMXC.INTF_WebServicesDef.INTF_Request request)
   {
       system.debug(logginglevel.warn,'request: '+request);
       SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
       Boolean isCalledFromDC = false; 
       String strUserId = '';
       String strFinalWhereClouse = ''; 
       String strFirstWhereClouse = 'where RecordType.Name = \'View Definition\' AND SVMXC__Rule_Type__c = \'Custom View\'';
       String strObjectNameWhereClouse = '';
       String strViewForWhereClouse = '';
       list<String> lstObjectName = new list<String>();
       list<String> lstViewFor = new list<String>();
       list<SVMXC__Dispatcher_Access__c> lstDPAcceess = new list<SVMXC__Dispatcher_Access__c>();
       list<SVMXC__Service_Group_Members__c> lstTech = new list<SVMXC__Service_Group_Members__c >();
       list<SVMXC__ServiceMax_Processes__c> lstViews = new list<SVMXC__ServiceMax_Processes__c>();
       set<String> setServiceTeams = new set<String>();
       set<String> setTerittories = new set<String>();
       set<String> setViewIds = new set<String>();
       if(request != null && request.stringListMap != null && request.stringListMap.size() > 0)
       {
           for(Integer i = 0;i<request.stringListMap.size();i++)
           {
               if(request.stringListMap[i].key != null && request.stringListMap[i].key.touppercase() == 'OBJECTNAME' && request.stringListMap[i].valueList != null && request.stringListMap[i].valueList.size() > 0)
               {
                   lstObjectName = request.stringListMap[i].valueList;
               }
               else if (request.stringListMap[i].key != null && request.stringListMap[i].key.touppercase() == 'VIEWFOR' && request.stringListMap[i].valueList != null && request.stringListMap[i].valueList.size() > 0)
               {
                    lstViewFor = request.stringListMap[i].valueList;
               }
               else if(request.stringListMap[i].key != null && request.stringListMap[i].key.touppercase() == 'USERID' && request.stringListMap[i].valueList != null && request.stringListMap[i].valueList.size() > 0)
               {
                   strUserId = request.stringListMap[i].valueList[0];
               }
               else if(request.stringListMap[i].key != null && request.stringListMap[i].key.touppercase() == 'ISCALLEDFROMDC')
               {
                   isCalledFromDC = true;
               }
           }
       }
       lstDPAcceess = [Select SVMXC__Territory__c, SVMXC__Service_Team__c, SVMXC__Dispatcher__c, Name, Id From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: strUserId and (SVMXC__Service_Team__c != null OR SVMXC__Territory__c != null)];
       //If logged in user is dispatcher..
       if(lstDPAcceess.size() > 0)
       {
           system.debug(logginglevel.warn,'Is Dispatcher');
           for(SVMXC__Dispatcher_Access__c DP : lstDPAcceess)
           {
               if(DP.SVMXC__Service_Team__c!= null)
                   setServiceTeams.add(DP.SVMXC__Service_Team__c);
               if(DP.SVMXC__Territory__c != null)
                   setTerittories.add(DP.SVMXC__Territory__c); 
           }
           list<SVMXC__ServiceMax_Config_Data__c> lstViewAccessForST = new list<SVMXC__ServiceMax_Config_Data__c>();
           list<SVMXC__ServiceMax_Config_Data__c> lstViewAccessForTerritories = new list<SVMXC__ServiceMax_Config_Data__c>();
           if(setServiceTeams.size() > 0)
               lstViewAccessForST = [select Id, SVMXC__Access_To__c, SVMXC__Dispatch_Process__c, SVMXC__Configuration_Type__c, SVMXC__Service_Group__c, SVMXC__Territory__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Service_Group__c IN :setServiceTeams and RecordType.Name = 'View Access' and SVMXC__Configuration_Type__c = 'Custom_View' and SVMXC__Access_To__c != 'Technician'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           if(setTerittories.size() > 0)
               lstViewAccessForTerritories = [select Id, SVMXC__Access_To__c, SVMXC__Dispatch_Process__c, SVMXC__Configuration_Type__c, SVMXC__Service_Group__c, SVMXC__Territory__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Territory__c IN :setTerittories and RecordType.Name = 'View Access' and SVMXC__Configuration_Type__c = 'Custom_View' and SVMXC__Access_To__c != 'Technician'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           if(lstViewAccessForST.size() > 0)
           {
               for(SVMXC__ServiceMax_Config_Data__c configData : lstViewAccessForST)
               {
                   if(configData.SVMXC__Dispatch_Process__c != null)
                       setViewIds.add(configData.SVMXC__Dispatch_Process__c);
               }
           }
           if(lstViewAccessForTerritories.size() > 0)
           {
               for(SVMXC__ServiceMax_Config_Data__c configData : lstViewAccessForTerritories)
               {
                   if(configData.SVMXC__Dispatch_Process__c != null)
                       setViewIds.add(configData.SVMXC__Dispatch_Process__c);
               }
           }   
       }  
       // If logged in user is technician 
       lstTech = [Select SVMXC__Service_Territory__c, SVMXC__Service_Group__c, SVMXC__Salesforce_User__c, Name, Id From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c =: strUserId];
       system.debug(logginglevel.warn,'lstTech'+lstTech);
       if(lstTech.size() > 0)
       {
           list<SVMXC__ServiceMax_Config_Data__c> lstViewAccessForST = new list<SVMXC__ServiceMax_Config_Data__c>();
           list<SVMXC__ServiceMax_Config_Data__c> lstViewAccessForTerritories = new list<SVMXC__ServiceMax_Config_Data__c>();
           lstViewAccessForST = [select Id, SVMXC__Access_To__c, SVMXC__Dispatch_Process__c, SVMXC__Configuration_Type__c, SVMXC__Service_Group__c, SVMXC__Territory__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Service_Group__c =: lstTech[0].SVMXC__Service_Group__c and RecordType.Name = 'View Access' and SVMXC__Configuration_Type__c = 'Custom_View' and SVMXC__Access_To__c != 'Dispatcher'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           system.debug(logginglevel.warn,'lstViewAccessForST'+lstViewAccessForST);
           if(lstTech[0].SVMXC__Service_Territory__c != null)
               lstViewAccessForTerritories = [select Id, SVMXC__Access_To__c, SVMXC__Dispatch_Process__c, SVMXC__Configuration_Type__c, SVMXC__Service_Group__c, SVMXC__Territory__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Territory__c =: lstTech[0].SVMXC__Service_Territory__c and RecordType.Name = 'View Access' and SVMXC__Configuration_Type__c = 'Custom_View' and SVMXC__Access_To__c != 'Dispatcher'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           system.debug(logginglevel.warn,'lstViewAccessForTerritories'+lstViewAccessForTerritories);
           if(lstViewAccessForST.size() > 0)
           {
               for(SVMXC__ServiceMax_Config_Data__c configData : lstViewAccessForST)
               {
                   if(configData.SVMXC__Dispatch_Process__c != null)
                       setViewIds.add(configData.SVMXC__Dispatch_Process__c);
               }
           }
           if(lstViewAccessForTerritories.size() > 0)
           {
               for(SVMXC__ServiceMax_Config_Data__c configData : lstViewAccessForTerritories)
               {
                   if(configData.SVMXC__Dispatch_Process__c != null)
                       setViewIds.add(configData.SVMXC__Dispatch_Process__c);
               }
           }
       }
       system.debug(logginglevel.warn,'setViewIds'+setViewIds);
       if(lstObjectName != null && lstObjectName.size() > 0)
       {
           for(Integer i = 0;i<lstObjectName.size();i++)
           {
               if(strObjectNameWhereClouse != null && strObjectNameWhereClouse.length() > 0)
                   strObjectNameWhereClouse += ' OR SVMXC__Source_Object_Name__c = \''+lstObjectName[i]+'\'';
               else
                   strObjectNameWhereClouse += 'SVMXC__Source_Object_Name__c = \''+lstObjectName[i]+'\'';
           }
       } 
       if(lstViewFor != null && lstViewFor.size() > 0)
       {
           for(Integer i = 0;i<lstViewFor.size();i++)
           {
               if(strViewForWhereClouse != null && strViewForWhereClouse.length() > 0)
                   strViewForWhereClouse += ' OR SVMXC__View_For__c  = \''+lstViewFor[i]+'\'';
               else
                   strViewForWhereClouse += 'SVMXC__View_For__c  = \''+lstViewFor[i]+'\'';
           }
           if(isCalledFromDC)
               strViewForWhereClouse += 'OR SVMXC__View_For__c  = null';
       }
       
       // Apurva : 16th Sep 2014
       //Building set of views which is not associated with any Tech or Dispatcher
       // Getting all the existing views, and removing all the views having any association (Technicians/Dispatcher/All)
       
       list<SVMXC__ServiceMax_Processes__c> lstpro = [Select Id, SVMXC__Name__c, SVMXC__Source_Object_Name__c, SVMXC__View_For__c, SVMXC__Values__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'View Definition' AND SVMXC__Rule_Type__c = 'Custom View'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
       
       set<string> setOfViews = new set<string>();
       for(SVMXC__ServiceMax_Processes__c obj :lstpro)
       setOfViews.add(obj.id);
       set<string> setViewsHavingPermission = new set<string>();

       list<AggregateResult> dcviews = [select SVMXC__dispatch_process__c  from SVMXC__servicemax_config_data__c where SVMXC__dispatch_process__c != null and recordtype.name = 'View Access' group by SVMXC__dispatch_process__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
       for(AggregateResult dcview : dcviews)
           setViewsHavingPermission.add(String.valueOf(dcview.get('SVMXC__dispatch_process__c')));
       setOfViews.removeAll(setViewsHavingPermission);
       setViewIds.addAll(setOfViews);


       system.debug(logginglevel.warn,'strObjectNameWhereClouse'+strObjectNameWhereClouse);
       system.debug(logginglevel.warn,'strViewForWhereClouse'+strViewForWhereClouse);
       strFinalWhereClouse += strFirstWhereClouse;
       if(strObjectNameWhereClouse != null && strObjectNameWhereClouse.length() > 0)
       {
           strFinalWhereClouse += ' AND ( '+strObjectNameWhereClouse +' ) ';
       }
       if(strViewForWhereClouse != null && strViewForWhereClouse.length() > 0)
       {
           strFinalWhereClouse += ' AND ( '+strViewForWhereClouse +' ) ';
       }
       if(setViewIds.size () > 0)
       {
           strFinalWhereClouse += ' AND Id IN : setViewIds';
       }
       system.debug(logginglevel.warn,'strFinalWhereClouse'+strFinalWhereClouse);
       if(strFinalWhereClouse != null && strFinalWhereClouse.length() > 0)
       {
           String strQuery = 'Select Id, SVMXC__Name__c, SVMXC__Source_Object_Name__c, SVMXC__View_For__c, SVMXC__Values__c From SVMXC__ServiceMax_Processes__c '+strFinalWhereClouse;
           system.debug(logginglevel.warn,'strQuery: '+strQuery);
           if(setViewIds.size () > 0)
           lstViews = database.query(strQuery);
           system.debug(logginglevel.warn,'lstViews: '+lstViews);
       }
       list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new  list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
       if(lstViews != null && lstViews.size() > 0)
       {
           for(Integer i = 0;i<lstViews.size();i++)
           {
               SVMXC.INTF_WebServicesDef.INTF_StringMap stringMap = new  SVMXC.INTF_WebServicesDef.INTF_StringMap();
               stringMap.key = lstViews[i].SVMXC__Source_Object_Name__c;
               stringMap.value = lstViews[i].SVMXC__Name__c;
               stringMap.value1 = lstViews[i].id;
               stringMap.type = lstViews[i].SVMXC__Values__c;
               lstStringMap.add(stringMap);
           }
       }
       if(lstStringMap.size() > 0)
           response.stringMap = lstStringMap;
       return response;
   }*/
    
}