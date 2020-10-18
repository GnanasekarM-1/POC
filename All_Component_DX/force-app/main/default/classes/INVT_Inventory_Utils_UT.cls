@isTest
        Private class INVT_Inventory_Utils_UT
        {
                static testMethod void INVT_Inventory_Utils_Stocktransfer(){
                    Test.startTest();
                    SVMXC__Site__c sourceSite = new SVMXC__Site__c();
                    sourceSite.name = 'Target Location';
                    sourceSite.SVMXC__Stocking_Location__c = true;
                    
                    insert sourceSite;
                    
                    SVMXC__Site__c targetSite = new SVMXC__Site__c();
                    targetSite.name = 'Source Location';
                    targetSite.SVMXC__Stocking_Location__c = true;
                    insert targetSite; 
                    
                    SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse(); SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
                    req.eventType = 'SYNC'; 
                    req.eventName = 'STOCK_TRANSFER';
                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjs = new List<SVMXC.INTF_WebServicesDef.SVMXMap>(); SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    obj1.key = 'STOCK_HEADER'; 
                     
                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjsHeader = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                    SVMXC.INTF_WebServicesDef.SVMXMap objHeader = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    objHeader.key = 'SOURCE';
                    objHeader.value = String.valueOf(sourceSite.id);
                     
                    SVMXC.INTF_WebServicesDef.SVMXMap objDes = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    objDes.key = 'TARGET';
                    objDes.value = String.valueOf(targetSite.id);
                    
                    SVMXC.INTF_WebServicesDef.SVMXMap invProcess = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    invProcess.key = 'INVENTORY_PROCESS';
                    invProcess.value = 'SXFR001';
                    
                    
                    lstObjsHeader.add(objHeader);
                    lstObjsHeader.add(objDes);
                    lstObjsHeader.add(invProcess);
                    obj1.valueMap = lstObjsHeader; 
                    
                    Product2 pd = new Product2();
                    pd.Name = 'test Pr';
                    insert pd;
                     
                    
                    SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    obj2.key = 'STOCK_LINE'; 
                    
                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjsLine = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                    SVMXC.INTF_WebServicesDef.SVMXMap objpart = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    objpart.key = 'PART';
                    objpart.value = pd.id;
                     
                    SVMXC.INTF_WebServicesDef.SVMXMap objQyn = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    objQyn.key = 'QUANTITY';
                    objQyn.value = '1';
                    
                    SVMXC.INTF_WebServicesDef.SVMXMap serialNumber = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    serialNumber.key = 'SERIAL_NUMBERS';
                    serialNumber.value = 'ABC001,ABC3001';
                    
                    
                    lstObjsLine.add(objpart);
                    lstObjsLine.add(objQyn);
                    lstObjsLine.add(serialNumber);
                    obj2.valueMap = lstObjsLine; 
                     
                     
                    lstObjs.add(obj1);
                    lstObjs.add(obj2);
                     
                    req.valueMap = lstObjs;
                     
                    //INVT_Inventory_Utils stockTransferUT = new INVT_Inventory_Utils();
                    resp  = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 


                    // Catch Statement
                    SVMXC.INTF_WebServicesDef.INTF_SFMRequest req1 = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
                    req1.eventType = 'SYNC'; 
                    req1.eventName = 'STOCK_TRANSFER';
                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjs1 = new List<SVMXC.INTF_WebServicesDef.SVMXMap>(); SVMXC.INTF_WebServicesDef.SVMXMap obj11 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    obj11.key = 'STOCK_HEADER'; 
                     
                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjsHeader1 = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                    SVMXC.INTF_WebServicesDef.SVMXMap objHeader1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    objHeader1.key = 'SOURCE';
                    objHeader1.value = '';
                     
                    SVMXC.INTF_WebServicesDef.SVMXMap objDes1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    objDes1.key = 'TARGET';
                    objDes1.value = '';
                    
                    SVMXC.INTF_WebServicesDef.SVMXMap invProcess1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    invProcess1.key = 'INVENTORY_PROCESS';
                    invProcess1.value = 'SXFR001';
                    
                    
                    lstObjsHeader1.add(objHeader);
                    lstObjsHeader1.add(objDes);
                    lstObjsHeader1.add(invProcess);
                    obj11.valueMap = lstObjsHeader; 

                    SVMXC.INTF_WebServicesDef.SVMXMap obj21 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    obj21.key = 'STOCK_LINE'; 

                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjsLine1 = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                    
                    lstObjsLine1.add(objpart);
                    lstObjsLine1.add(objQyn);
                    lstObjsLine1.add(serialNumber);
                    obj21.valueMap = lstObjsLine; 
                     
                     
                    lstObjs1.add(obj11);
                    lstObjs1.add(obj21);

                    req1.valueMap = lstObjs1;
                    resp  = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
                    Test.StopTest();
                }
                
                
                static testMethod void INVT_Inventory_UtilsLocatePart_UT()
                {
                      Test.startTest();
                      // Create Account
                    Account account = new Account( Name = 'Account',
                    ShippingStreet = 'ABC',
                    ShippingCity = 'PQR',
                    ShippingState = 'XYZ',
                    ShippingPostalCode = '111',
                    ShippingCountry = 'XYZ',
                    BillingStreet = 'ABC',
                    BillingCity = 'PQR',
                    BillingState = 'XYZ',
                    BillingPostalCode = '111',
                    BillingCountry = 'XYZ'); 
                    insert account;
                    // Create Contact
                    Contact contact = new Contact( LastName='Last',
                        AccountId = account.Id,
                        Email = 'svmxmailfortest@servicemax.com');
                    insert contact;
                    
                    // Create locations       
                    list<SVMXC__Site__c>lstLoc = new list<SVMXC__Site__c>();
                    SVMXC__Site__c location1 = new SVMXC__Site__c( Name = 'MG Road',
                        SVMXC__Stocking_Location__c = true,
                        SVMXC__Account__c = account.Id,
                        SVMXC__Email__c = 'testEmail@servicemax.com');
                    lstLoc.add(location1);
                     
                    SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'MG Road',
                        SVMXC__Stocking_Location__c = true,
                        SVMXC__Account__c = account.Id,
                        SVMXC__Latitude__c = 12.972397 ,
                        SVMXC__Longitude__c = 77.596947,
                        SVMXC__Location_Type__c = 'Field',
                        SVMXC__Email__c = 'testEmail@servicemax.com');
                        lstLoc.add(location2);
                    
                    insert lstLoc;
                    
                    // Creating product2
                    Product2 prod1 = new Product2( Name = 'prodPR1',
                        ProductCode='prodPR1',
                        SVMXC__Inherit_Parent_Warranty__c = True,
                        SVMXC__Enable_Serialized_Tracking__c = True,
                        SVMXC__Stockable__c = True );
                    insert prod1;
                     // Creating product Stock
                    list<SVMXC__Product_Stock__c> lstproStock1 = new list<SVMXC__Product_Stock__c>();
                    SVMXC__Product_Stock__c proStock1 = new SVMXC__Product_Stock__c();
                    proStock1.SVMXC__Status__c = 'Available';
                    proStock1.SVMXC__Product__c = prod1.id;
                    proStock1.SVMXC__Location__c = location1.Id;
                    proStock1.SVMXC__Quantity2__c = 2;
                    lstproStock1.add(proStock1);
                    
                    SVMXC__Product_Stock__c proStock2 = new SVMXC__Product_Stock__c();
                    proStock2.SVMXC__Status__c = 'Available';
                    proStock2.SVMXC__Product__c = prod1.id;
                    proStock2.SVMXC__Location__c = location2.Id;
                    proStock2.SVMXC__Quantity2__c = 1;
                    lstproStock1.add(proStock2);
                    insert lstproStock1;
                    
                    //creating stock Serial
                    list<SVMXC__Product_Serial__c> lststck = new list<SVMXC__Product_Serial__c>();
                    SVMXC__Product_Serial__c stck = new SVMXC__Product_Serial__c();
                    stck.SVMXC__Active__c = true;
                    stck.SVMXC__Product__c = prod1.id;
                    stck.SVMXC__Product_Stock__c = proStock1.id;
                    stck.name = 'Test1';
                    lststck.add(stck);
                    SVMXC__Product_Serial__c stck2 = new SVMXC__Product_Serial__c();
                    stck2.SVMXC__Active__c = true;
                    stck2.SVMXC__Product__c = prod1.id;
                    stck2.SVMXC__Product_Stock__c = proStock2.id;
                    stck2.name = 'Test2';
                    lststck.add(stck2);
                    insert lststck;
                    // Creating team
                    
                    SVMXC__Service_Group__c SerTeam = new SVMXC__Service_Group__c();
                    SerTeam.Name='TeamABC';
                    insert SerTeam;
                    
                // Creating Territory

                SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                                    Name = 'TERRITORY 1'
                                                    );
                insert objTerritory;
                
                // Creating Technician

                List<SVMXC__Service_Group_Members__c> TechList123 = new List<SVMXC__Service_Group_Members__c>();
                SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
                Tech1.Name='Tech1';
                Tech1.SVMXC__Service_Group__c=SerTeam.Id;
                Tech1.SVMXC__Enable_Scheduling__c=true;
                //
                List<User> userList = [select Id from User where Id !=: userinfo.getuserid() and IsActive = TRUE];
                Tech1.SVMXC__Salesforce_User__c = userList[0].Id;
                Tech1.SVMXC__Active__c = true;
                Tech1.SVMXC__Service_Territory__c = objTerritory.id;
                Tech1.SVMXC__Latitude__c = 12.972397 ;
                Tech1.SVMXC__Longitude__c = 77.596947;
                Tech1.SVMXC__Inventory_Location__c =location1.Id;
                Tech1.SVMXC__Latlong_Captured_On__c = system.now().addHours(-1);
            
                insert Tech1;
                string AccConfProfid ;
                list<SVMXC__ServiceMax_Config_Data__c> lstconf = new list<SVMXC__ServiceMax_Config_Data__c> ();
                lstconf = [select  SVMXC__Access_Configuration_Profile__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Profile__c =: UserInfo.getProfileId() ];
                if(!lstconf.isEmpty()){
                    AccConfProfid = lstconf.get(0).SVMXC__Access_Configuration_Profile__c;
                }
                else
                {
                    list<RecordType> lstrectype = new list<RecordType>();
                    list<string> lststr = new list<string>{'Configuration Profile','Configuration Access'};
                    
                    lstrectype = [SELECT Id,Name FROM RecordType WHERE Name in:lststr ];
                    
                    SVMXC__ServiceMax_Config_Data__c conf = new SVMXC__ServiceMax_Config_Data__c();
                    string strConfAccessid, strConfProfid;
                    /* if(lstrectype.isempty())                     
                    {
                        list<RecordType> lstrectype1 = new list<RecordType>();
                        RecordType rec = new RecordType();
                        rec.Name='Configuration Access';
                        rec.SobjectType = 'SVMXC__ServiceMax_Config_Data__c';
                        RecordType rec2 = new RecordType();
                        rec2.Name='Configuration Access';
                        rec2.SobjectType = 'SVMXC__ServiceMax_Config_Data__c';
                        lstrectype1.add(rec2);
                        lstrectype1.add(rec);
                        insert lstrectype1;
                    } */
                    lstrectype = [SELECT Id,Name FROM RecordType WHERE Name in:lststr ];
                    if(!lstrectype.isempty())
                    {
                        for(RecordType rec:lstrectype){
                            if(rec.Name.equalsignorecase('Configuration Access'))
                            {
                                strConfAccessid = rec.id;   
                            }
                            else if(rec.Name.equalsignorecase('Configuration Profile'))
                            {
                                strConfProfid = rec.id; 
                            }
                        }
                    }
                    
                    system.debug('lstrectype: '+lstrectype);
                    system.debug('strConfProfid: '+strConfProfid);
                    system.debug('strConfAccessid: '+strConfAccessid);
                
                    {
                        if(strConfProfid != '' && strConfProfid != null)
                        {
                            conf.RecordTypeid = strConfProfid;
                            conf.SVMXC__Configuration_Type__c = 'Group';
                            conf.SVMXC__Active__c = true;
                            conf.SVMXC__Profile__c = UserInfo.getProfileId() ;
                            insert conf;
                            system.debug('Conf Prof id : '+conf.id);
                        }
                        
                        if(strConfAccessid != '' && strConfAccessid != null)
                        {
                            SVMXC__ServiceMax_Config_Data__c confprof = new SVMXC__ServiceMax_Config_Data__c();
                            confprof.SVMXC__Profile__c = userinfo.getProfileId();
                            confprof.SVMXC__Configuration_Type__c = 'Group';
                            confprof.SVMXC__Active__c =true;
                            confprof.SVMXC__Access_Configuration_Profile__c  =conf.id;
                            confprof.RecordTypeid = strConfAccessid;
                            insert confprof;
                            system.debug('Conf Access id : '+confprof.id);
                        }
                        
                        AccConfProfid = conf.id;
                    }
                }
                SVMXC__SM_Inventory_Config__c testInvtConf = new SVMXC__SM_Inventory_Config__c();
                String str = '{"locatepartsetup":{"isEnabled":false,"Radius":10,"Distanceinunit":"kilometer","locationtype":["Field"],"inventoryprocess":null},"layout":{}}';
                
                testInvtConf.SVMXC__SM_Content__c = str;
                testInvtConf.SVMXC__SM_ServiceMax_Profile__c =  AccConfProfid;
                insert testInvtConf;
                
                
                SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse(); 
                SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
                req.eventType = 'SYNC'; 
                req.eventName = 'LOCATE_PART';
                 List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjs = new List<SVMXC.INTF_WebServicesDef.SVMXMap>(); SVMXC.INTF_WebServicesDef.SVMXMap obj1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                 obj1.key = 'LATITUDE'; 
                 obj1.value = '12.972397';
                 SVMXC.INTF_WebServicesDef.SVMXMap obj2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                 obj2.key = 'LONGITUDE'; 
                 obj2.value = '77.596947';
                 //strProduct ='01tF0000004NIrX';
                 
                 lstObjs.add(obj1);
                 lstObjs.add(obj2);
                 
                 req.valueMap = lstObjs;
                 req.values = new list<string>();
                 req.values.add(prod1.id);
                 
                 system.debug('request = :' + req); resp = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req); 
                 system.debug('response = :' + resp);
                 try{
                     
                    SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp2 = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse(); SVMXC.INTF_WebServicesDef.INTF_SFMRequest req2 = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
                    req2.eventType = 'SYNC'; 
                    req2.eventName = 'LOCATE_PART';
                    req2.valueMap = null;
                    system.debug('request = :' + req2); 
                    resp2 = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req2); 
                 }
                 catch(exception e){}
                 
                 try{
                     
                    SVMXC.INTF_WebServicesDef.INTF_SFMResponse resp3 = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse(); SVMXC.INTF_WebServicesDef.INTF_SFMRequest req3 = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest(); 
                    req3.eventType = 'SYNC'; 
                    req3.eventName = 'LOCATE_PART';
                    List<SVMXC.INTF_WebServicesDef.SVMXMap> lstObjs3 = new List<SVMXC.INTF_WebServicesDef.SVMXMap>(); 
                    SVMXC.INTF_WebServicesDef.SVMXMap obj3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    obj3.key = 'LATITUDE'; 
                    obj3.value = '12.972397';
                    lstObjs3.add(obj3);
                    req3.valueMap = lstObjs3;
                    system.debug('request = :' + req3); 
                    resp3 = SVMXC.INTF_WebServicesDef.INTF_DataSync_WS(req3); 
                 }
                 catch(exception e){}
                  Test.StopTest();
                }
                
        }