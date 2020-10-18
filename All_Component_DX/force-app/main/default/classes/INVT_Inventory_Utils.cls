public class INVT_Inventory_Utils{
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse getStockTransferWrapper(INTF_WebServicesDef.INTF_SFMRequest prequest, String svmxProfileId){
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse stockTransferRes = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        
        SVMXC__Stock_Transfer__c stockTransferHeader = new SVMXC__Stock_Transfer__c();
        List<SVMXC__Stock_Transfer_Line__c> listStocktransferLine = new List<SVMXC__Stock_Transfer_Line__c>();
        
        Savepoint objSavepoint; 
        List<INTF_WebServicesDef.SVMXError> listError = new List<INTF_WebServicesDef.SVMXError>();
        String serialNumber = NULL;
        try{
            
            objSavepoint = Database.setSavepoint();
            if(prequest.valueMap != null && prequest.valueMap.size() > 0){
                for(INTF_WebServicesDef.SVMXMap keyValue: prequest.valueMap){
                    // Create Stock header
                    // Stock header should have both source and target location
                    if(keyValue.key.equalsIgnoreCase('STOCK_HEADER')){
                        if(keyValue.valueMap != null && keyValue.valueMap.size() > 0){
                            for(INTF_WebServicesDef.SVMXMap innerkeyValue: keyValue.valueMap){
                                if(innerkeyValue.key.equalsIgnoreCase('SOURCE')){
                                    stockTransferHeader.SVMXC__Source_Location__c = innerkeyValue.value; 
                                }

                                if(innerkeyValue.key.equalsIgnoreCase('TARGET')){
                                    stockTransferHeader.SVMXC__Destination_Location__c = innerkeyValue.value; 
                                }
                                
                                if(innerkeyValue.key.equalsIgnoreCase('INVENTORY_PROCESS')){
                                    stockTransferHeader.SVMXC__Additional_Information__c = innerkeyValue.value;
                                }  
                                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( stockTransferHeader, COMM_SecurityUtils.Access.Upsertable ) ) {
                                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    upsert stockTransferHeader;
                                } else {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                }
                                
                            }
                        }
                    }
                    String fieldToStoreSerialNumber = '';
                    String fieldToStoreProduct = '';
                    
                    system.debug( LoggingLevel.DEBUG, 'Profile ID' + svmxProfileId );
                    String profileName = '';
                    
                    if(svmxProfileId != null && svmxProfileId != ''){
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        profileName = [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Configuration_Type__c = 'Global' AND SVMXC__Active__c = true limit 1].SVMXC__Profile_Name__c;
                    }
                    if(stockTransferHeader != null && !String.isBlank(stockTransferHeader.SVMXC__Additional_Information__c)){
                         String serialNumberFieldConfig = stockTransferHeader.SVMXC__Additional_Information__c+ '_SET040'; 
                         String productFieldConfig = stockTransferHeader.SVMXC__Additional_Information__c+ '_SET026'; 
                         //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                         List<SVMXC__ServiceMax_Config_Data__c> invProcessData = [Select Id, SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c
                                                                             from SVMXC__ServiceMax_Config_Data__c
                                                                                 WHERE SVMXC__Config_Profile_Name__c  =: profileName AND ( SVMXC__Setting_Unique_ID__c =: serialNumberFieldConfig OR SVMXC__Setting_Unique_ID__c =: productFieldConfig) ];
                         if(invProcessData != null && invProcessData.size()> 0){
                             for(SVMXC__ServiceMax_Config_Data__c configRec : invProcessData){
                                 // Anchal - Uncommenting the code to fix BAC-3570 
                                 if(configRec.SVMXC__Setting_Unique_ID__c.equalsIgnoreCase(serialNumberFieldConfig)){
                                     fieldToStoreSerialNumber = configRec.SVMXC__Internal_Value__c; 
                                 }
                                 if(configRec.SVMXC__Setting_Unique_ID__c.equalsIgnoreCase(productFieldConfig)){
                                     fieldToStoreProduct = configRec.SVMXC__Internal_Value__c;
                                 }
                             }
                             
                         }
                         
                    }
                   
                    // Create Stock Lines
                    if(keyValue.key.equalsIgnoreCase('STOCK_LINE')){
                        if(keyValue.valueMap != null && keyValue.valueMap.size() > 0){
                            SObject stockTransferLine = new SVMXC__Stock_Transfer_Line__c();
                            for(INTF_WebServicesDef.SVMXMap innerkeyValueLine: keyValue.valueMap){
                                if(innerkeyValueLine.key.equalsIgnoreCase('PART')){
                                    stockTransferLine.put(fieldToStoreProduct,innerkeyValueLine.value);
                                }

                                if(innerkeyValueLine.key.equalsIgnoreCase('QUANTITY')){
                                    stockTransferLine.put('SVMXC__Quantity_Transferred2__c',Decimal.valueof(innerkeyValueLine.value));
                                }
                                
                                
                                if(innerkeyValueLine.key.equalsIgnoreCase('SERIAL_NUMBERS')){
                                    serialNumber = innerkeyValueLine.value;
                                    if(!String.isBlank(serialNumber)){
                                        List<String> listSerialNumber = serialNumber.split(',');
                                        for(String sn: listSerialNumber){
                                            SObject serialStockTransferLine = stockTransferLine.clone();
                                            serialStockTransferLine.put(fieldToStoreSerialNumber, sn);
                                            serialStockTransferLine.put('SVMXC__Stock_Transfer__c',stockTransferHeader.id); 
                                            listStocktransferLine.add((SVMXC__Stock_Transfer_Line__c)serialStockTransferLine);
                                        }
                                    }
                                    else{
                                        stockTransferLine.put('SVMXC__Stock_Transfer__c',stockTransferHeader.id);
                                        listStocktransferLine.add((SVMXC__Stock_Transfer_Line__c)stockTransferLine);
                                    }
                                } 
                            }
                        }
                    }
                    
                    system.debug( LoggingLevel.DEBUG, listStocktransferLine);
                    system.debug( LoggingLevel.DEBUG, stockTransferHeader);
                    if(listStocktransferLine != null && listStocktransferLine.size() > 0){
                        if(!listStocktransferLine.isEmpty() && COMM_SecurityUtils.getInstance().verifyFieldAccess( listStocktransferLine, COMM_SecurityUtils.Access.Upsertable ) ) {
                            //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert listStocktransferLine;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        stockTransferRes.success = true;
                    }
                    
                }

                // Validate the Stock header and transfer lines
                    
                    INVT_WrapperDef.INVT_Response invtResponse = new INVT_WrapperDef.INVT_Response();
                    List<SVMXC.INVT_WrapperDef.INVT_StringMap> lstStringMap = new List<SVMXC.INVT_WrapperDef.INVT_StringMap>();
                    SVMXC.INVT_WrapperDef.INVT_StringMap headerRecordIdStringMap = new SVMXC.INVT_WrapperDef.INVT_StringMap('SVMX_HearderId',stockTransferHeader.id);
                    lstStringMap.add(headerRecordIdStringMap);
                    
                    SVMXC.INVT_WrapperDef.INVT_StringMap inventoryProcessIdStringMap = new SVMXC.INVT_WrapperDef.INVT_StringMap('SVMX_InventoryProcessId',stockTransferHeader.SVMXC__Additional_Information__c); 
                    lstStringMap.add(inventoryProcessIdStringMap);
                    
                    SVMXC.INVT_WrapperDef.INVT_Request invtRequest = new SVMXC.INVT_WrapperDef.INVT_Request();
                    invtRequest.listOfStringMap = lstStringMap;
                    
                    INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
                    invtResponse = objInventoryAPIEngine.processINVTRequest(invtRequest);
                    system.debug( LoggingLevel.WARN,'invtResponse'+invtResponse);
                    
                    
                    if(invtResponse.getSuccess()){
                        stockTransferRes.success = true;
                        if(serialNumber != NULL){
                            INTF_WebServicesDef.SVMXMap serialNumberSVMXMap= new INTF_WebServicesDef.SVMXMap();
                            serialNumberSVMXMap.key = 'SERIAL_NUMBERS';
                            serialNumberSVMXMap.value = serialNumber; 
                            stockTransferRes.valueMap.add(serialNumberSVMXMap);
                        }
                    }
                    else{
                        Database.rollback(objSavepoint);
                        stockTransferRes.success = invtResponse.getSuccess();
                        String strMessage = JSON.serialize(invtResponse.getListOfMessage());
                        
                        INTF_WebServicesDef.SVMXError errorLog = new INTF_WebServicesDef.SVMXError();
                        errorLog.errorMsg = strMessage;
                        listError.add(errorLog);
                        stockTransferRes.errors = listError;
                        //stockTransferRes.messages = (list<SFM_WrapperDef.SVMXMessage>)JSON.deserialize(strMessage, list<SFM_WrapperDef.SVMXMessage>.class);
                    } 
            }
        }
        catch(Exception e){
            Database.rollback(objSavepoint);
            stockTransferRes.success= false; 
            
            INTF_WebServicesDef.SVMXError errorLog = new INTF_WebServicesDef.SVMXError();
            errorLog.errorMsg = e.getMessage();

            listError.add(errorLog);
            stockTransferRes.errors = listError;

        }
        
        stockTransferRes.eventType = prequest.eventType;
        stockTransferRes.eventName = prequest.eventName;
        
        return stockTransferRes;
    }

    public class TechnicianProductStock
    {
        SVMXC__Service_Group_Members__c technician;
        list<SVMXC__Product_Stock__c> lstProductStck ;
        list<SVMXC__Product_Serial__c> lstStockSerial;
        double distance;
        //String unit;
        public TechnicianProductStock(){}
        
    }
    
    public class WareHouseProductStock
    {
        SVMXC__Site__c location;
        list<SVMXC__Product_Stock__c> lstProductStck;
        list<SVMXC__Product_Serial__c> lstStockSerial;
        double distance;
        //String unit;
        public WareHouseProductStock(){}
    }
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse locatePart(INTF_WebServicesDef.INTF_SFMRequest locatePartrequest, string profileId)
    {
        
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse  locatePartRes = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse(); 
        double dblRadius ;
        double dblLatitude ;
        double dblLongitude ;   
        string distanceUnit;
        string strProduct;
        integer noOfrecordcanbequeried = limits.getLimitQueryRows();
        list<string> lstLocType =  new list<string>();
        list<string> lstLocid =  new list<string>();
        boolean success = false;
        INVT_SpareParts_Wrapper.SpareParts_Request  invtConfig ;
        list<SVMXC__SM_Inventory_Config__c> lstInvConfig = new list<SVMXC__SM_Inventory_Config__c>();
        list<TechnicianProductStock> lstTechProdStock = new list<TechnicianProductStock>();
        list<WareHouseProductStock> lstWareHouseProdStock = new list<WareHouseProductStock>();
        
        //Retrieving Inventory Configuration for the given profile. 
        try
        {
            system.debug( LoggingLevel.DEBUG, 'profileId: '+profileId);
            if(profileId != null && profileId != '')
            {
                List<String> queryFieldsInventory_Config = new List<String> {'SVMXC__SM_Content__c', 'SVMXC__SM_ServiceMax_Profile__c'};


                if( ! Test.isRunningTest() &&  ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Inventory_Config__c', queryFieldsInventory_Config, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                lstInvConfig = [Select SVMXC__SM_Content__c from SVMXC__SM_Inventory_Config__c where SVMXC__SM_ServiceMax_Profile__c = : profileId ];
            }
            system.debug( LoggingLevel.DEBUG, 'lstInvConfig: '+lstInvConfig);
            
            //Get the radius value,locationtype and unit for the given profile
            if(lstInvConfig != null && !lstInvConfig.isEmpty() && ! String.isBlank(lstInvConfig.get(0).SVMXC__SM_Content__c))
                invtConfig = (INVT_SpareParts_Wrapper.SpareParts_Request  ) JSON.deserialize (lstInvConfig.get(0).SVMXC__SM_Content__c, INVT_SpareParts_Wrapper.SpareParts_Request .Class);
            system.debug( LoggingLevel.DEBUG, 'invtConfig: '+invtConfig);
            
            if(invtConfig != null && invtConfig.locatepartsetup != null && !String.isBlank(invtConfig.locatepartsetup.radius))
                dblRadius = double.valueof(invtConfig.locatepartsetup.radius);
            
            
            system.debug( LoggingLevel.DEBUG, 'dblRadius: '+dblRadius);
            
            if(invtConfig != null && invtConfig.locatepartsetup != null && !invtConfig.locatepartsetup.locationtype.isEmpty())
                lstLocType = invtConfig.locatepartsetup.locationtype;
            
            
            system.debug( LoggingLevel.DEBUG, 'lstLocType: '+lstLocType);
            
            if(invtConfig != null && invtConfig.locatepartsetup != null && invtConfig.locatepartsetup.Distanceinunit != null && invtConfig.locatepartsetup.Distanceinunit != '')
                distanceUnit = invtConfig.locatepartsetup.Distanceinunit;
            
                
            system.debug( LoggingLevel.DEBUG, 'distanceUnit: '+distanceUnit);
            
            //Given Product
            
            if(locatePartrequest != null && locatePartrequest.values != null && locatePartrequest.values.size()>0)
                strProduct = locatePartrequest.values.get(0);
           
            
            system.debug( LoggingLevel.DEBUG, 'strProduct: '+strProduct);
            
            //Given lat/long
            if(locatePartrequest != null && locatePartrequest.valueMap != null)
            {
                for(INTF_WebServicesDef.SVMXMap objMap:locatePartrequest.valueMap)
                {
                    if(!String.isBlank(objMap.key) && objMap.key.equalsIgnoreCase('LATITUDE') && !String.isBlank(objMap.value))
                        dblLatitude = double.valueOf(objMap.value);
                    
                    if(!String.isBlank(objMap.key) && objMap.key.equalsIgnoreCase('LONGITUDE') && !String.isBlank(objMap.value))
                        dblLongitude = double.valueOf(objMap.value);
                    
                }
                if(dblRadius != null && ! String.isBlank(strProduct) && dblLongitude != null && dblLatitude != null)
                    success = true;
                
            }
            
            else 
                success = false;
            system.debug( LoggingLevel.DEBUG, 'dblLatitude: '+dblLatitude);
            system.debug( LoggingLevel.DEBUG, 'dblLongitude: '+dblLongitude);
            system.debug( LoggingLevel.DEBUG, 'success: '+success);
            
            //If all the required information is available, proceeding with locating technicain and Warehouse
            if(success == true)
            {
               
                
                noOfrecordcanbequeried = noOfrecordcanbequeried - limits.getQueryRows();
                system.debug( LoggingLevel.DEBUG, 'noOfrecordcanbequeried: '+noOfrecordcanbequeried);
                
                //Retrieving all technician having current lat/long values and inventory location
                 map<id,SVMXC__Service_Group_Members__c>   mapTech = new map<id,SVMXC__Service_Group_Members__c>();
                if(noOfrecordcanbequeried > 0)
                {
                    
                    List<String> queryTechFields;
                    if(! Test.isRunningTest() && ConnectApi.Organization.getSettings().features.chatter ) 
                    {
                        queryTechFields  = new List<String> {'id','Name','SVMXC__Inventory_Location__c','SVMXC__Latitude__c','SVMXC__Longitude__c','SVMXC__Service_Group__r.Name','SVMXC__Service_Territory__r.Name','SVMXC__Phone__c','SVMXC__Salesforce_User__r.FullPhotoUrl','SVMXC__Salesforce_User__r.SmallPhotoUrl','SVMXC__Latlong_Captured_On__c','SVMXC__Active__c','SVMXC__City__c','SVMXC__Country__c','SVMXC__Street__c','SVMXC__State__c','SVMXC__Zip__c','SVMXC__Salesforce_User__c'};
                    }
                    else
                        queryTechFields  = new List<String> {'id','Name','SVMXC__Inventory_Location__c','SVMXC__Latitude__c','SVMXC__Longitude__c','SVMXC__Service_Group__r.Name','SVMXC__Service_Territory__r.Name','SVMXC__Phone__c','SVMXC__Latlong_Captured_On__c','SVMXC__Active__c','SVMXC__City__c','SVMXC__Country__c','SVMXC__Street__c','SVMXC__State__c','SVMXC__Zip__c','SVMXC__Salesforce_User__c'};
                
                    
                    
                    if( ! Test.isRunningTest() &&  ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Group_Members__c', queryTechFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
                    String strquery = utils.SVMX_getFieldNamesFromList(queryTechFields); 
                    
                    //strquery = 'Select '+ strquery + ' from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Inventory_Location__c != null and SVMXC__Latitude__c != null and SVMXC__Longitude__c != null and SVMXC__Salesforce_User__c !=:userId limit: noOfrecordcanbequeried';
                    strquery = 'Select '+ strquery + ' from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Inventory_Location__c != null and SVMXC__Latitude__c != null and SVMXC__Longitude__c != null limit: noOfrecordcanbequeried';
                    
                    mapTech.putAll((List<SVMXC__Service_Group_Members__c>)Database.query(strquery));
                }
               
                map<id,id> mapLocTechWithinRadius = new map<id,id>();
                system.debug( LoggingLevel.DEBUG, 'mapTech: '+mapTech.size()+'Tech Id: '+mapTech.keyset());
                map<id,double> mapTechWithDistance =  new map<id,double>() ; 
                map<String, String> mapLocTechOutsideRadius = new Map<string,String>();
                String curTechInvLocId = NULL;
                String userId = Userinfo.getUserId();
                
                //Finding all the technicain who are within the given radius 
                Datetime dtEightHours = system.now().addHours(-8);  //Ensure tech's latLong_Captured_On is within the last 8 hours
                
                if(!mapTech.isEmpty())
                {
                    for(SVMXC__Service_Group_Members__c tech:mapTech.values())
                    {
                        if(tech.SVMXC__Salesforce_User__c != userId){
                            double dist = getDistanceBetween(dblLatitude,dblLongitude,Double.ValueOf(tech.SVMXC__Latitude__c),Double.ValueOf(tech.SVMXC__Longitude__c),distanceUnit);
                            if(dist <= dblRadius && (tech.SVMXC__Latlong_Captured_On__c != NULL && tech.SVMXC__Latlong_Captured_On__c >= dtEightHours) )
                            {
                                mapTechWithDistance.put(tech.id,dist);
                                mapLocTechWithinRadius.put(tech.SVMXC__Inventory_Location__c,tech.id);
                                lstLocid.add(tech.SVMXC__Inventory_Location__c);
                            }else{
                                //technician's lat long wasn't updated recently
                                mapLocTechOutsideRadius.put(tech.SVMXC__Inventory_Location__c,tech.id);
                            }
                        }else{
                            curTechInvLocId = tech.SVMXC__Inventory_Location__c;
                        }
                    }
                
                }
                system.debug( LoggingLevel.DEBUG, 'mapTechWithDistance: '+mapTechWithDistance);
                system.debug( LoggingLevel.DEBUG, 'mapLocTechWithinRadius: '+mapLocTechWithinRadius);
                map<id,SVMXC__Site__c> mapLocation = new map<id,SVMXC__Site__c>();
                
                
                noOfrecordcanbequeried = noOfrecordcanbequeried - limits.getQueryRows();
                system.debug( LoggingLevel.DEBUG, 'noOfrecordcanbequeried: '+noOfrecordcanbequeried);
                
                
                //Getting all the location having lat/long values and SVMXC__Location_Type__c in lstLocType
                if(noOfrecordcanbequeried>0)
                {
                    List<String> queryLocFields = new List<String> {'id','Name','SVMXC__Latitude__c','SVMXC__Longitude__c',' SVMXC__Site_Phone__c', 'SVMXC__Location_Type__c','SVMXC__Street__c','SVMXC__State__c','SVMXC__Country__c','SVMXC__City__c'};

                    if( ! Test.isRunningTest() &&  ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryLocFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    mapLocation = new map<id,SVMXC__Site__c>([Select id,Name,SVMXC__Latitude__c,SVMXC__Longitude__c, SVMXC__Site_Phone__c from SVMXC__Site__c where SVMXC__Latitude__c != null and SVMXC__Longitude__c!= null and SVMXC__Location_Type__c in:lstLocType limit: noOfrecordcanbequeried]); 
                }
                
                system.debug( LoggingLevel.DEBUG, 'mapLocation: '+mapLocation.size()+'Location Id: '+mapLocation.keyset());
                
                map<id,double> mapLocWithDistance =  new map<id,double>() ; 
                
                //Finding all the location within the given radius
                if(!mapLocation.isEmpty())
                {
                    for(SVMXC__Site__c loc:mapLocation.values())
                    {
                    
                        double dist = getDistanceBetween(dblLatitude,dblLongitude,Double.ValueOf(loc.SVMXC__Latitude__c),Double.ValueOf(loc.SVMXC__Longitude__c),distanceUnit);
                        system.debug( LoggingLevel.DEBUG, 'Locid: '+loc.id+ '   ' +dist);
                        if(dist <= dblRadius)
                        {
                            mapLocWithDistance.put(loc.id,dist);
                            lstLocid.add(loc.id);
                             
                        }
                        
                    }
                }
                system.debug( LoggingLevel.DEBUG, 'mapLocWithDistance: '+mapLocWithDistance.size()+'Location Id: '+mapLocWithDistance.keyset());
                system.debug( LoggingLevel.DEBUG, 'mapLocWithDistance: '+mapLocWithDistance);
                system.debug( LoggingLevel.DEBUG, 'lstLocid: '+lstLocid);
                
                noOfrecordcanbequeried = noOfrecordcanbequeried - limits.getQueryRows();
                system.debug( LoggingLevel.DEBUG, 'noOfrecordcanbequeried: '+noOfrecordcanbequeried);
                
                list<SVMXC__Product_Stock__c> lstProductStock = new list<SVMXC__Product_Stock__c>();
                //Retrieving product stock for all technicainand location within the given radius
                if(noOfrecordcanbequeried > 0)
                {
                    List<String> queryProdStkFields = new List<String> {'id','SVMXC__Location__c',' SVMXC__Quantity2__c ',' SVMXC__Status__c','SVMXC__Product__c'};


                    if( ! Test.isRunningTest() &&  ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryProdStkFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    List<String> queryStckSerialFields = new List<String> {'id','Name'};


                    if( ! Test.isRunningTest() &&  ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Serial__C', queryStckSerialFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    lstProductStock = [select id, SVMXC__Location__c, SVMXC__Quantity2__c , SVMXC__Status__c,(select id, Name from SVMXC__Product_Serial__r where SVMXC__Active__c = true) from SVMXC__Product_Stock__c where  SVMXC__Product__c = :strProduct and SVMXC__Status__c ='Available' and SVMXC__Location__c != null and SVMXC__Location__c in:lstLocid limit: noOfrecordcanbequeried];
                
                }
                
                system.debug( LoggingLevel.DEBUG, 'lstProductStock: '+lstProductStock);
                
                for(SVMXC__Product_Stock__c prodStck: lstProductStock)
                {
                    system.debug( LoggingLevel.DEBUG, 'prodStck SVMXC__Location__c: '+prodStck.SVMXC__Location__c); 
                    system.debug( LoggingLevel.DEBUG, 'mapLocTechWithinRadius location : '+mapLocTechWithinRadius.containskey(prodStck.SVMXC__Location__c)); 
                    system.debug( LoggingLevel.DEBUG, 'mapLocWithDistance location : '+mapLocWithDistance.containskey(prodStck.SVMXC__Location__c)); 
                    
                    //If the product stock belongs to Technician, adding it to technician wrapper
                    if(!mapLocTechWithinRadius.isEmpty() && mapLocTechWithinRadius.containsKey(prodStck.SVMXC__Location__c))
                    {
                        TechnicianProductStock techProdStck = new TechnicianProductStock();
                        techProdStck.lstProductStck = new list<SVMXC__Product_Stock__c>();
                        techProdStck.lstStockSerial = new list<SVMXC__Product_Serial__C>();
                        if(!mapTech.isEmpty() && mapTech.containskey(mapLocTechWithinRadius.get(prodStck.SVMXC__Location__c)))
                        {
                            
                            techProdStck.technician = mapTech.get(mapLocTechWithinRadius.get(prodStck.SVMXC__Location__c));
                            if(!mapTechWithDistance.isEmpty() && mapTechWithDistance.containsKey(mapTech.get(mapLocTechWithinRadius.get(prodStck.SVMXC__Location__c)).id))
                            techProdStck.distance = mapTechWithDistance.get(mapTech.get(mapLocTechWithinRadius.get(prodStck.SVMXC__Location__c)).id);
                            system.debug( LoggingLevel.DEBUG, 'Tech name: '+mapTech.get(mapLocTechWithinRadius.get(prodStck.SVMXC__Location__c)).get('Name'));
                                                    
                        }                           
                        techProdStck.lstProductStck.add(prodStck);
                        if(prodStck.SVMXC__Product_Serial__r != null && prodStck.SVMXC__Product_Serial__r.size()>0)
                            techProdStck.lstStockSerial.addAll(prodStck.SVMXC__Product_Serial__r);
                        lstTechProdStock.add(techProdStck);
                        
                    system.debug( LoggingLevel.DEBUG, 'Tech : '+mapLocTechWithinRadius.get(prodStck.SVMXC__Location__c));
                    system.debug( LoggingLevel.DEBUG, 'prodStck : '+prodStck.id);
                    system.debug( LoggingLevel.DEBUG, 'techProdStck : '+techProdStck);
                    }
                    //If the product stock belongs to Warehouse, adding it to Warehouse wrapper
                    else if(!mapLocWithDistance.isEmpty() &&  mapLocWithDistance.containsKey(prodStck.SVMXC__Location__c) && !mapLocTechOutsideRadius.containsKey(prodStck.SVMXC__Location__c) && prodStck.SVMXC__Location__c != curTechInvLocId)                    
                    {
                        
                        WareHouseProductStock wareHouseProdStock = new WareHouseProductStock();
                        wareHouseProdStock.location = mapLocation.get(prodStck.SVMXC__Location__c);
                        wareHouseProdStock.lstProductStck = new list<SVMXC__Product_Stock__c>();
                        wareHouseProdStock.lstStockSerial = new list<SVMXC__Product_Serial__C>();
                        wareHouseProdStock.lstProductStck.add(prodStck);
                        if(!mapLocWithDistance.isEmpty() && mapLocWithDistance.containsKey(prodStck.SVMXC__Location__c))
                        wareHouseProdStock.distance = mapLocWithDistance.get(prodStck.SVMXC__Location__c);

                        if(prodStck.SVMXC__Product_Serial__r != null && prodStck.SVMXC__Product_Serial__r.size()>0)
                            wareHouseProdStock.lstStockSerial.addAll(prodStck.SVMXC__Product_Serial__r);
                        lstWareHouseProdStock.add(wareHouseProdStock);
                        system.debug( LoggingLevel.DEBUG, 'wareHouseProdStock : '+wareHouseProdStock);
                    }
                    
                }
                
                //Building the response
                INTF_WebServicesDef.SVMXMap UnitSVMXMap= new INTF_WebServicesDef.SVMXMap();
                UnitSVMXMap.key = 'Unit'; 
                UnitSVMXMap.value = distanceUnit;//Unit used to compute the distance
                
                INTF_WebServicesDef.SVMXMap techSVMXMap= new INTF_WebServicesDef.SVMXMap();
                techSVMXMap.key = 'Technician';
                techSVMXMap.value = JSON.serialize(lstTechProdStock);
                
                
                INTF_WebServicesDef.SVMXMap warehouseSVMXMap= new INTF_WebServicesDef.SVMXMap();
                warehouseSVMXMap.key = 'Warehouse';
                warehouseSVMXMap.value = JSON.serialize(lstWareHouseProdStock);     
                
                locatePartRes.valueMap.add(techSVMXMap);
                locatePartRes.valueMap.add(UnitSVMXMap);
                locatePartRes.valueMap.add(warehouseSVMXMap);
                success = true;
                locatePartRes.success = success;
                system.debug( LoggingLevel.DEBUG, 'locatePartRes: '+locatePartRes);
            }
            else
            {
                //Insufficient information to locate  part
                List<INTF_WebServicesDef.SVMXError> listError = new List<INTF_WebServicesDef.SVMXError>();
                INTF_WebServicesDef.SVMXError insufficientParameter = new INTF_WebServicesDef.SVMXError();
                insufficientParameter.errorMsg = system.label.COMM001_TAG084;
                system.debug( LoggingLevel.DEBUG, 'err msg: '+insufficientParameter.errorMsg);
                if(insufficientParameter != null && insufficientParameter.errorMsg != null && insufficientParameter.errorMsg != '')
                {                    
                    listError.add(insufficientParameter);
                    locatePartRes.errors = listError;
                }               
            }
        }
        catch(Exception e)
        {
            locatePartRes.success = false; 
            List<INTF_WebServicesDef.SVMXError> listError = new List<INTF_WebServicesDef.SVMXError>();
            
            
            INTF_WebServicesDef.SVMXError errorLog = new INTF_WebServicesDef.SVMXError();
            errorLog.errorMsg = e.getMessage();
            listError.add(errorLog);
            system.debug( LoggingLevel.DEBUG, 'Exception : '+errorLog.errorMsg);
            system.debug( LoggingLevel.DEBUG, 'getStackTraceString : '+e.getStackTraceString());
            
        
            locatePartRes.errors = listError;
            

        }
        return locatePartRes ;
    }
    private double getDistanceBetween(double lat1, double lon1, double lat2, double lon2, string Unit)
    {
        //Geolocation
        Location loc1 = Location.newInstance(lat1,lon1);
        Location loc2 = Location.newInstance(lat2,lon2);
        Double dist;
        //Finding distance between 2 geolocation
        if(Unit.equalsIgnoreCase('KILOMETER'))
            dist = Location.getDistance(loc1, loc2, 'km');
        else    
            dist = Location.getDistance(loc1, loc2, 'mi');

        
        system.debug( LoggingLevel.DEBUG, 'dist:'+ dist);
        return dist;
        
         
    }
    
}