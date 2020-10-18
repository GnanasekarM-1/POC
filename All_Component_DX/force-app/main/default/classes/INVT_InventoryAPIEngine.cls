/* Security Scanned */
public with sharing class INVT_InventoryAPIEngine {
    
    // For performance statistics 
    private static final String[] EMAIL_RECIPIENTS = new String[] { 'amar.joshi@servicemax.com','ramachandra.mohan@servicemax.com' };    
    public static String emailBody = '';
                                                    
    private static final Boolean ENABLE_PERFORMANCE_STATISTICS = false; 
    private static Long inventoryProcessStartTime;
    
    private String strHeaderRecordId = null;//idHeader
    private String strInvtProcessId = null;
    private List<String> lstLineIds = null;//lstIdsLine
    private Map<String, Map<String, String>> recordTypeMap; //RTypeMap      
    private List<SObject> lineRecordList; // xRecs  
    private List<Product2> lstProduct = new List<Product2>(); // product2List
    private List<INVT_TransactionRecord> invtTransactionRecordList; //xLines
    private List<INVT_TransactionRecord> lstINVT_TransactionRecord = new List<INVT_TransactionRecord>();
    private Map<Id, Product2> mapValidProdRecs = new Map<Id, Product2>();
    private Map<Id, Product2> mapValidSerializedProdcts = new Map<Id, Product2>();
    private Map<String, String> mapToLocation = new Map<String, String>();//mToLocation
    private Map<String, String> mapFromLocation = new Map<String, String>();//mFromLocation
    private SVMXC__ServiceMax_Processes__c objInventoryProcess;
        //for update
    private Boolean isInventoryEnabled = true;
    private Boolean isLocationInvolved = true;
    private Boolean isAllowWarining = false;
    private boolean isErrorAdded = false;
    private boolean isRollBack = false;
    private Map<String, List<String>> mapSerialSuffix = new Map<String, List<string>>();
    private Map<String, SVMXC__Product_Stock__c> mapUniqueKeySourcePS = new Map<String, SVMXC__Product_Stock__c>();
    private Map<String, SVMXC__Product_Stock__c> mapUniqueKeyTargetPS = new Map<String, SVMXC__Product_Stock__c>();
    private Map<String, SVMXC__Product_Stock__c> mapUniqueKeyDecreasedSourcePS = new Map<String, SVMXC__Product_Stock__c>();
    private set<Id> setSourcePSId = new set<Id>();
    private map<String, list<String>> mapProductIdSerialNoProductStockName = new map<String, list<String>>();
    
    private INVT_ConfigurationRecord invtConfigurationRecord;  
    private set<Id> setProductId = new set<Id>();
    private set<Id> setFromLocationId = new set<Id>();
    private set<Id> setToLocationId = new set<Id>();
    private Map<Id, Map<String, SVMXC__Product_Serial__c>> mapTranscationRecIdSourcePSSerialNumber = new Map<Id,Map<String, SVMXC__Product_Serial__c>>();
    private Map<Id, Map<String, SVMXC__Product_Serial__c>> mapTranscationRecordToSerial = new Map<Id,Map<String, SVMXC__Product_Serial__c>>();    
    private Map<Id, Map<String, SVMXC__Product_Serial__c>> mapTranscationRecIdRemovedPSSerialNumber = new Map<Id,Map<String, SVMXC__Product_Serial__c>>();
    
    private Map<String, List<String>> serialNumberToIndexListMap = new Map<String, List<String>>();
    
    private map<string, string> mapSerialNumberProductId = new map<string, string>();
    private Schema.SObjectType schemaTypeProductStock;
    private sobject sobjFL, sobjTL;
    private double adjusetedQty = 0;
    private String strNotifyUser;
    private List<SVMXC__Product_Stock__c> lstSourceProductStock = new List<SVMXC__Product_Stock__c>();
    List<SVMXC__Product_Stock__c> lstTargetProductStock = new List<SVMXC__Product_Stock__c>();
    private String strLineSOQL = '';
    private SObject headerRecord;
    private boolean isUpdateSuccess = true;
    private List<SVMXC__Product_Serial__c> lstToCreateSerialNumbers = new List<SVMXC__Product_Serial__c>();
    private COMM_SVMXC_Utils3 objTags = new COMM_SVMXC_Utils3(true); 
    private COMM_SVMXC_Utils3 oCommUtils = new COMM_SVMXC_Utils3( true );   
    private Map<String, SVMXC__ServiceMax_Config_Data__c> settingObjectMap;
    private List<INVT_WrapperDef.SVMXMessage> svmxMessageList = new List<INVT_WrapperDef.SVMXMessage>();   
    private boolean isSerialError = false;
    private boolean isSerialWarning = false;
    private map<string, list<INVT_TransactionRecord>> mapMailList = new map<string, list<INVT_TransactionRecord>>();
    private boolean isNagetiveWarn = false;
    List<SVMXC__Product_Stock__c> lstNewSourceProductStock = new List<SVMXC__Product_Stock__c>();
    List<SVMXC__Product_Stock__c> lstNewSourceProductStockDecreased = new List<SVMXC__Product_Stock__c>();
    List<SVMXC__Product_Stock__c> lstNewTargetProductStock = new List<SVMXC__Product_Stock__c>();
    List<SVMXC__Product_Stock__c> lstSourceProductStockDecreased = new List<SVMXC__Product_Stock__c>();
    
    map<String,SVMXC__Product_Stock__c> mapUniqueKeySourceProductDecreased = new map<String,SVMXC__Product_Stock__c>();
    map<Id,INVT_TransactionRecord> mapTransactionRecordIdTransactionRecord = new map<Id,INVT_TransactionRecord>();  
    private map<id, SVMXC__Product_Stock__c> mapTransactionRecordToNegativeProductStock = new map<id, SVMXC__Product_Stock__c>();   
    private map<id, Double> mapNegativeProductStockToBeforeQuantity = new map<id, Double>();    
    private Savepoint sp2;
    
    private String strHeaderObjectName;
    private String strHeaderObjectNameFieldValue;
    
    private static final String NEWLINE = '\n';
    
    private Map<Id,List<String>> idResultListMap;
    
    public void setSettingObjectMap( Map<String, SVMXC__ServiceMax_Config_Data__c> settingObjectMap ) {
        this.settingObjectMap = settingObjectMap;
    }
    
    public Map<Id, Product2> getProduct2Map() {
        return mapValidProdRecs;    
    }
    
    public Map<Id, Product2> getSerializedProduct2Map() {
        return mapValidSerializedProdcts;   
    }    
    
    public List<INVT_TransactionRecord> getINVTTransactionRecordList() {
        return lstINVT_TransactionRecord;
    }
    
    public void setLineRecordQueryString( String strLineSOQL ) {
        this.strLineSOQL = strLineSOQL;   
    }
    
    public void setHeaderRecord( SObject headerRecord ) {
        this.headerRecord = headerRecord;
    }
    
    public void setConfigurationRecord( INVT_ConfigurationRecord invtConfigurationRecord ) {
        this.invtConfigurationRecord = invtConfigurationRecord;
    }
    
    public SVMXC__ServiceMax_Processes__c getObjInventoryProcess() {
        return objInventoryProcess;
    }
    
    public void setObjInventoryProcess(SVMXC__ServiceMax_Processes__c objInventoryProcess) {
        this.objInventoryProcess = objInventoryProcess;
    }
    
    
    public Map<String, String> getToLocationMap() {
        return mapToLocation;
    }
    
    public Map<String, String> getFromLocationMap() {
        return mapFromLocation;
    }
    
    public void setInventoryEnabled( Boolean enabled ) {
        this.isInventoryEnabled = enabled;
    }
    
    public Boolean isInventoryEnabled() {
        return isInventoryEnabled;  
    }
    
    public void setLocationInvolved( Boolean enabled ) {
        this.isLocationInvolved = enabled;
    }
    
    public Boolean isLocationInvolved() {
        return isLocationInvolved;  
    }
    
    public Map<String, Map<String, String>> getRecordTypeMap() {
        return recordTypeMap;
    }
    
    public void setRecordTypeMap( Map<String, Map<String, String>> recordTypeMap ) {
        this.recordTypeMap = recordTypeMap;
    }
    
    public List<Product2> getProduct2List() {
        return lstProduct;
    }
    
    public void setLineRecordList( List<SObject> lineRecordList ) {
        this.lineRecordList = lineRecordList;
    }
    
    public void setInvtTransactionRecordList( List<INVT_TransactionRecord> invtTransactionRecordList ) {
        this.invtTransactionRecordList = invtTransactionRecordList;
    }
    
    public List<SObject> getLineRecordList() {
        return lineRecordList;
    }
    
    public INVT_WrapperDef.INVT_Response processINVTRequest(INVT_WrapperDef.INVT_Request svmxRequest) {
    
//        if(ENABLE_PERFORMANCE_STATISTICS) initPerformanceReport();
        
        System.debug( LoggingLevel.DEBUG, 'processINVTRequest() - enter: '+svmxRequest );
        
        final List<INVT_WrapperDef.INVT_StringListMap> lstStringListMap = svmxRequest.listOfStringlistMap;
        final List<INVT_WrapperDef.INVT_StringMap> lstStringMap = svmxRequest.listOfStringMap;
        INVT_WrapperDef.INVT_Response invtResponse = new INVT_WrapperDef.INVT_Response();
        Boolean isInventoryProcessed = false;
        if(lstStringMap != null && !lstStringMap.isEmpty()) 
        {
            
            for(INVT_WrapperDef.INVT_StringMap objStringMap : lstStringMap) {
                
                if( objStringMap.value != null) {
                
                    if(objStringMap.key == INVT_Consts.SVMX_HEADERID_STRING) strHeaderRecordId = objStringMap.value;
                        
                    if(objStringMap.key == INVT_Consts.SVMX_INVETORYID_STRING) strInvtProcessId = objStringMap.value;
                        
                    if( objStringMap.key == INVT_Consts.SVMX_ALLOW_WARNING_STRING ) isAllowWarining = Boolean.valueOf( objStringMap.value );
                                            
                    if(lstStringListMap != null && !lstStringListMap.isEmpty()) {
                            
                        for(INVT_WrapperDef.INVT_StringListMap objStringListMap : lstStringListMap) {
                            if( objStringListMap.key == INVT_Consts.SVMX_LINEIDS_STRING ) {
                                lstLineIds = objStringListMap.valueList;
                            }
                        }
                    }                    
                } else {
                    
                    addError( oCommUtils.getTAG039() );
                    invtResponse.listOfMessage = svmxMessageList;
                    invtResponse.success = false;
                    return invtResponse;
                }
            }
        } else {
                        
            addError( oCommUtils.getTAG039() );
            invtResponse.listOfMessage = svmxMessageList;
            invtResponse.success = false;
            return invtResponse;
        }
        
        // onload validation 
        sp2 = Database.setSavepoint();
        
        INVT_ValidationEngine invt_ValidationEngine = new INVT_ValidationEngine(this);
        svmxMessageList = invt_ValidationEngine.onLoadValidation(strHeaderRecordId, strInvtProcessId, lstLineIds);
        idResultListMap = invt_ValidationEngine.getRecordStatusMap();
              
        if( svmxMessageList.isEmpty() && lineRecordList !=null && !lineRecordList.isEmpty() ) {
            
            schemaTypeProductStock = Schema.Sobjecttype.SVMXC__Product_Stock__c.getSobjectType();  
        
            if( schemaTypeProductStock == null ) { 
                this.isInventoryEnabled = false; 
            }
        
            if( invt_ValidationEngine.isProcessComplete() ) {
                
                if( isInventoryEnabled && isLocationInvolved ) {
                  
                    buildFromSerialNumber();
                    buildToSerialNumber();                  
                }                
                doInventoryUpdate();   
                isInventoryProcessed = true;     
            } else {
                addError(objTags.getTAG038());
            }        
        }
                
        if( idResultListMap != null && !idResultListMap.isEmpty() ) {
            invtResponse.validationSuccess = false;                     
        }
         
        if( !svmxMessageList.isEmpty() ) {
            
            invtResponse.listOfMessage = svmxMessageList;            
            invtResponse.success = false;            
        } else {
            if(isInventoryProcessed){
                INVT_WrapperDef.SVMXMessage objMessage = new INVT_WrapperDef.SVMXMessage(system.label.INVT001_TAG067, '', 'INFO');
                svmxMessageList.add(objMessage);
            }   
            if( invtResponse.validationSuccess )
                updateResultMap(system.label.INVT001_TAG067);
            invtResponse.listOfMessage = svmxMessageList;
            invtResponse.success = true;
        }

        System.debug( LoggingLevel.DEBUG, 'SVMX RESPONSE: '+svmxMessageList);
        System.debug( LoggingLevel.DEBUG, 'idResultListMap: '+idResultListMap);
        
        if( idResultListMap != null && !idResultListMap.isEmpty() ) {           
            updateFieldStatus();            
        }

//        if(ENABLE_PERFORMANCE_STATISTICS) processPerformanceReport();

        return invtResponse;
    }
    
/*    private void initPerformanceReport() {
        
        inventoryProcessStartTime = System.currentTimeMillis();
        
        emailBody += '\nTotal Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries();
        emailBody += '\nTotal Number of records that can be queried  in this apex code context: ' +  Limits.getLimitDmlRows();
        emailBody += '\nTotal Number of DML statements allowed in this apex code context: ' +  Limits.getLimitDmlStatements();
        emailBody += '\nThe time limit (in milliseconds) of CPU usage in the current transaction: ' +  Limits.getLimitCpuTime();        
        emailBody += '\nBefore inventory process.';
        emailBody += '\n\t1. Number of Queries used in this apex code so far: ' + Limits.getQueries();
        emailBody += '\n\t2. Number of rows queried in this apex code so far: ' + Limits.getDmlRows();
        emailBody += '\n\t3. Number of DML statements used so far : ' +  Limits.getDmlStatements();
        emailBody += '\n\t4. The CPU time (in milliseconds) accumulated on the Salesforce servers in the current transaction : ' +  Limits.getCpuTime();
        emailBody += '\n\t5. Final heap size        : ' +  Limits.getHeapSize();
        
    }
    
    private void processPerformanceReport() {
        
        Long inventoryProcessEndTime = System.currentTimeMillis();
        Long inventoryProcessingTime = inventoryProcessEndTime - inventoryProcessStartTime;
        String executionTime = ( inventoryProcessingTime > 1000 ) ? (inventoryProcessingTime / 1000) + ' seconds' : inventoryProcessingTime + ' ms';
        
        emailBody += '\n\nAfter inventory process.';
        emailBody += '\n\t1. Number of Queries used in this apex code so far: ' + Limits.getQueries();
        emailBody += '\n\t2. Number of rows queried in this apex code so far: ' + Limits.getDmlRows();
        emailBody += '\n\t3. Number of DML statements used so far : ' +  Limits.getDmlStatements();
        emailBody += '\n\t4. The CPU time (in milliseconds) accumulated on the Salesforce servers in the current transaction : ' +  Limits.getCpuTime();
        emailBody += '\n\t5. Final heap size        : ' +  Limits.getHeapSize();
        emailBody += '\n\nFinal execution time : ' +  executionTime;
        
        system.debug(LoggingLevel.WARN,'PerformanceLog: '+emailBody);
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
        
        singleEmailMessage.setToAddresses(EMAIL_RECIPIENTS);
        singleEmailMessage.setSubject( 'Inventory Report: Performance statistics for ' + lstINVT_TransactionRecord.size() +' lines ' );
        singleEmailMessage.setPlainTextBody( emailBody );
        singleEmailMessageList.add( singleEmailMessage );
        
        Messaging.sendEmail( singleEmailMessageList );
    }
*/  
    private void updateResultMap( String messageString ) {
        
        if( invtConfigurationRecord.isMultilineTransaction() ) {
            
            for( INVT_TransactionRecord invtTransactionRecord : lstINVT_TransactionRecord ) {
                
                if( !idResultListMap.containsKey( invtTransactionRecord.getTransactionRecordId() ) ) {
                    
                    List<String> messageList = new List<String>();                                
                    idResultListMap.put( invtTransactionRecord.getTransactionRecordId() , messageList );
                }
                
                idResultListMap.get(invtTransactionRecord.getTransactionRecordId()).add( messageString + ': ' + invtTransactionRecord.getNameFieldValue() );                
            }               
        } else {
            if( !idResultListMap.containsKey( (Id) headerRecord.get( INVT_Consts.FIELD_NAME_ID ) ) ) {
                
                List<String> messageList = new List<String>(); 
                messageList.add( messageString );
                idResultListMap.put( (Id) headerRecord.get( INVT_Consts.FIELD_NAME_ID ), messageList );        
            }                
        }
    }

    private void updateFieldStatus() {
        
        if( invtConfigurationRecord.isMultilineTransaction() ) {
            
            List<SObject> recordList = new List<SObject>();
            
            // Updating line record status messages
            for( INVT_TransactionRecord invtTransactionRecord : lstINVT_TransactionRecord ) {
                
                if( idResultListMap.containskey( invtTransactionRecord.getTransactionRecordId() ) ) {
                    
                    String messageString = listToString( idResultListMap.get( invtTransactionRecord.getTransactionRecordId() ), NEWLINE );
                    System.debug( LoggingLevel.INFO, 'Id : ' + (String) invtTransactionRecord.getTransactionRecordId() + '; Message : ' + messageString );
                    invtTransactionRecord.getTransactionRecord().put( invtConfigurationRecord.getStockResultUpdateFieldAPIName(), messageString );                    
                } else {
                    invtTransactionRecord.getTransactionRecord().put( invtConfigurationRecord.getStockResultUpdateFieldAPIName(), '' );
                }
                
                recordList.add( invtTransactionRecord.getTransactionRecord() );
            }   
            
            //Integer getQueries = Limits.getQueries();
            //Integer getDmlStatements = Limits.getDmlStatements();
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( recordList, COMM_SecurityUtils.Access.Updateable ) ) {
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            update recordList;
            } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            
            //emailBody += '\nTransaction Status Field Update (Line records), Number of queries = ' + ( Limits.getQueries() - getQueries );
            //emailBody += '\nTransaction Status Field Update (Line records), Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
                       
        } else {
            // Updating header status messages.
            for( Id headerId : idResultListMap.keyset() ) {
                
                String messageString = listToString( idResultListMap.get( headerId ), NEWLINE );
                System.debug( LoggingLevel.INFO, 'Id : ' + headerId + '; Message : ' + messageString );
                headerRecord.put( invtConfigurationRecord.getStockResultUpdateFieldAPIName(), messageString );
            }            
            
            //Integer getQueries = Limits.getQueries();
            //Integer getDmlStatements = Limits.getDmlStatements();
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( headerRecord, COMM_SecurityUtils.Access.Updateable ) ) {
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update headerRecord;
                } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            
            
            //emailBody += '\nTransaction Status Field Update (Header records), Number of queries = ' + ( Limits.getQueries() - getQueries );
            //emailBody += '\nTransaction Status Field Update (Header records), Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
             
        }
    }
    
    // Private method to convert list of strings to string.
    private String listToString( List<String> listOfStrings, String seperator ) {
        
        String retValue = '';
        
        for( String str : listOfStrings ) {
            retValue += str + seperator;
        }
        
        return retValue;
    }

    private void buildToSerialNumber() {    
        
        for( INVT_TransactionRecord invtTransactionRecord : invtTransactionRecordList ) {
            
            Id productId = invtTransactionRecord.getProductId();   
            Id transcationRecordId =  invtTransactionRecord.getTransactionRecordId();
            List<String> serialNumberList = invtTransactionRecord.getSerialNumberList();
            
            updateToSerialNumber( productId, transcationRecordId, serialNumberList );
        }
    }
  
    private void updateToSerialNumber( Id productId, Id transcationRecordId, List<String> serialNumber ) {
        
        if( serialNumber == null  ) {//|| serialNumber.trim().equalsIgnoreCase( INVT_Consts.EMPTY_STRING )
            return;
        }
        
        // prease do the trin befor process for now it is commented serialNumber = serialNumber.trim();    
                    
        Map<String, SVMXC__Product_Serial__c> mapSourcePSSerailNo = new Map<String, SVMXC__Product_Serial__c>();
        Map<String, SVMXC__Product_Serial__c> mapTargetPSSerialNo = new Map<string, SVMXC__Product_Serial__c>();
        Map<String, SVMXC__Product_Serial__c> mapRemovedPSSerailNo = new Map<String, SVMXC__Product_Serial__c>();
            
        if( mapTranscationRecIdSourcePSSerialNumber != null && mapTranscationRecIdSourcePSSerialNumber.containsKey( transcationRecordId ) ) {
            
            mapSourcePSSerailNo = mapTranscationRecIdSourcePSSerialNumber.get( transcationRecordId );
        }
    
        Integer count = 0;
        list<string> moveTargetSerialNumber = new list<string>();
        
        for(String strUniqueSerialNumber : mapSourcePSSerailNo.keySet()) {            
            
            String strSerialNumber = strUniqueSerialNumber.substringBefore('^');
            
            for(Integer i = 0; i <  serialNumber.size() ; i++) {
                
                if(serialNumber[i].equalsIgnoreCase(strSerialNumber)) {
                    
                    count++;
                    SVMXC__Product_Serial__c productSerial = mapSourcePSSerailNo.get(strUniqueSerialNumber);
                    if( productSerial == null ) {
                        productSerial = ((SVMXC__Product_Serial__c) mapRemovedPSSerailNo.get(strUniqueSerialNumber)).clone(false,true);
                    } else {
                        mapRemovedPSSerailNo.put( strUniqueSerialNumber, mapSourcePSSerailNo.remove(strUniqueSerialNumber));
                    }
                                                            
                    mapTargetPSSerialNo.put(strSerialNumber+'^'+count, productSerial);                    
                    moveTargetSerialNumber.add(serialNumber[i]);
                } 
            }
        }
        
        //list<String>  serialNumber = new list<String>();
        //list<String> moveTargetSerialNumber = new list<String>();
        
        Map<String, Integer> mapSerialNumberToCount = new Map<String, Integer>();
        for(String strSerialNumber : serialNumber) {
            
            if(!mapSerialNumberToCount.containsKey(strSerialNumber)) {
                mapSerialNumberToCount.put(strSerialNumber, 1);
            } else {
                Integer count1 = mapSerialNumberToCount.get(strSerialNumber)+1;
                mapSerialNumberToCount.put(strSerialNumber, count1);
            }
        }
        
        for(String strMoveSerialNumber : moveTargetSerialNumber) {
            
            if(mapSerialNumberToCount.containsKey(strMoveSerialNumber)) {
                
                Integer count1 = mapSerialNumberToCount.get(strMoveSerialNumber)-1;
                mapSerialNumberToCount.put(strMoveSerialNumber, count1);
            }
        }
        
        for(String strSerailNUmber : mapSerialNumberToCount.keySet()) {
            
            for(Integer i = 0 ; i < mapSerialNumberToCount.get(strSerailNUmber) ; i++) {
                
                SVMXC__Product_Serial__c objProductSerial = new SVMXC__Product_Serial__c();

                objProductSerial.Name = strSerailNUmber;
                objProductSerial.SVMXC__Product__c = productId;
                mapTargetPSSerialNo.put(strSerailNUmber+'^'+(mapTargetPSSerialNo.size()+1), objProductSerial);
            }
        }
        
        mapTranscationRecIdSourcePSSerialNumber.put( transcationRecordId, mapSourcePSSerailNo );
        mapTranscationRecIdRemovedPSSerialNumber.put( transcationRecordId, mapRemovedPSSerailNo );                
        mapTranscationRecordToSerial.put( transcationRecordId, mapTargetPSSerialNo);        
   }      
    
    private void buildFromSerialNumber() {
        
        // Call method to get all Source Product Stock
        buildSourceProductStockMap();        
        // Call method to get all Serial Number for Source Product Stock.
        map<String, map<String,SVMXC__Product_Serial__c>> mapUniqueKeyListOfSerialNumberWithDuplicates = new map<String, map<String,SVMXC__Product_Serial__c>>();
        mapUniqueKeyListOfSerialNumberWithDuplicates = getSerialNumberForSourceProductStock();
        
        // Call method to arrange Serial Number with Transcation Record Id
        BuildSerailNumberListforTranscationRecord(mapUniqueKeyListOfSerialNumberWithDuplicates);

        list<SVMXC__Product_Stock__c> lstNewSourceProductStock = new list<SVMXC__Product_Stock__c>();
        for( INVT_TransactionRecord invtTransactionRecord : invtTransactionRecordList ) {
            Id ProductId = invtTransactionRecord.getProductId();
            Id SourceLocationId = invtTransactionRecord.getFromLocationId();
            String strUniqueKey = ProductId+'_'+SourceLocationId+'_'+invtConfigurationRecord.getSourceStatus();
            mapTransactionRecordIdTransactionRecord.put(invtTransactionRecord.getTransactionRecordId(),invtTransactionRecord);
            // Check if the Source prodcut stock exsist for the Transcation record. IF not then create Source Product Stock record.
            if(!mapUniqueKeySourcePS.containsKey(strUniqueKey)){
                SVMXC__Product_Stock__c SourcePS = new SVMXC__Product_Stock__c();
                SourcePS.put('SVMXC__Quantity2__c', 0);
                SourcePS.put('SVMXC__Product__c', ProductId );
                SourcePS.put('SVMXC__Location__c', SourceLocationId );
                SourcePS.put('SVMXC__Status__c', invtConfigurationRecord.getSourceStatus() );
                mapUniqueKeySourcePS.put(strUniqueKey,SourcePS);
                lstNewSourceProductStock.add(SourcePS);
            }
            // Check Decreased Product stock 
            strUniqueKey = ProductId+'_'+SourceLocationId+'_DECREASED';
            if(!mapUniqueKeyDecreasedSourcePS.containsKey(strUniqueKey)){
                SVMXC__Product_Stock__c objProductStock = new SVMXC__Product_Stock__c();
                objProductStock.SVMXC__Quantity2__c = 0;
                objProductStock.SVMXC__Product__c = ProductId;
                objProductStock.SVMXC__Location__c = SourceLocationId;
                objProductStock.SVMXC__Status__c = 'DECREASED';
                mapUniqueKeyDecreasedSourcePS.put(strUniqueKey,objProductStock);
                lstNewSourceProductStockDecreased.add(objProductStock);
            }
        }
        if(lstNewSourceProductStock != null && lstNewSourceProductStock.size() > 0){
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewSourceProductStock, COMM_SecurityUtils.Access.Createable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert lstNewSourceProductStock;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
        }
        if(lstNewSourceProductStockDecreased != null && lstNewSourceProductStockDecreased.size() > 0){
                        
            //Integer getQueries = Limits.getQueries();
            //Integer getDmlStatements = Limits.getDmlStatements();
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewSourceProductStockDecreased, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert lstNewSourceProductStockDecreased;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
            
            
            //emailBody += '\nbuildFromSerialNumber: New source product stock decrease, Number of queries = ' + ( Limits.getQueries() - getQueries );
            //emailBody += '\nbuildFromSerialNumber: New source product stock decrease, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
            
        }
        for(SVMXC__Product_Stock__c PS : lstNewSourceProductStock){
            String strUniqueKey = PS.SVMXC__Product__c+'_'+PS.SVMXC__Location__c+'_'+PS.SVMXC__Status__c;
            if(mapUniqueKeySourcePS.containskey(strUniqueKey)){
                mapUniqueKeySourcePS.put(strUniqueKey,PS);
            }
        }
        for(SVMXC__Product_Stock__c PS : lstNewSourceProductStockDecreased){
            String strUniqueKey = PS.SVMXC__Product__c+'_'+PS.SVMXC__Location__c+'_'+PS.SVMXC__Status__c;
            if(mapUniqueKeyDecreasedSourcePS.containskey(strUniqueKey)){
                mapUniqueKeyDecreasedSourcePS.put(strUniqueKey,PS);
            }
        }
        
        system.debug('mapUniqueKeySourcePS'+mapUniqueKeySourcePS);
        system.debug('mapTranscationRecIdSourcePSSerialNumber'+mapTranscationRecIdSourcePSSerialNumber);
    }
    // This method get all Product Id and From Location Id from  INVT_TransactionRecord and query Product Stock record for them.
    private void buildSourceProductStockMap(){
        // Loop INVT_TransactionRecord.  Loop INVT_TransactionRecord.


        
        for( INVT_TransactionRecord invtTransactionRecord : invtTransactionRecordList ) {
            if(invtTransactionRecord.getProductId() != null){
                setProductId.add(invtTransactionRecord.getProductId());
            }
            if(invtTransactionRecord.getFromLocationId() != null){
                setFromLocationId.add(invtTransactionRecord.getFromLocationId());
            }
            if(invtTransactionRecord.getToLocationId() != null){
                setToLocationId.add(invtTransactionRecord.getToLocationId());
            }
        }
        system.debug('setProductId : '+setProductId);
        system.debug('setFromLocationId : '+setFromLocationId);

        system.debug('setToLocationId : '+setToLocationId);
        system.debug('invtConfigurationRecord.getSourceStatus() : '+invtConfigurationRecord.getSourceStatus());
        //Query Product stock records for given product, Location and inventory status
        map<Id, SVMXC__Product_Stock__c> mapSourceProductStock = new map<Id, SVMXC__Product_Stock__c>();
        
        // In exsisting inventory below query is implemented for If and Else. Don't know the reason about Else condition. 
        if(isValidString(invtConfigurationRecord.getSourceStatus()))
            mapSourceProductStock.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Id, SVMXC__Location__r.SVMXC__Email__c From SVMXC__Product_Stock__c where SVMXC__Status__c =: invtConfigurationRecord.getSourceStatus() And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setFromLocationId]);
        else
            mapSourceProductStock.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Id, SVMXC__Location__r.SVMXC__Email__c From SVMXC__Product_Stock__c where SVMXC__Status__c = 'DECREASED' And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setFromLocationId]);
       
        lstSourceProductStockDecreased = [Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Id, SVMXC__Location__r.SVMXC__Email__c From SVMXC__Product_Stock__c where SVMXC__Status__c = 'DECREASED' And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setFromLocationId];
        
        system.debug('lstSourceProductStock'+mapSourceProductStock);
        system.debug('lstSourceProductStockDecreased'+lstSourceProductStockDecreased);
        
        
        setSourcePSId = mapSourceProductStock.keyset();
        system.debug('setSourcePSId'+setSourcePSId);
        
        // Create Source Product Stock map With key = ProductId_LocationId_Status
        for(SVMXC__Product_Stock__c PS : mapSourceProductStock.values()){
            mapUniqueKeySourcePS.put(PS.SVMXC__Product__c+'_'+PS.SVMXC__Location__c+'_'+PS.SVMXC__Status__c,PS);
        }
        // Create Decreased Source Product Stock map With key = ProductId_LocationId_Status
        if(lstSourceProductStockDecreased.size() > 0){
            for(SVMXC__Product_Stock__c PS : lstSourceProductStockDecreased){
                String strUniqueKey = PS.SVMXC__Product__c+'_'+PS.SVMXC__Location__c+'_'+PS.SVMXC__Status__c;
                mapUniqueKeyDecreasedSourcePS.put(strUniqueKey,PS);
            }
        }
        system.debug('mapUniqueKeySourcePS'+mapUniqueKeySourcePS);
        system.debug('mapUniqueKeyDecreasedSourcePS'+mapUniqueKeyDecreasedSourcePS);
        
    }
    
    // This method query all product serial records for all source product stock 
    //and create map of unique key (prodcutStock.Product_ProductStock.Location_Product.Status) and map of Product serial
    private map<String, map<String,SVMXC__Product_Serial__c>> getSerialNumberForSourceProductStock(){
        map<String, map<String,SVMXC__Product_Serial__c>> mapUniqueKeyListOfSerialNumberWithDuplicates = new map<String, map<String,SVMXC__Product_Serial__c>>();
        map<String, list<SVMXC__Product_Serial__c>> mapUniqueKeyListOfSerialNumber = new map<String, list<SVMXC__Product_Serial__c>>();
        //Query all Poduct serail record from Source Product Stock and build a map of unique key and list of product serial.
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        list<SVMXC__Product_Serial__c> lstSerialNumberFromSourcePS = [Select SVMXC__Product_Stock__r.SVMXC__Status__c, SVMXC__Product_Stock__r.SVMXC__Location__c, SVMXC__Product_Stock__r.SVMXC__Product__c, SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : setSourcePSId order by SVMXC__Product_Stock__c];
        for(SVMXC__Product_Serial__c serialNumber : lstSerialNumberFromSourcePS){
            String strUniqueKey = serialNumber.SVMXC__Product_Stock__r.SVMXC__Product__c+'_'+serialNumber.SVMXC__Product_Stock__r.SVMXC__Location__c+'_'+serialNumber.SVMXC__Product_Stock__r.SVMXC__Status__c;
            
            if(!mapUniqueKeyListOfSerialNumber.containskey(strUniqueKey)){
                mapUniqueKeyListOfSerialNumber.put(strUniqueKey, new list<SVMXC__Product_Serial__c>());
            }
            mapUniqueKeyListOfSerialNumber.get(strUniqueKey).add(serialNumber);
        }
        // Create Serial number list with suffix ^+Incrementatl number (Don't know exceltly why we are doing this but this is implemented in exsisting inventory)
        for(String strKey : mapUniqueKeyListOfSerialNumber.keyset()){
            map<String, SVMXC__Product_Serial__c> serialNumbersWithDuplicate = new map<String, SVMXC__Product_Serial__c>();
            for(SVMXC__Product_Serial__c serialNumber : mapUniqueKeyListOfSerialNumber.get(strKey)){
                
                String strSerialNumberName = (String) serialNumber.get('Name');
                mapSerialNumberProductId.put(strSerialNumberName,(String)serialNumber.get('SVMXC__Product_Stock__c') );
                
                List<String> lstSuffix;
                if( mapSerialSuffix.containsKey(strSerialNumberName)) {
                    
                    lstSuffix = mapSerialSuffix.get(strSerialNumberName);
                    lstSuffix.add(String.valueOf(lstSuffix.size() + 1));
                } else {                                
                    lstSuffix = new List<String>(); lstSuffix.add('1');
                }
                String strUniqueSerialNumber = strSerialNumberName + '^' + String.valueOf( lstSuffix.size() );                             
                mapSerialSuffix.put( strSerialNumberName, lstSuffix);
                serialNumbersWithDuplicate.put( strUniqueSerialNumber, serialNumber );
            }
            mapUniqueKeyListOfSerialNumberWithDuplicates.put(strKey,serialNumbersWithDuplicate);
        }
        system.debug('mapUniqueKeyListOfSerialNumberWithDuplicates'+mapUniqueKeyListOfSerialNumberWithDuplicates);
        return mapUniqueKeyListOfSerialNumberWithDuplicates;
    }
    
    private void BuildSerailNumberListforTranscationRecord(map<String, map<String,SVMXC__Product_Serial__c>> mapUniqueKeyListOfSerialNumberWithDuplicates){
        
        for( INVT_TransactionRecord invtTransactionRecord : invtTransactionRecordList ) {
            Id ProductId = invtTransactionRecord.getProductId();
            Id SourceLocationId = invtTransactionRecord.getFromLocationId();
            String strUnique = ProductId+'_'+SourceLocationId+'_'+invtConfigurationRecord.getSourceStatus();
            if(mapUniqueKeyListOfSerialNumberWithDuplicates.containsKey(strUnique)){
                
                //Map<String, SVMXC__Product_Serial__c> mapSerialToProduct = new Map<String, SVMXC__Product_Serial__c>();
                //mapSerialToProduct.put( '', mapUniqueKeyListOfSerialNumberWithDuplicates.get(strUnique).get('') );
                //mapTranscationRecIdSourcePSSerialNumber.put(invtTransactionRecord.getTransactionRecordId(), mapSerialToProduct );
                Map<String, SVMXC__Product_Serial__c> mapSerialToProduct = mapUniqueKeyListOfSerialNumberWithDuplicates.get(strUnique);
                Map<String, SVMXC__Product_Serial__c> mapSerialToProductTemp = new Map<String, SVMXC__Product_Serial__c>();
                for( String serialKey : mapSerialToProduct.keyset() ) {
                    
                    List<String> serialList = invtTransactionRecord.getSerialNumberList();
                    String serialString = serialKey.substring( 0, serialKey.indexOf('^') );
                    
                    for( String serial : serialList ) {
                        
                        if( serialString.equals( serial ) ) {
                            mapSerialToProductTemp.put( serialKey, mapSerialToProduct.get(serialKey) );
                        }
                    }
                }
                if( !mapSerialToProductTemp.isEmpty() ) {
                    mapTranscationRecIdSourcePSSerialNumber.put( invtTransactionRecord.getTransactionRecordId(), mapSerialToProductTemp );
                }
                //mapTranscationRecIdSourcePSSerialNumber.put(invtTransactionRecord.getTransactionRecordId(),mapUniqueKeyListOfSerialNumberWithDuplicates.get(strUnique));
            }
        }
    }
    
    private void doInventoryUpdate() {        
        System.debug( LoggingLevel.WARN, 'enter do inventry update');
        boolean isSerialSaved = false;
        
        SVMX_CheckSerialStockUpdates();
        if(svmxMessageList.isEmpty())
        {

            if(invtConfigurationRecord != null)
            {
                Boolean isStockUpdate = false;
                Boolean isSerialNumbercheck = true;
                system.debug(LoggingLevel.WARN, 'test log 1: '+isRollBack);

                if( invtConfigurationRecord.isEnableSerialSelection() ) {
                    isSerialNumbercheck = validateSerialNumbers();
                }
                
                if( idResultListMap != null && idResultListMap.isEmpty() ) {
                                
                    if( isSerialNumbercheck ) {
                        isStockUpdate = updateProductStockAndHistory();
                    }
                    
                    if(!isStockUpdate) {
                
                        if( !isErrorAdded ) {
                            addError(objTags.getTAG043());
                        }
                    } else {
                    
                        if(invtConfigurationRecord.isEnableSerialSelection())
                            isSerialSaved = processSerialSave();
                    }
                    
                    if( svmxMessageList.isEmpty() ) {
                        SVMX_closureActionRelatedRecordUpdate(isSerialSaved);
                    }
                }
            }
        }
        if(isRollBack)
        {
            system.debug(LoggingLevel.WARN, 'Rollbacked.');
            database.rollBack(sp2);
        }        
    }
        
    
    //related records and closure actions update//
    private void SVMX_closureActionRelatedRecordUpdate(boolean isSerialSaved) {
        
        List<SVMXC__ServiceMax_Config_Data__c> headerClosureActionList = new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lineClosureActionList = new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> relatedClosureActionList = new list<SVMXC__ServiceMax_Config_Data__c>();//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                 
        List<SVMXC__ServiceMax_Config_Data__c> closerActionList = database.query( 'SELECT id, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name__c, SVMXC__Expression_Type__c, SVMXC__Field_Name__c, SVMXC__Operand__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = \'Expressions\' AND SVMXC__Inventory_Process__c = \'' + objInventoryProcess.Id +'\'');
        
        for( SVMXC__ServiceMax_Config_Data__c configData : closerActionList ) {
            
            if(configData.SVMXC__Expression_Type__c.equalsIgnoreCase( INVT_Consts.EXPRESSION_TYPE_HEADER_CLOSURE_ACTION ) ) {
                headerClosureActionList.add( configData );
            } else if(configData.SVMXC__Expression_Type__c.equalsIgnoreCase( INVT_Consts.EXPRESSION_TYPE_LINE_CLOSURE_ACTION ) ) {              
                lineClosureActionList.add( configData );
            } else if(configData.SVMXC__Expression_Type__c.equalsIgnoreCase( INVT_Consts.EXPRESSION_TYPE_RELATED_UPDATE_ACTION ) ) {
                relatedClosureActionList.add( configData );
            }
        }
        
        /*
         * If serial selection is not enabled or serial selection is enabled and 
         * serial save is true the perform the closure action on header, line and related lines.
         */


        if( ( invtConfigurationRecord != null && ( !invtConfigurationRecord.isEnableSerialSelection() ) ) || 
            ( ( invtConfigurationRecord != null && invtConfigurationRecord.isEnableSerialSelection() ) && isSerialSaved ) ) { 
                
            if( updateHeaderAndLineClosureAction( headerClosureActionList, lineClosureActionList ) ) {
                
                if( !updateRelatedUpdateAction( relatedClosureActionList ) ) {
                    
                    if(!isErrorAdded) {
                        addError(objTags.getTAG043());

                    }                    
                    isRollBack = true;                    
                }
            } else {                
                isRollBack = true;
            }
        }        
    }
    
    private void SVMX_CheckSerialStockUpdates()
    {
        //declare variables start
        System.debug( LoggingLevel.WARN, 'enter SVMX_CheckSerialStockUpdates');
        
        set<string> setDuplicateSerials = new set<string>();         
        //declare variables end
        try {
            
            // Check for lines having excess quantity / partial quantity, if these are not allowed as per the inventory process definition
            checkExcessQuantity();
            
            if(isInventoryEnabled) {

                if(invtConfigurationRecord != null && 
                    invtConfigurationRecord.getEnforceUniquenessInSerialSelection() != null && 
                    (invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'STRICT' || invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'SOFT' ))
                {
                    if(invtConfigurationRecord.getSourceAction() != null && invtConfigurationRecord.getSourceAction() == 'SET') {
                        // Do the duplicate check for the serial numbers entered in the request only
                        checkDuplicateSerialNumber(setDuplicateSerials,false);
                    } else {
                        //Do duplicate check for serial numbers against values entered in screen and values existing in db
                        checkDuplicateSerialNumber(setDuplicateSerials,true);
                    }
                }
                
                if(isSerialError) {
                    addError( objTags.getTAG045() + ': ' + getDuplicateSerials(setDuplicateSerials) );                
                } else if( idResultListMap == null || idResultListMap.isEmpty() ) {
                    //This method is for check Target product stock and create new if it is not available 
                    checkTargetProductStock();
                }
            }
        }
        catch(exception ex) {
            
            System.debug( LoggingLevel.WARN, 'catch  SVMX_CheckSerialStockUpdates: '+ex);
            addError(objTags.getTAG043());

        }
    }
    /**
    *   This method check the actual quantity comes with the line record and expected quantity, and give error message according to invt process
    **/
    private void checkExcessQuantity()
    {
        try
        {
            string strExcessLines = '';
            string strPartialLines = '';
            for(INVT_TransactionRecord objINVT_TransactionRecord : invtTransactionRecordList)

            {
                if(!invtConfigurationRecord.isAllowExcessQuantity() && (objINVT_TransactionRecord.getOriginalQty() < objINVT_TransactionRecord.getActualQty()))

                {   
                    if(strExcessLines.length() > 0)
                        strExcessLines += ', ';
                    strExcessLines += (objINVT_TransactionRecord.getNameFieldValue()) + ' (' + (objINVT_TransactionRecord.getProductName()) + ')';
                    addError(objINVT_TransactionRecord.getTransactionRecordId(), objTags.getTAG048() + ' ' + strExcessLines, false );
                }
                if(!invtConfigurationRecord.isAllowPartialQuantity() && (objINVT_TransactionRecord.getOriginalQty() > objINVT_TransactionRecord.getActualQty()))

                {
                    if(strPartialLines.length() > 0)
                        strPartialLines += ', ';
                    strPartialLines += (objINVT_TransactionRecord.getNameFieldValue()) + ' (' + (objINVT_TransactionRecord.getProductName()) + ')';

                    addError( objINVT_TransactionRecord.getTransactionRecordId(), objTags.getTAG049() + ' ' + strPartialLines, false );
                }
            }
        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  checkExcessQuantity: '+ex);
            addError( ex.getmessage());
        }
    }
  
    /**

        Method to validate the serial number to enter are duplicate or not.
        This method also check the serial number in database also for available or intransit in any location
    **/
    private void checkDuplicateSerialNumber(set<string> setDuplicateSerials, Boolean doDataBaseCheckAlso)
    {
        try
        {
            map<String, SVMXC__Product_Serial__c> mapUniqueSerailNoProductSerial = new map<String, SVMXC__Product_Serial__c>();


            list<Id> lstProductId = new list<Id>();
            map<String, set<String>> mapProductIdSetSerailNumber = new map<String, set<String>>();
            map<String, map<String, list<SVMXC__Product_Serial__c>>> mapProductIdMapSerailNumberListProductSerial = new map<String, map<String, list<SVMXC__Product_Serial__c>>> ();
            set<String> setSerailNumber = new set<String>() ;
            // Do duplicate check for each product against values comes from request for that product
            for(INVT_TransactionRecord objINVT_TransactionRecord : invtTransactionRecordList) {
                
                Id transactionRecordId = objINVT_TransactionRecord.getTransactionRecordId();
                
                // Defect 012356 fix.                
                Boolean hasError = false;
                List<String> serialNumberList = objINVT_TransactionRecord.getSerialNumberList();
                if( serialNumberList != null ) {                
                    for( Integer i = 0; i < serialNumberList.size() - 1; i++ ) {
                        for( Integer j = (i+1); j < serialNumberList.size(); j++ ) {
                            if( serialNumberList[i].equalsIgnoreCase(serialNumberList[j]) ) {
                                addError( transactionRecordId, objTags.getTAG045() + ': ' + objINVT_TransactionRecord.getNameFieldValue() , false);
                                hasError = true;
                                break;                           
                            }
                        }
                        if( hasError ) break;
                    }
                }
                
                if( hasError ) continue;
                // End of Defect 012356 fix.

                String strProdId =(string)objINVT_TransactionRecord.getProductId();
                if(mapTranscationRecordToSerial != null && mapTranscationRecordToSerial.containsKey(transactionRecordId))
                    mapUniqueSerailNoProductSerial = mapTranscationRecordToSerial.get(transactionRecordId);
                if(mapUniqueSerailNoProductSerial != null){
                    for(string strUniqueSerialNo : mapUniqueSerailNoProductSerial.keyset())
                    {
                        SVMXC__Product_Serial__c objProductSerialRecord = mapUniqueSerailNoProductSerial.get(strUniqueSerialNo);
                        string strSerialNumber = '';
                        if(objProductSerialRecord != null)
                            strSerialNumber = (String)objProductSerialRecord.get('Name');
                        
                        if(strSerialNumber != '' && mapProductIdSetSerailNumber.containskey(strProdId)  && mapProductIdSetSerailNumber.get(strProdId).contains(strSerialNumber))
                        {                            
                            setDuplicateSerials.add(strSerialNumber);
                            if( invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'STRICT' ||
                                invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'SOFT' ) {
                                //isSerialError = true;
                                addError( transactionRecordId, objTags.getTAG045() + ': ' + objINVT_TransactionRecord.getNameFieldValue() , false);
                            }
                        }
                        else
                        {
                            if(! mapProductIdSetSerailNumber.containsKey(strProdId)){
                                mapProductIdSetSerailNumber.put(strProdId, new set<string>());
                            }
                            mapProductIdSetSerailNumber.get(strProdId).add(strSerialNumber);                            
                            setSerailNumber.add(strSerialNumber);
                        }
                    }
                }
                lstProductId.add(objINVT_TransactionRecord.getProductId());
            }
            if(doDataBaseCheckAlso){    
                // Retrieve stocked serial records from db for the products and serials of all the lines
                list<SVMXC__Product_Serial__c> lstStockSerialInDB;
                if(setSerailNumber.size() >0 && !isAllowWarining)
                {
                    List<String> AllowedStockStatusValuesForInventory = getAllowedStockStatusValuesForInventory();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstStockSerialInDB = [Select SVMXC__Product__c, Name, SVMXC__Product_Stock__c, SVMXC__Product_Stock__r.Name, Id From SVMXC__Product_Serial__c where Name IN: setSerailNumber AND SVMXC__Product__c IN: lstProductId AND SVMXC__Product_Stock__r.SVMXC__Status__c IN: AllowedStockStatusValuesForInventory];
                }
                system.debug('lstStockSerialInDB - source and target: ' + lstStockSerialInDB);
                system.debug('mapSlNoProdStkId - source: ' + mapSerialNumberProductId);
                
                // Do duplicate check for each product against values retrieved from db for that product
                if(lstStockSerialInDB != null && lstStockSerialInDB.size() > 0)
                {
                    for(SVMXC__Product_Serial__c objProdcutSerial: lstStockSerialInDB)
                    {
                        if(!mapProductIdMapSerailNumberListProductSerial.containsKey((String)objProdcutSerial.get('SVMXC__Product__c')))
                        {
                            map<String, list<SVMXC__Product_Serial__c>> MapSerailNumberListProductSerial = new map<String, list<SVMXC__Product_Serial__c>>();
                            mapProductIdMapSerailNumberListProductSerial.put((String)objProdcutSerial.get('SVMXC__Product__c'), MapSerailNumberListProductSerial);       
                        }
                        if(!(mapProductIdMapSerailNumberListProductSerial.get((String)objProdcutSerial.get('SVMXC__Product__c')).containskey((String)objProdcutSerial.get('Name'))))
                            mapProductIdMapSerailNumberListProductSerial.get((String)objProdcutSerial.get('SVMXC__Product__c')).put((String)objProdcutSerial.get('Name'), new list<SObject>{objProdcutSerial});
                        else
                            mapProductIdMapSerailNumberListProductSerial.get((String)objProdcutSerial.get('SVMXC__Product__c')).get((String)objProdcutSerial.get('Name')).add(objProdcutSerial);
                    }
                    system.debug('mapProductIdMapSerailNumberListProductSerial: ' + mapProductIdMapSerailNumberListProductSerial);
                    
                    for(string productId : mapProductIdMapSerailNumberListProductSerial.keyset()) // For each product 
                    {
                        // Get the Stocked Serials retrieved from DB for this product
                        map<string, list<SVMXC__Product_Serial__c>> mapSerailNumberListOfProductSerial = mapProductIdMapSerailNumberListProductSerial.get(productId);
                        if(mapProductIdSetSerailNumber.containsKey(productId))
                        {
                            for(string strSerial : mapProductIdSetSerailNumber.get(productId)) // For each unique serial no. entered
                            {
                                if(mapSerailNumberListOfProductSerial.containsKey(strSerial)) // If the serial no. is in DB
                                {       
                                    if(mapSerialNumberProductId.containsKey(strSerial)) // If the serial no. is in source
                                    {
                                        for(SVMXC__Product_Serial__c objProductSerialRecord : mapSerailNumberListOfProductSerial.get(strSerial))
                                        {
                                            if(objProductSerialRecord != null && mapSerialNumberProductId.get(strSerial) != objProductSerialRecord.get('SVMXC__Product_Stock__c')) // Consider as duplicate only if serial no. in DB is not that of the source
                                            {
                                                setDuplicateSerials.add(strSerial);
                                                String strUniqueKey = objProductSerialRecord.get('SVMXC__Product__c')+'_'+strSerial;
                                                if(!mapProductIdSerialNoProductStockName.containsKey(strUniqueKey))
                                                    mapProductIdSerialNoProductStockName.put(strUniqueKey,new list<String>());
                                                mapProductIdSerialNoProductStockName.get(strUniqueKey).add((String)objProductSerialRecord.SVMXC__Product_Stock__r.Name);
                                                
                                                if( invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'STRICT' ||
                                                    invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'SOFT' ) {
                                                    isSerialError = true;
                                                    // addError( transactionRecordId, '', false);
                                                } 
                                            }
                                        }
                                    }
                                    else { // If serial no. is not in source, but in db, consider as duplicate
                                    
                                        setDuplicateSerials.add(strSerial);
                                        if( invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'STRICT' ||
                                            invtConfigurationRecord.getEnforceUniquenessInSerialSelection() == 'SOFT' ) {
                                            isSerialError = true;
                                            // addError( transactionRecordId, '', false);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }     
        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  checkDuplicateSerialNumber: '+ex.getmessage() +' Line number: ' +ex.getLineNumber());
            addError( ex.getmessage());
        }
    }

    private void checkTargetProductStock(){
    
        try{
            if(isInventoryEnabled && invtConfigurationRecord.getNumberOfLocation() != null && invtConfigurationRecord.getNumberOfLocation() != '' && schemaTypeProductStock != null ){
                set<string> setNewTargetStock = new set<String>();
        
                if(setToLocationId != null && setToLocationId.size() > 0 && setProductID != null && setProductID.size() > 0 && isValidString(invtConfigurationRecord.getTargetStatus())){
                    lstTargetProductStock = [Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Id, SVMXC__Location__r.SVMXC__Email__c From SVMXC__Product_Stock__c where SVMXC__Status__c =: invtConfigurationRecord.getTargetStatus() And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setToLocationId];
                }
                
                if(invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'ONE' && invtConfigurationRecord.getSourceAction().ToUpperCase() == 'SET' && setFromLocationId != null && setFromLocationId.size() > 0 && setProductID != null && setProductID.size() > 0)
                    lstTargetProductStock = [Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, SVMXC__Location__r.SVMXC__Email__c ,  Id From SVMXC__Product_Stock__c where SVMXC__Status__c = 'ADJUSTED' And SVMXC__Product__c IN : setProductId And SVMXC__Location__c IN : setFromLocationId];
                
                if(lstTargetProductStock == null)
                    lstTargetProductStock = new List<SVMXC__Product_Stock__c>();
            
                //Create map 
                if(lstTargetProductStock.size() > 0){
                    for(SVMXC__Product_Stock__c TargetPS : lstTargetProductStock){
                        String strUniqueKey = TargetPS.SVMXC__Product__c+'_'+TargetPS.SVMXC__Location__c+'_'+TargetPS.SVMXC__Status__c;
                        mapUniqueKeyTargetPS.put(strUniqueKey,TargetPS);
                    }
                }
                for(INVT_TransactionRecord objINVT_TransactionRecord :invtTransactionRecordList){
                    
                    Id productId = objINVT_TransactionRecord.getProductId();
                    Id fromLocationId = objINVT_TransactionRecord.getFromLocationId();
                    Id toLocationId = objINVT_TransactionRecord.getToLocationId();
                    
                    if(lstTargetProductStock != null && objINVT_TransactionRecord.getActualQty() != null && (objINVT_TransactionRecord.getActualQty() > 0 || (objINVT_TransactionRecord.getActualQty() == 0 && (invtConfigurationRecord.getSourceAction() == 'Set' || invtConfigurationRecord.getTargetAction() == 'Set'))))
                    {

                        Boolean targetFound = false;
                        for(SVMXC__Product_Stock__c objProductStock :lstTargetProductStock){
                            if(productId == (Id)objProductStock.get('SVMXC__Product__c') && objINVT_TransactionRecord.getToLocationId() == (Id)objProductStock.get('SVMXC__Location__c') && invtConfigurationRecord.getTargetStatus() == (String)objProductStock.get('SVMXC__Status__c')){
                                targetFound = true;
                                break;
                            }
                            if(objINVT_TransactionRecord.getToLocationId() == null || ((String)objINVT_TransactionRecord.getToLocationId()).length() == 0){
                                if(productId == (Id)objProductStock.get('SVMXC__Product__c') && objINVT_TransactionRecord.getToLocationId() == (Id)objProductStock.get('SVMXC__Location__c') && 'DECREASED' == ((String)objProductStock.get('SVMXC__Status__c')).ToUpperCase()){
                                    targetFound = true;
                                    break;
                                }
                            }

                            if(invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'ONE' && invtConfigurationRecord.getSourceAction().ToUpperCase() == 'SET'){
                                if(productId == (Id)objProductStock.get('SVMXC__Product__c') && objINVT_TransactionRecord.getFromLocationId() == (Id)objProductStock.get('SVMXC__Location__c') && ((String)objProductStock.get('SVMXC__Status__c')).ToUpperCase() == 'ADJUSTED'){
                                    targetFound = true;
                                    break;
                                }
                            }
                        }
                        if(!targetFound){
                            System.debug( LoggingLevel.WARN, 'lstTargetProductStock not found : ');
                            SVMXC__Product_Stock__c objProductStock = new SVMXC__Product_Stock__c();
                            objProductStock.SVMXC__Quantity2__c = 0;
                            objProductStock.SVMXC__Product__c = productId;
                            if(isValidString(invtConfigurationRecord.getTargetStatus())){
                                if( !setNewTargetStock.contains(String.valueOf(productId)+String.valueOf(FromLocationId)+invtConfigurationRecord.getTargetStatus())){
                                    objProductStock.SVMXC__Status__c = invtConfigurationRecord.getTargetStatus();
                                    objProductStock.SVMXC__Location__c = ToLocationId;
                                    lstNewTargetProductStock.add(objProductStock);
                                    setNewTargetStock.add(String.valueOf(productId)+String.valueOf(FromLocationId)+invtConfigurationRecord.getTargetStatus());
                                }
                            }
                            if(invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'ONE' && invtConfigurationRecord.getSourceAction().ToUpperCase() == 'SET'){
                                objProductStock.SVMXC__Status__c = 'ADJUSTED';
                                objProductStock.SVMXC__Location__c = FromLocationId;
                                if(!setNewTargetStock.contains(String.valueOf(productId)+String.valueOf(FromLocationId)+'ADJUSTED')){
                                    lstNewTargetProductStock.add(objProductStock);
                                    setNewTargetStock.add(String.valueOf(productId)+String.valueOf(FromLocationId)+'ADJUSTED');
                                }
                            }
                        }
                    }
                }

                if(lstNewTargetProductStock != null && lstNewTargetProductStock.size() > 0) {
                
                    
                    //Integer getQueries = Limits.getQueries();
                    //Integer getDmlStatements = Limits.getDmlStatements();
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewTargetProductStock, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstNewTargetProductStock;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    
            
                    //emailBody += '\ncheckTargetProductStock: New target product stock, Number of queries = ' + ( Limits.getQueries() - getQueries );
                    //emailBody += '\ncheckTargetProductStock: New target product stock, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
                
                }
                       
                if(lstNewTargetProductStock != null && lstNewTargetProductStock.size() > 0){
                    for(SVMXC__Product_Stock__c newTargetPS :lstNewTargetProductStock){
                        String strUniqueKey = newTargetPS.SVMXC__Product__c+'_'+newTargetPS.SVMXC__Location__c+'_'+newTargetPS.SVMXC__Status__c;
                        mapUniqueKeyTargetPS.put(strUniqueKey,newTargetPS);
                    }
                }
                    
            }
            System.debug( LoggingLevel.WARN, 'mapUniqueKeySourcePS: '+mapUniqueKeySourcePS);

            System.debug( LoggingLevel.WARN, 'mapUniqueKeyDecreasedSourcePS: '+mapUniqueKeyDecreasedSourcePS);
            System.debug( LoggingLevel.WARN, 'mapUniqueKeyTargetPS: '+mapUniqueKeyTargetPS);
        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  checkTargetProductStock: '+ex);
            addError(ex.getmessage());

        }
    }
    
    /**
    *   This method is for check for serial numbers and quantity is valid or not
    **/
    private Boolean validateSerialNumbers()
    {
        System.debug( LoggingLevel.WARN, 'enter validateSerialNumbers');
        try
        {
            boolean IsQtyCorrect = true;
            string strErrorLineName ='';
            boolean IsQtyWrong = true;
            string strWrongLineName ='';
            for(INVT_TransactionRecord objINVT_TransactionRecord : invtTransactionRecordList)
            {
                if((double)objINVT_TransactionRecord.getActualQty() >= 0)
                {
                    if(mapValidSerializedProdcts.containsKey(((string)objINVT_TransactionRecord.getProductId())) && objINVT_TransactionRecord.getActualQty() > 0)
                    {
                        if(!mapTranscationRecordToSerial.containsKey(((string)objINVT_TransactionRecord.getTransactionRecordId())) || objINVT_TransactionRecord.getActualQty() != mapTranscationRecordToSerial.get(((string)objINVT_TransactionRecord.getTransactionRecordId())).size())
                        {                            
                            if(strErrorLineName.length() > 0)
                                strErrorLineName += ', ';
                            strErrorLineName += ((string)objINVT_TransactionRecord.getNameFieldValue()) + ' (' + ((string)objINVT_TransactionRecord.getProductName()) + ')';
                            IsQtyCorrect = false;
                            addError( objINVT_TransactionRecord.getTransactionRecordId(), objTags.getTAG042() + ' ' + strErrorLineName, false );
                        }
                    }
                }
                else
                {
                    if(strWrongLineName.length() > 0)
                        strWrongLineName += ', ';
                    strWrongLineName += ((string)objINVT_TransactionRecord.getNameFieldValue()) + ' (' + ((string)objINVT_TransactionRecord.getProductName()) + ')';
                    IsQtyWrong = false;
                    addError( objINVT_TransactionRecord.getTransactionRecordId(), objTags.getTAG055() + ' ' + strWrongLineName, false );
                }
            }
            if(!IsQtyCorrect)
                addError( objTags.getTAG042() + ' ' + strErrorLineName);
            if(!IsQtyWrong)
                addError( objTags.getTAG055() + ' ' + strWrongLineName);
            if(!IsQtyCorrect || !IsQtyWrong)
                return false;
            return true;
        }
        catch(exception ex)
        {
            System.debug( LoggingLevel.WARN, 'catch  validateSerialNumbers: '+ex);
            addError( ex.getMessage());
            return false;
        }
        return false;
    } 
    /**
    *   This method is for update product stock and history
    **/
    private Boolean updateProductStockAndHistory()
    {
        System.debug( LoggingLevel.WARN, 'enter updateProductStockAndHistory');
        try
        {
            if(invtConfigurationRecord.getNumberOfLocation() != null && invtConfigurationRecord.getNumberOfLocation() != '' && schemaTypeProductStock != null )
            {
            
                system.debug(LoggingLevel.WARN, 'Entered for Stock updates..'+invtTransactionRecordList);
                string RTypeStockHistory = getRecordType('SVMXC__Stock_History__c','Stock History');
                List<SVMXC__Stock_History__c> lstProductStockHistory = new List<SVMXC__Stock_History__c>();
                

                if(invtConfigurationRecord.getEmailForNegativeStockAlert() != null && invtConfigurationRecord.getEmailForNegativeStockAlert().length() > 0)
                    mapMailList.put(invtConfigurationRecord.getEmailForNegativeStockAlert(), new list<INVT_TransactionRecord>());
                for(INVT_TransactionRecord objINVT_TransactionRecord : invtTransactionRecordList)
                {
                    //String strProductId =((string)objINVT_TransactionRecord.getProductId());
                    //String strRecordLineId = ((string)objINVT_TransactionRecord.getTransactionRecordId());
                    boolean isProductStockable = false;
                    if(objINVT_TransactionRecord.getActualQty() > 0 || (objINVT_TransactionRecord.getActualQty() == 0 && (invtConfigurationRecord.getSourceAction() == 'Set' || invtConfigurationRecord.getTargetAction() == 'Set')))
                    {

                        if(!invtConfigurationRecord.isMultilineTransaction() && isValidString(invtConfigurationRecord.getRelationshipNameToProduct()))
                        {

                            sobject sobjProduct = headerRecord.getSObject(invtConfigurationRecord.getRelationshipNameToProduct());
                            if(sobjProduct != null && (Boolean)sobjProduct.get('SVMXC__Stockable__c'))
                                isProductStockable = true;
                        }

                        else if(isValidString(invtConfigurationRecord.getRelationshipNameToProduct()))
                        {
                            sobject sobjProduct = objINVT_TransactionRecord.getTransactionRecord().getSObject(invtConfigurationRecord.getRelationshipNameToProduct());
                            if(sobjProduct != null && (Boolean)sobjProduct.get('SVMXC__Stockable__c'))
                                isProductStockable = true;
                        }
                        system.debug('isProductStockable'+isProductStockable);
                        if(isProductStockable)
                        {   
                            //update product stock and history for source
                            system.debug(LoggingLevel.WARN,'Check Here'+objINVT_TransactionRecord);
                            system.debug(LoggingLevel.WARN,'Check Here'+lstProductStockHistory);
                            system.debug(LoggingLevel.WARN,'Check Here'+RTypeStockHistory);
                            createSourceProductStockAndHistory(objINVT_TransactionRecord, lstProductStockHistory, RTypeStockHistory);
                            if(isNagetiveWarn)
                                return false;
                            //update product stock and history for target
                            createTargetProductStockAndHistory(objINVT_TransactionRecord, lstProductStockHistory, RTypeStockHistory);  
                            if(isNagetiveWarn)
                                return false;
                        }
                    }
                }

                
                System.debug( LoggingLevel.WARN, 'mapUniqueKeySourcePS: '+mapUniqueKeySourcePS);
                System.debug( LoggingLevel.WARN, 'mapUniqueKeyTargetPS: '+mapUniqueKeyTargetPS);

                System.debug( LoggingLevel.WARN, 'mapUniqueKeyDecreasedSourcePS: '+mapUniqueKeyDecreasedSourcePS);
                lstSourceProductStock.Clear();
                if(mapUniqueKeySourcePS.size() >0){
                    lstSourceProductStock.addAll(mapUniqueKeySourcePS.values());
                }

                if(mapUniqueKeyTargetPS.size() >0){
                    lstSourceProductStock.addAll(mapUniqueKeyTargetPS.values());

                }

                if(mapUniqueKeyDecreasedSourcePS.size() >0){
                    lstSourceProductStock.addAll(mapUniqueKeyDecreasedSourcePS.values());

                } 

                system.debug( LoggingLevel.WARN, 'lstSourceProductStock: '+lstSourceProductStock);
                system.debug( LoggingLevel.WARN, 'lstProductStockHistory: '+lstProductStockHistory);
                // Upsert Product Stock Records..
                if(lstSourceProductStock != null && lstSourceProductStock.size() >0) {
                    
                    //Integer getQueries = Limits.getQueries();
                    //Integer getDmlStatements = Limits.getDmlStatements();
            
                    upsert lstSourceProductStock;
            
                    //emailBody += '\nupdateProductStockAndHistory: Source product stock, Number of queries = ' + ( Limits.getQueries() - getQueries );
                    //emailBody += '\nupdateProductStockAndHistory: Source product stock, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );           
                }
                // Upsert Product Stock History Records..
                if(lstProductStockHistory != null && lstProductStockHistory.size() >0) {                    
                       
                    //Integer getQueries = Limits.getQueries();
                    //Integer getDmlStatements = Limits.getDmlStatements();
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProductStockHistory, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstProductStockHistory;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    
            
                    //emailBody += '\nupdateProductStockAndHistory: Product stock history, Number of queries = ' + ( Limits.getQueries() - getQueries );
                    //emailBody += '\nupdateProductStockAndHistory: Product stock history, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );              
                }
        
                sendMail();
            }
            return true;

        }   
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch updateProductStockAndHistory: ');
            addError( ex.getmessage());
            return false;

        }
    }
    /**
    *   create a map for all negative product stock and email ID to send mail
    **/
    private void createNegativeStockMap(INVT_TransactionRecord objINVT_TransactionRecord, SVMXC__Product_Stock__c sObjTargetPSID, String strProductId)
    {
        try
        {
            objINVT_TransactionRecord.setNegativeStockAtSource( INVT_Consts.BOOLEAN_FALSE );
            if(mapValidProdRecs.containsKey(strProductId) && mapMailList.ContainsKey(invtConfigurationRecord.getEmailForNegativeStockAlert()))
                mapMailList.get(invtConfigurationRecord.getEmailForNegativeStockAlert()).add(objINVT_TransactionRecord);
                System.debug(LoggingLevel.WARN, 'sObjTargetPSID: '+sObjTargetPSID);
            String strEmailAddress = sObjTargetPSID.SVMXC__Location__r.SVMXC__Email__c;



            if(mapValidProdRecs.containsKey(strProductId) && invtConfigurationRecord.isEmailSentToLocationOwner() && strEmailAddress != null && strEmailAddress.length() > 0)
            {
                if(!mapMailList.ContainsKey(strEmailAddress))
                    mapMailList.put(strEmailAddress, new list<INVT_TransactionRecord>());
                mapMailList.get(strEmailAddress).add(objINVT_TransactionRecord);

            } 
        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  createNegativeStockMap: '+ex);
            addError( ex.getmessage());
        }
    }
    
    /**
    *   method for create product stock and history for source location
    **/
    private void createSourceProductStockAndHistory(INVT_TransactionRecord objINVT_TransactionRecord, List<SVMXC__Stock_History__c> lstProductStockHistory, string RTypeStockHistory)
    {
        system.debug('objINVT_TransactionRecord'+objINVT_TransactionRecord);
        system.debug('mapTranscationRecIdSourcePSSerialNumber'+mapTranscationRecIdSourcePSSerialNumber);
        
        try
        {
            Id productId = objINVT_TransactionRecord.getProductId();
            Id transactionRecordId = objINVT_TransactionRecord.getTransactionRecordId();
            Id fromLocationId = objINVT_TransactionRecord.getFromLocationId();
            Boolean isSourcelocationStockable = false;
            
            if(invtConfigurationRecord.isSourceLocationFromHeader()){
                isSourcelocationStockable = (Boolean)headerRecord.getSobject(invtConfigurationRecord.getRelationshipToSourceLocation()).get('SVMXC__Stocking_Location__c');
            }
            else{
                if(objINVT_TransactionRecord.getTransactionRecord().getSObject(invtConfigurationRecord.getRelationshipToSourceLocation()) != null)
                    isSourcelocationStockable = (Boolean)(objINVT_TransactionRecord.getTransactionRecord().getSObject(invtConfigurationRecord.getRelationshipToSourceLocation()).get('SVMXC__Stocking_Location__c'));
            }
            SVMXC__Product_Stock__c sObjSourcePSID;
            system.debug('isSourcelocationStockable'+isSourcelocationStockable);
            if(isSourcelocationStockable){
                //system.debug('mapUniqueKeySourcePS'+mapUniqueKeySourcePS);
                String strUniqueKey = productId+'_'+fromLocationId+'_'+invtConfigurationRecord.getSourceStatus();
                system.debug('strUniqueKey: '+strUniqueKey);
                if(mapUniqueKeySourcePS.containsKey(strUniqueKey))
                    sObjSourcePSID = mapUniqueKeySourcePS.get(strUniqueKey);
                if (sObjSourcePSID.get('SVMXC__Quantity2__c') == null )
                    sObjSourcePSID.put('SVMXC__Quantity2__c', 0);
                Double numNewSourceQuantity = 0;
                Boolean isNegativeSourceQuantity =false;
                
                if (invtConfigurationRecord.getSourceAction() == 'Decrease') {
                     if( invtConfigurationRecord.isEnableSerialSelection() && ((Double)sObjSourcePSID.get('SVMXC__Quantity2__c') - objINVT_TransactionRecord.getActualQty()) >= 0 ) {
                        if( mapTranscationRecIdRemovedPSSerialNumber.containsKey(objINVT_TransactionRecord.getTransactionRecordId() ) ) {
                          // BAC-2203 - Changes are done as part of internal defect
                            // If serialNumber size is 0, use the quantity field value to calculate the new source quantity.
                            Double serialNumberSize =   mapTranscationRecIdRemovedPSSerialNumber.get( objINVT_TransactionRecord.getTransactionRecordId()).size();
                            if(serialNumberSize == 0.0){
                            serialNumberSize = objINVT_TransactionRecord.getActualQty();
                          }
                            numNewSourceQuantity = (Double)sObjSourcePSID.get('SVMXC__Quantity2__c') - serialNumberSize;
                        }
                        
                    } else if( !invtConfigurationRecord.isEnableSerialSelection() && ((Double)sObjSourcePSID.get('SVMXC__Quantity2__c') - objINVT_TransactionRecord.getActualQty()) >= 0 ) {
                        
                        numNewSourceQuantity = (Double)sObjSourcePSID.get('SVMXC__Quantity2__c') - objINVT_TransactionRecord.getActualQty();                                     
                    } else if(!isNegativeStockUpdateAllow()){
                        
                        addError( objINVT_TransactionRecord.getTransactionRecordId(), objTags.getTAG057(), true );
                        isNagetiveWarn = true;
                    } else{
                        createNegativeStockMap(objINVT_TransactionRecord, sObjSourcePSID, productId);
                        isNegativeSourceQuantity = true;
                        numNewSourceQuantity = 0;
                    }
                    system.debug(LoggingLevel.WARN,'numNewSourceQuantity'+numNewSourceQuantity);
                }
                if(!isNagetiveWarn){
                    if (invtConfigurationRecord.getSourceAction() == 'Increase') 
                        numNewSourceQuantity = ((double)sObjSourcePSID.get('SVMXC__Quantity2__c') + objINVT_TransactionRecord.getActualQty());


                    if (invtConfigurationRecord.getSourceAction() == 'Set'){
                        adjusetedQty = (double)sObjSourcePSID.get('SVMXC__Quantity2__c') - objINVT_TransactionRecord.getActualQty(); 
                        numNewSourceQuantity = objINVT_TransactionRecord.getActualQty();

                    }
                    if(sObjSourcePSID != null && invtConfigurationRecord.isMaintainStockHistory() && IsValidString((string)objINVT_TransactionRecord.getFromLocationId())){

                        SVMXC__Stock_History__c objHistoryRec = new SVMXC__Stock_History__c();
                        objHistoryRec.put('RecordTypeId', RTypeStockHistory);
                        objHistoryRec.put('SVMXC__Transaction_Type__c',objInventoryProcess.SVMXC__Name__c);
                        objHistoryRec.put('SVMXC__Inventory_Process__c', objInventoryProcess.Id);
                        objHistoryRec.put('SVMXC__Transaction_Quantity2__c', objINVT_TransactionRecord.getActualQty());
                        objHistoryRec.put('SVMXC__Quantity_before_change2__c', sObjSourcePSID.get('SVMXC__Quantity2__c'));
                        objHistoryRec.put('SVMXC__Quantity_after_change2__c', numNewSourceQuantity);
                        objHistoryRec.put('SVMXC__Product__c', productId);
                        objHistoryRec.put('SVMXC__Product_Stock__c', sObjSourcePSID.Id);
                        objHistoryRec.put('SVMXC__Notified_User__c', strNotifyUser);
                        objHistoryRec.put('SVMXC__Negative_Stock__c', isNegativeSourceQuantity);
                        objHistoryRec.put('SVMXC__Location__c', ((string)objINVT_TransactionRecord.getFromLocationId()));
                        objHistoryRec.put('SVMXC__Date_Changed__c', datetime.now());
                        objHistoryRec.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                        objHistoryRec.put('SVMXC__Change_Type__c', invtConfigurationRecord.getSourceAction());
                        objHistoryRec.put('SVMXC__Status__c', invtConfigurationRecord.getSourceStatus());

                        objHistoryRec.put(invtConfigurationRecord.getStockHistoryHeaderAPIName(), strHeaderRecordId);
                        system.debug(LoggingLevel.WARN,'objHistoryRec'+objHistoryRec);

                        if(invtConfigurationRecord.isMultilineTransaction()) 
                            objHistoryRec.put(invtConfigurationRecord.getStockHistoryLineAPIName(), transactionRecordId);
                        lstProductStockHistory.add(objHistoryRec);                        
                    }
                    if(isNegativeSourceQuantity){
                        mapTransactionRecordToNegativeProductStock.put(objINVT_TransactionRecord.getTransactionRecordId(), sObjSourcePSID);
                        mapNegativeProductStockToBeforeQuantity.put(sObjSourcePSID.Id, sObjSourcePSID.SVMXC__Quantity2__c);
                    }
                    sObjSourcePSID.put('SVMXC__Quantity2__c', numNewSourceQuantity);


                }
            }
        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  createSourceProductStockAndHistory: '+ex);
            addError( ex.getmessage());
        }
    }
    
    /**
    *   method for create product stock and history for target location
    **/
    private void createTargetProductStockAndHistory(INVT_TransactionRecord objINVT_TransactionRecord, List<SVMXC__Stock_History__c> lstProductStockHistory, string RTypeStockHistory)
    {
        try
        {
            Id productId =((string)objINVT_TransactionRecord.getProductId());
            Id transactionRecordId = ((string)objINVT_TransactionRecord.getTransactionRecordId());
            Id toLocationId = ((string)objINVT_TransactionRecord.getToLocationId());
            boolean isTargetlocationStockable = false;
            SVMXC__Product_Stock__c sObjTargetPSID;
            Boolean isDecresedStock = false;



            String strUniqueKey = productId+'_'+toLocationId+'_'+invtConfigurationRecord.getTargetStatus();
            if(invtConfigurationRecord.isTargetLocationFromHeader())
            {
                if(headerRecord != null)
                    isTargetlocationStockable = (Boolean)headerRecord.getSObject(invtConfigurationRecord.getRelationshipToTargetLocation()).get('SVMXC__Stocking_Location__c');

                else
                    isDecresedStock = true;
            }
            else
            {
                if(objINVT_TransactionRecord.getTransactionRecord().getSObject(invtConfigurationRecord.getRelationshipToTargetLocation()) != null)
                    isTargetlocationStockable = (Boolean)(objINVT_TransactionRecord.getTransactionRecord().getSObject(invtConfigurationRecord.getRelationshipToTargetLocation()).get('SVMXC__Stocking_Location__c'));

                else
                    isDecresedStock = true;

            }
            system.debug('isTargetlocationStockable'+isTargetlocationStockable);
            system.debug('isDecresedStock'+isDecresedStock);            system.debug('mapUniqueKeyTargetPS'+mapUniqueKeyTargetPS);
            system.debug('mapUniqueKeyDecreasedSourcePS'+mapUniqueKeyDecreasedSourcePS);
            system.debug('strUniqueKey'+strUniqueKey);
            system.debug('invtConfigurationRecord.getNumberOfLocation().ToUpperCase()'+invtConfigurationRecord.getNumberOfLocation().ToUpperCase());
            if(isTargetlocationStockable && !isDecresedStock)
            {
                if(mapUniqueKeyTargetPS.containsKey(strUniqueKey))
                    sObjTargetPSID = mapUniqueKeyTargetPS.get(strUniqueKey);
            }
            else if(invtConfigurationRecord.getNumberOfLocation() != null && invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'TWO')
            {
                strUniqueKey = productId+'_'+toLocationId+'_DECREASED';
                isDecresedStock = true;
                if(mapUniqueKeyDecreasedSourcePS.containsKey(strUniqueKey))
                    sObjTargetPSID = mapUniqueKeyDecreasedSourcePS.get(strUniqueKey);
            }
            system.debug('sObjTargetPSID'+sObjTargetPSID);
            if(sObjTargetPSID != null)
            {
                if (sObjTargetPSID.get('SVMXC__Quantity2__c') == null )
                    sObjTargetPSID.put('SVMXC__Quantity2__c', 0);
                Double numNewTargetQuantity;
                Boolean isNegativeTargetQuantity = false;
                if(invtConfigurationRecord.getNumberOfLocation() != null && invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'ONE')
                {                                                                 
                   if(invtConfigurationRecord.getSourceAction() == 'Set' && adjusetedQty > 0)                                  
                        numNewTargetQuantity = (double)sObjTargetPSID.get('SVMXC__Quantity2__c');
                }
                else
                {
                    if (invtConfigurationRecord.getTargetAction() == 'Decrease') 
                    {
                        if(((double)sObjTargetPSID.get('SVMXC__Quantity2__c') - objINVT_TransactionRecord.getActualQty()) >= 0)
                            numNewTargetQuantity = ((double)sObjTargetPSID.get('SVMXC__Quantity2__c') - objINVT_TransactionRecord.getActualQty());
                        else if(!isNegativeStockUpdateAllow())
                        {                            
                            addError(objINVT_TransactionRecord.getTransactionRecordId(), objTags.getTAG057(), true );
                            isNagetiveWarn = true;
                        }
                        else
                        {
                            createNegativeStockMap(objINVT_TransactionRecord, sObjTargetPSID, productId);
                            isNegativeTargetQuantity = true;
                            numNewTargetQuantity = 0;
                        }
                    }
                        
                    if (invtConfigurationRecord.getTargetAction() == 'Increase') 
                        numNewTargetQuantity = ((double)sObjTargetPSID.get('SVMXC__Quantity2__c') + objINVT_TransactionRecord.getActualQty());

                    if (invtConfigurationRecord.getTargetAction() == 'Set') 
                        numNewTargetQuantity = (objINVT_TransactionRecord.getActualQty());
                }
                
                if(!isNagetiveWarn)
                {
                    if(sObjTargetPSID != null && invtConfigurationRecord.isMaintainStockHistory() && IsValidString((string)objINVT_TransactionRecord.getToLocationId()) && IsValidString(invtConfigurationRecord.getTargetStatus()))
                    {
                        SVMXC__Stock_History__c objHistoryRec = new SVMXC__Stock_History__c();
                        objHistoryRec.put('RecordTypeId', RTypeStockHistory);
                        objHistoryRec.put('SVMXC__Transaction_Type__c',objInventoryProcess.SVMXC__Name__c);
                        objHistoryRec.put('SVMXC__Inventory_Process__c', objInventoryProcess.Id);
                        objHistoryRec.put('SVMXC__Transaction_Quantity2__c', objINVT_TransactionRecord.getActualQty());
                        objHistoryRec.put('SVMXC__Quantity_before_change2__c', sObjTargetPSID.get('SVMXC__Quantity2__c'));
                        if(numNewTargetQuantity != null)
                            objHistoryRec.put('SVMXC__Quantity_after_change2__c', numNewTargetQuantity);
                        objHistoryRec.put('SVMXC__Product__c', productId);
                        objHistoryRec.put('SVMXC__Product_Stock__c', sObjTargetPSID.Id);
                        objHistoryRec.put('SVMXC__Notified_User__c', strNotifyUser);
                        objHistoryRec.put('SVMXC__Negative_Stock__c', isNegativeTargetQuantity);
                        objHistoryRec.put('SVMXC__Location__c', ((string)objINVT_TransactionRecord.getToLocationId()));
                        objHistoryRec.put('SVMXC__Date_Changed__c', datetime.now());
                        objHistoryRec.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                        objHistoryRec.put('SVMXC__Change_Type__c', invtConfigurationRecord.getTargetAction());
                        objHistoryRec.put('SVMXC__Status__c', invtConfigurationRecord.getTargetStatus());
                        
                        objHistoryRec.put(invtConfigurationRecord.getStockHistoryHeaderAPIName(), strHeaderRecordId);

                        if(invtConfigurationRecord.isMultilineTransaction())
                            objHistoryRec.put(invtConfigurationRecord.getStockHistoryLineAPIName(), transactionRecordId);
                        lstProductStockHistory.add(objHistoryRec);

                    } 
                    if(isNegativeTargetQuantity){
                        mapTransactionRecordToNegativeProductStock.put(objINVT_TransactionRecord.getTransactionRecordId(), sObjTargetPSID);
                        mapNegativeProductStockToBeforeQuantity.put(sObjTargetPSID.Id, sObjTargetPSID.SVMXC__Quantity2__c);
                    }
                    if(numNewTargetQuantity != null)
                        sObjTargetPSID.put('SVMXC__Quantity2__c', numNewTargetQuantity);
                    if(objINVT_TransactionRecord.getToLocationId() != null)
                        sObjTargetPSID.put('SVMXC__Location__c', ((string)objINVT_TransactionRecord.getToLocationId()));
                    if(!isDecresedStock)
                        mapUniqueKeyTargetPS.put(strUniqueKey,sObjTargetPSID);
                    else
                        mapUniqueKeyDecreasedSourcePS.put(strUniqueKey, sObjTargetPSID);
                }
            }
        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  createTargetProductStockAndHistory: '+ex);
            addError( ex.getmessage());
        }
    }
    /**
    *   method to send mail for negative stock update
    **/
    private void sendMail(){
        
        list<Messaging.SingleEmailMessage> lstmails = new list<Messaging.SingleEmailMessage>();
        try{
            if(mapMailList.size() > 0){
                
                boolean isEmailInvolved = false;                        
                for(string strEmail :mapMailList.KeySet()){
                    
                    list<INVT_TransactionRecord> lstTransactionRecord = mapMailList.get(strEmail);
                    string strEmailBody ='';
                    strEmailBody = system.label.INVT001_TAG064;
                    for(INVT_TransactionRecord objINVT_TransactionRecord :lstTransactionRecord){
                        
                        isEmailInvolved = true;
                        strEmailBody += '\n' + objTags.getTAG022() + ' ' + objInventoryProcess.SVMXC__Name__c;
                        if(isValidString((String)headerRecord.get(INVT_Consts.FIELD_NAME_NAME)))
                            strEmailBody += '\n' + objINVT_TransactionRecord.getHeaderObjectNameFieldLabel() + ' ' + headerRecord.get(INVT_Consts.FIELD_NAME_NAME);
                        if(invtConfigurationRecord.isMultilineTransaction() && isValidString(objINVT_TransactionRecord.getNameFieldValue()))
                            strEmailBody += '\n' + objINVT_TransactionRecord.getLineObjectNameFieldLabel() + ' ' + objINVT_TransactionRecord.getNameFieldValue();   
                        strEmailBody += '\n' + objTags.getTAG024() + ' ' + objINVT_TransactionRecord.getProductName();
                        strEmailBody += '\n' + objTags.getTAG025() + ' ' + objINVT_TransactionRecord.getFromLocationName();
                        SObject objProductStock;
                        if(mapTransactionRecordToNegativeProductStock != null && mapTransactionRecordToNegativeProductStock.containsKey(objINVT_TransactionRecord.getTransactionRecordId()) && mapTransactionRecordToNegativeProductStock.get(objINVT_TransactionRecord.getTransactionRecordId()) != null)
                            objProductStock = mapTransactionRecordToNegativeProductStock.get(objINVT_TransactionRecord.getTransactionRecordId());
                        Double beforeQuantity = 0;
                        if(objProductStock.Id != null)
                        beforeQuantity = mapNegativeProductStockToBeforeQuantity.get(objProductStock.Id);
                        if(objProductStock != null){
                            strEmailBody += '\n' + objTags.getTAG026() + ' ' + objProductStock.get('SVMXC__Status__c');
                            strEmailBody += '\n' + objTags.getTAG027() + ' ' + String.valueOf(beforeQuantity);
                            strEmailBody += '\n' + objTags.getTAG028() + ' ' + objINVT_TransactionRecord.getActualQty();
                            strEmailBody += '\n' + objTags.getTAG029() + ' ' + (double)objProductStock.get('SVMXC__Quantity2__c');
                        }
                        strEmailBody += '\n' + objTags.getTAG030() + ' ' + UserInfo.getName();
                        strEmailBody += '\n' + objTags.getTAG031() + ' ' + DateTime.now() + ' '+system.label.INVT001_TAG066;
                        strEmailBody += '\n';// Fix for Defect 012925
                    }
                    strEmailBody += '\n'+ system.label.INVT001_TAG065;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(isValidString(strEmail)){
                        String[] toAddresses = new String[] {strEmail};
                        mail.setToAddresses(toAddresses);
                        mail.setSubject(objTags.getTAG020());
                        mail.setPlainTextBody(strEmailBody);
                        lstmails.add(mail);
                    }
                }
                if(isEmailInvolved && lstmails != null && lstmails.size() > 0)
                   Messaging.sendEmail(lstmails);
            }
        }
        catch(Exception ex)
        {
            System.debug( LoggingLevel.WARN, 'catch send mail'+ex);
        }
    }
   
    public string getDuplicateSerials(set<string> setDuplicateSerials)
    {
        string strValue = '';
        for(string str :setDuplicateSerials)
        {
            if(IsValidString(strValue))
                strValue += ', ' +str;
            else
                strValue = str;
        }
        return strValue;
    }
    
    private Boolean updateHeaderClosureAction( List<SVMXC__ServiceMax_Config_Data__c> headerClosureActionList ) {

        try
        {
            if( invtConfigurationRecord.isMultilineTransaction()) {                
                lineRecordList = Database.query(strLineSOQL);
            } else if(lineRecordList != null && lineRecordList.size() > 0) {
                headerRecord = lineRecordList[0];
            }
            
            if( (!invtConfigurationRecord.isMultilineTransaction() || lineRecordList == null || lineRecordList.size() == 0) && 
                !headerClosureActionList.isEmpty() ) {
                
                for( SVMXC__ServiceMax_Config_Data__c objConfigData : headerClosureActionList ) {
                    
                    COMM_SVMXC_Utils3.WraperSObject oSObject = new COMM_SVMXC_Utils3().updateSObject(headerRecord, objConfigData.SVMXC__Field_Name__c, objConfigData.SVMXC__Display_Type__c, objConfigData.SVMXC__Operand__c, objConfigData.SVMXC__Object_Name__c);
                    if(oSObject == null || oSObject.sObj == null ) {
                        return false;
                    }
                    headerRecord = oSObject.sObj;
                }           
                 
                //Integer getQueries = Limits.getQueries();
                //Integer getDmlStatements = Limits.getDmlStatements();
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(headerRecord, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert headerRecord;
                }
                else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                
            
                //emailBody += '\nupdateHeaderClosureAction: Header record, Number of queries = ' + ( Limits.getQueries() - getQueries );
                //emailBody += '\nupdateHeaderClosureAction: Header record, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );                           
            }

        }
        catch(exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  updateHeaderClosureAction: '+ex);
            addError( ex.getMessage());
            return false;

        }
        return true;
    }
    
    private Boolean processSerialSave()
    {
        System.debug( LoggingLevel.WARN, 'enter processSerialSave');


        try
        {
            if(lstToCreateSerialNumbers != null)
                lstToCreateSerialNumbers.Clear();
            string RTypeSerialHistory = getRecordType('SVMXC__Stock_History__c','Serial History');
            map<string, SVMXC__Stock_History__c> mapSerialHistory = new map<string, SVMXC__Stock_History__c>();
            if(schemaTypeProductStock != null)
            {
                updateSerialsInTarget(mapSerialHistory, RTypeSerialHistory);
                
                updateSerialsInSource(mapSerialHistory, RTypeSerialHistory);
                
                map<String, SVMXC__Product_Serial__c> mapUniquekeyProductSerialTemp = new map<String, SVMXC__Product_Serial__c>();
                
                if(lstToCreateSerialNumbers != null)
                {
                    for(SVMXC__Product_Serial__c sobj : lstToCreateSerialNumbers)
                    {
                        mapUniquekeyProductSerialTemp.put((string)sobj.get('Name'), sobj);
                        string strSerialNumberName;
                        strSerialNumberName=(string)sobj.get('Name');
                        if(strSerialNumberName.contains('^'))
                        {
                            strSerialNumberName=strSerialNumberName.substring(0,strSerialNumberName.indexOf('^'));
                            sobj.put('Name',strSerialNumberName);
                        }
                    
                    } 
                }               
                
                if(lstToCreateSerialNumbers != null && !lstToCreateSerialNumbers.isEmpty() ) 
                {
                    
                    //Integer getQueries = Limits.getQueries();
                    //Integer getDmlStatements = Limits.getDmlStatements();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    upsert lstToCreateSerialNumbers;
            
                    //emailBody += '\nprocessSerialSave: Create serial number, Number of queries = ' + ( Limits.getQueries() - getQueries );
                    //emailBody += '\nprocessSerialSave: Create serial number, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
                 
                    for(String stringKey: mapUniquekeyProductSerialTemp.keySet())
                    {

                        if(mapSerialHistory.containsKey(stringKey))
                            mapSerialHistory.get(stringKey).put('SVMXC__Product_Serial__c', mapUniquekeyProductSerialTemp.get(stringKey).Id);
                    }
                }
                if(mapSerialHistory.size() > 0)
                {
                    list<SVMXC__Stock_History__c> lstConcreteSerialHistory = new list<SVMXC__Stock_History__c>();
                    for(SVMXC__Stock_History__c objHistory :mapSerialHistory.values())
                    {
                        lstConcreteSerialHistory.add(objHistory);
                    }
                    if(lstConcreteSerialHistory.size() > 0) {
                        
                        //Integer getQueries = Limits.getQueries();
                        //Integer getDmlStatements = Limits.getDmlStatements();
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConcreteSerialHistory, COMM_SecurityUtils.Access.Upsertable)){
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstConcreteSerialHistory;
                        }
                        else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        } 
                       
            
                        //emailBody += '\nprocessSerialSave: Concrete serial history, Number of queries = ' + ( Limits.getQueries() - getQueries );
                        //emailBody += '\nprocessSerialSave: Concrete serial history, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );     
                    }                  
                }
            }
            return true;

        }
        catch (Exception ex)
        { 
            System.debug( LoggingLevel.WARN, 'catch  processSerialSave: '+ex);
            addError( ex.getmessage());
            return false;

        }

    }
    /**
    *   This method is responsible for maintain list of serial number to save in target Product and history
    **/
    private void updateSerialsInTarget(map<String, SVMXC__Stock_History__c> mapSerialHistory, String RTypeSerialHistory)
    {
        try
        {
            System.debug( LoggingLevel.WARN, 'In the block lstINVT_TransactionRecord: '+invtTransactionRecordList);
            for(INVT_TransactionRecord objINVT_TransactionRecord : invtTransactionRecordList)
            {
                if(mapValidProdRecs.containsKey(objINVT_TransactionRecord.getProductId()) && objINVT_TransactionRecord.isEnableSerialSelection())
                {                        
                    if( objINVT_TransactionRecord.getActualQty() > 0)
                    {
                        System.debug( LoggingLevel.WARN, 'In the block target serial update getActualQty: '+objINVT_TransactionRecord.getActualQty() );
                        SVMXC__Product_Stock__c sObjTargetPSID = new SVMXC__Product_Stock__c();
                        
                        if(invtConfigurationRecord != null && invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'ONE')
                        {
                            System.debug( LoggingLevel.WARN, 'number of location is one: ');
                            System.debug( LoggingLevel.WARN, 'invtConfigurationRecord.getSourceAction(): '+invtConfigurationRecord.getSourceAction());
                            if (invtConfigurationRecord.getSourceAction() == 'Set' || invtConfigurationRecord.getSourceAction() == 'Increase'){   
                                System.debug( LoggingLevel.WARN, 'mapUniqueKeySourcePS: '+mapUniqueKeySourcePS);
                                String strUniqueKey = (string)objINVT_TransactionRecord.getProductId()+'_'+(String)objINVT_TransactionRecord.getFromLocationId()+'_'+invtConfigurationRecord.getSourceStatus();
                                if(mapUniqueKeySourcePS.containskey(strUniqueKey) && mapUniqueKeySourcePS.get(strUniqueKey) != null)
                                    sObjTargetPSID = mapUniqueKeySourcePS.get(strUniqueKey);
                            }
                            else
                            {
                                System.debug( LoggingLevel.WARN, 'mapUniqueKeyTargetPS: '+mapUniqueKeyTargetPS);
                                String strUniqueKey = (string)objINVT_TransactionRecord.getProductId()+'_'+(String)objINVT_TransactionRecord.getFromLocationId()+'__ADJUSTED';
                                if(mapUniqueKeyTargetPS.containskey(strUniqueKey) && mapUniqueKeyTargetPS.get(strUniqueKey) != null )
                                    sObjTargetPSID = mapUniqueKeyTargetPS.get(strUniqueKey);
                            }
                        }
                        if(invtConfigurationRecord != null && invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'TWO')
                        {
                            if(objINVT_TransactionRecord.getToLocationId() != null && ((String)objINVT_TransactionRecord.getToLocationId()).length() > 0)
                            {
                                String strUniqueKey = (string)objINVT_TransactionRecord.getProductId()+'_'+(String)objINVT_TransactionRecord.getToLocationId()+'_'+invtConfigurationRecord.getTargetStatus();
                                if(mapUniqueKeyTargetPS.containsKey(strUniqueKey) && mapUniqueKeyTargetPS.get(strUniqueKey) != null)
                                    sObjTargetPSID = mapUniqueKeyTargetPS.get(strUniqueKey);
                            }
                            else
                            {
                                String strUniqueKey = (string)objINVT_TransactionRecord.getProductId()+'_'+(String)objINVT_TransactionRecord.getFromLocationId()+'_DECREASED';
                                if(mapUniqueKeyDecreasedSourcePS.containskey(strUniqueKey) && mapUniqueKeyDecreasedSourcePS.get(strUniqueKey) != null) 
                                    sObjTargetPSID = mapUniqueKeyDecreasedSourcePS.get(strUniqueKey);
                            }
                        }
                        map<string,SVMXC__Product_Serial__c> lstTargetSN = new map<string,SVMXC__Product_Serial__c>();
                        if(mapTranscationRecordToSerial.containskey(((string)objINVT_TransactionRecord.getTransactionRecordId())) && mapTranscationRecordToSerial.get(((string)objINVT_TransactionRecord.getTransactionRecordId())) != null )
                            lstTargetSN = mapTranscationRecordToSerial.get(((string)objINVT_TransactionRecord.getTransactionRecordId()));
                            
                         System.debug( LoggingLevel.WARN, 'In the block target serial update serial number: '+lstTargetSN);
                         System.debug( LoggingLevel.WARN, 'In the block target serial update serial number product stock: '+sObjTargetPSID);
                        for(SVMXC__Product_Serial__c sObjTargetSN : lstTargetSN.values()) {
                                                        
                            if( sObjTargetSN == null ) continue;
                            
                            if( invtConfigurationRecord != null && invtConfigurationRecord.isMaintainSerialHistory() && !((String)sObjTargetSN.get('SVMXC__Product_Stock__c') == sObjTargetPSID.Id))
                            {
                                SVMXC__Stock_History__c objSerialHistory = new SVMXC__Stock_History__c();
                                objSerialHistory.put('RecordTypeId', RTypeSerialHistory);
                                objSerialHistory.put('SVMXC__Transaction_Type__c',objInventoryProcess.SVMXC__Name__c);
                                objSerialHistory.put('SVMXC__Inventory_Process__c', objInventoryProcess.Id);
                                objSerialHistory.put('SVMXC__From_Product_Stock__c', (String)sObjTargetSN.get('SVMXC__Product_Stock__c'));
                                objSerialHistory.put('SVMXC__To_Product_Stock__c', sObjTargetPSID.Id);
                                objSerialHistory.put('SVMXC__Date_Changed__c', datetime.now());
                                objSerialHistory.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                                if(!invtConfigurationRecord.isMultilineTransaction() && IsValidString(invtConfigurationRecord.getStockHistoryHeaderAPIName()))
                                    objSerialHistory.put(invtConfigurationRecord.getStockHistoryHeaderAPIName(), strHeaderRecordId);
                                if(invtConfigurationRecord.isMultilineTransaction() && IsValidString(invtConfigurationRecord.getStockHistoryLineAPIName()))
                                    objSerialHistory.put(invtConfigurationRecord.getStockHistoryLineAPIName(), objINVT_TransactionRecord.getTransactionRecordId());
                                mapSerialHistory.put((String)sObjTargetSN.get('Name'), objSerialHistory);
                            }
                            
                            sObjTargetSN.put('SVMXC__Product_Stock__c', sObjTargetPSID.Id);
                            sObjTargetSN.put('SVMXC__Product__c', ((string)objINVT_TransactionRecord.getProductId()));
                            sObjTargetSN.put('SVMXC__Active__c', true);
                            System.debug( LoggingLevel.WARN, 'In the block target serial update serial number: '+sObjTargetSN);
                            lstToCreateSerialNumbers.add(sObjTargetSN);
                        }
                    }
                }
            }
        }
        catch(exception ex)
        {
            System.debug( LoggingLevel.WARN, 'catch  updateSerialsInTarget: '+ex);
            addError( ex.getMessage());
        }
    }
    /**
    *   This method is responsible for update the list of serial number to save in source Product and history
    **/
    private void updateSerialsInSource(map<string, SVMXC__Stock_History__c> mapSerialHistory, String RTypeSerialHistory)
    {

        try
        {
            if(invtConfigurationRecord != null && invtConfigurationRecord.getNumberOfLocation().ToUpperCase() == 'ONE' && invtConfigurationRecord.getSourceAction() == 'Set')
            {
                System.debug( LoggingLevel.WARN, 'In the block');
                for(Id transcationRecId :mapTranscationRecIdSourcePSSerialNumber.keyset())
                {
                    for(SVMXC__Product_Serial__c sObjSourceSN : mapTranscationRecIdSourcePSSerialNumber.get(transcationRecId).values())
                    {
                        if(invtConfigurationRecord.isMaintainSerialHistory())
                        {
                            SVMXC__Stock_History__c objSerialHistory = new SVMXC__Stock_History__c();
                            objSerialHistory.put('RecordTypeId', RTypeSerialHistory);
                            objSerialHistory.put('SVMXC__Transaction_Type__c',objInventoryProcess.SVMXC__Name__c);
                            objSerialHistory.put('SVMXC__Inventory_Process__c', objInventoryProcess.Id);
                            objSerialHistory.put('SVMXC__From_Product_Stock__c', (String)sObjSourceSN.get('SVMXC__Product_Stock__c'));
                            //objSerialHistory.put('SVMXC__To_Product_Stock__c', mapUniqueKeyTargetPS.get(strKey).id);
                            objSerialHistory.put('SVMXC__Date_Changed__c', datetime.now());
                            objSerialHistory.put('SVMXC__Changed_By__c',UserInfo.getUserId());
                            objSerialHistory.put(invtConfigurationRecord.getStockHistoryLineAPIName(), transcationRecId);
                            if(!invtConfigurationRecord.isMultilineTransaction() && IsValidString(invtConfigurationRecord.getStockHistoryHeaderAPIName()))
                                objSerialHistory.put(invtConfigurationRecord.getStockHistoryHeaderAPIName(), strHeaderRecordId);
                            if(invtConfigurationRecord.isMultilineTransaction() && IsValidString(invtConfigurationRecord.getStockHistoryLineAPIName())){
                                if(mapTransactionRecordIdTransactionRecord.containskey(transcationRecId)){
                                    INVT_TransactionRecord objINVT_TransactionRecord = mapTransactionRecordIdTransactionRecord.get(transcationRecId);

                                    String strUniqueKey = (string)objINVT_TransactionRecord.getProductId()+'_'+(String)objINVT_TransactionRecord.getToLocationId()+'_'+invtConfigurationRecord.getTargetStatus();
                                    if(mapUniqueKeyTargetPS.containsKey(strUniqueKey) && mapUniqueKeyTargetPS.get(strUniqueKey) != null ){
                                        objSerialHistory.put('SVMXC__To_Product_Stock__c', mapUniqueKeyTargetPS.get(strUniqueKey).Id);
                                        sObjSourceSN.put('SVMXC__Product_Stock__c', mapUniqueKeyTargetPS.get(strUniqueKey).Id);
                                        lstToCreateSerialNumbers.add(sObjSourceSN);
                                    }
                                }
                            }    
                            if(invtConfigurationRecord.isMaintainSerialHistory())
                                mapSerialHistory.put((String)sObjSourceSN.get('Name'), objSerialHistory);
                        }
                        System.debug( LoggingLevel.WARN, 'lstToCreateSerialNumbers: '+lstToCreateSerialNumbers+' history: '+mapSerialHistory);
                    }
                }
            }
        }
        catch(exception ex)
        {
            System.debug( LoggingLevel.WARN, 'catch  updateSerialsInSource: '+ex);
            addError( ex.getMessage());
        }
    }
    
    private Boolean updateRelatedUpdateAction( List<SVMXC__ServiceMax_Config_Data__c> relatedClosureActionList ) {

        try
        {
            for(SVMXC__ServiceMax_Config_Data__c objConfigData :relatedClosureActionList)
            {
                string strIds = '';
                for(INVT_TransactionRecord objINVT_TransactionRecord :invtTransactionRecordList)
                {
                    if(strIds.length() > 0 && objINVT_TransactionRecord.getTransactionRecord().get(objConfigData.SVMXC__Lookup_Field_API_Name__c) != null && ((string)objINVT_TransactionRecord.getTransactionRecord().get(objConfigData.SVMXC__Lookup_Field_API_Name__c)).length() > 0)
                        strIds += ', ';
                    strIds += objINVT_TransactionRecord.getTransactionRecord().get(objConfigData.SVMXC__Lookup_Field_API_Name__c) != null? '\''+ (String)objINVT_TransactionRecord.getTransactionRecord().get(objConfigData.SVMXC__Lookup_Field_API_Name__c) + '\'' : '' ;
                }
                if(strIds.length() > 0)
                {
                    list<sObject> lstsObj = database.query('select id, ' + objConfigData.SVMXC__Field_Name__c + ' from '+ objConfigData.SVMXC__Object_Name__c + ' where id IN ('+ strIds + ')');
                    if(lstsObj != null)
                    {
                        for(sObject o :lstsObj)
                        {
                            Double actualQty = 0;
                                                        
                            Boolean hasLookupField = false;
                            for(INVT_TransactionRecord objINVT_TransactionRecord :invtTransactionRecordList)
                            {
                                if(o.get('Id') == objINVT_TransactionRecord.getTransactionRecord().get(objConfigData.SVMXC__Lookup_Field_API_Name__c) )
                                {
                                    actualQty += objINVT_TransactionRecord.getActualQty();
                                    hasLookupField = true;
                                }
                            }
                            
                            if( hasLookupField ) {
                                
                                if(objConfigData.SVMXC__Operator__c != null && objConfigData.SVMXC__Operator__c.ToUpperCase() == 'SET')
                                    o.put(objConfigData.SVMXC__Field_Name__c, actualQty );
                                else if(objConfigData.SVMXC__Operator__c != null && objConfigData.SVMXC__Operator__c.ToUpperCase() == 'INCREASE')
                                    o.put(objConfigData.SVMXC__Field_Name__c, (o.get(objConfigData.SVMXC__Field_Name__c) != null ? (double)o.get(objConfigData.SVMXC__Field_Name__c) : 0) + actualQty );
                                else if(objConfigData.SVMXC__Operator__c != null && objConfigData.SVMXC__Operator__c.ToUpperCase() == 'DECREASE')
                                    o.put(objConfigData.SVMXC__Field_Name__c, (o.get(objConfigData.SVMXC__Field_Name__c) != null ? (double)o.get(objConfigData.SVMXC__Field_Name__c) : 0) - actualQty );
                            }
                        }
                                               
                        //Integer getQueries = Limits.getQueries();
                        //Integer getDmlStatements = Limits.getDmlStatements();
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsObj, COMM_SecurityUtils.Access.Upsertable)){
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert lstsObj;
                        }
                        else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        } 
                        
            
                        //emailBody += '\nUpdate Related Update Action, Number of queries = ' + ( Limits.getQueries() - getQueries );
                        //emailBody += '\nUpdate Related Update Action, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );                       
                    }   
                }
            }
            return true;

        }
        catch(exception ex)
        {
            System.debug( LoggingLevel.WARN, 'catch  updateRelatedUpdateAction: '+ex);
            addError( ex.getMessage());
            return false;

        }
    }
    
    private Boolean updateHeaderAndLineClosureAction( List<SVMXC__ServiceMax_Config_Data__c> headerClosureActionList, 
        List<SVMXC__ServiceMax_Config_Data__c> lineClosureActionList ) {
        
        Boolean anyLineOpen = false;           
                    
        try {
            List<SObject> lstCloneLine = new List<SObject>();
            lineRecordList.clear();
            Boolean isAllLineZero = true;
            for( INVT_TransactionRecord invtTransactionRecord : invtTransactionRecordList ) {
                
                if( invtTransactionRecord.getActualQty() > 0 || 
                    ( invtTransactionRecord.getActualQty() == 0 && 
                    ( invtTransactionRecord.doCloseLine() || 

                        invtConfigurationRecord.getSourceAction() == INVT_Consts.SOURCE_ACTION_SET || 
                        invtConfigurationRecord.getTargetAction() == INVT_Consts.SOURCE_ACTION_SET ) ) ) {
                                                
                    isAllLineZero = false;
                    Double orgMinusActual = invtTransactionRecord.getOriginalQty() - invtTransactionRecord.getActualQty();
                    if( orgMinusActual <= 0 || invtTransactionRecord.doCloseLine() || 
                        ( orgMinusActual > 0 && !invtTransactionRecord.doCloseLine() ) ) {                     
                          
                        if( orgMinusActual > 0 && !invtTransactionRecord.doCloseLine() ) {
                            
                            SObject cloneLineObject = invtTransactionRecord.getTransactionRecord().clone( false, true );
                            cloneLineObject.put( invtConfigurationRecord.getOriginalQuantityAPIName(), orgMinusActual );
                            cloneLineObject.put( invtConfigurationRecord.getStockResultUpdateFieldAPIName(), '' );
                            cloneLineObject.put( invtConfigurationRecord.getSerialNumberFieldAPIName(), '' );
                            
                            if( invtConfigurationRecord.isActualQuantityEditable() ) {
                                cloneLineObject.put( invtConfigurationRecord.getActualQuantityAPIName(), null);
                            }   
                            lstCloneLine.add( cloneLineObject );
                            anyLineOpen = true;
                        }
                        
                        if( lineClosureActionList != null && lineClosureActionList.size() > 0 ) {
                            
                            for( SVMXC__ServiceMax_Config_Data__c configData : lineClosureActionList ) {
                                
                                COMM_SVMXC_Utils3.WraperSObject oWraperSObject = new COMM_SVMXC_Utils3().updateSObject( invtTransactionRecord.getTransactionRecord(), configData.SVMXC__Field_Name__c, configData.SVMXC__Display_Type__c, configData.SVMXC__Operand__c, configData.SVMXC__Object_Name__c );
                                if( oWraperSObject == null || oWraperSObject.sObj == null ) {
                                    addError(invtTransactionRecord.getTransactionRecordId(), 'Line closure action update failed : ' + invtTransactionRecord.getNameFieldValue() , false );
                                    return false;
                                } 
                                system.debug('ConfigData'+configData.SVMXC__Field_Name__c);
                                system.debug('ConfigData'+configData.SVMXC__Operand__c);
                                system.debug('ConfigData'+configData.SVMXC__Object_Name__c);
                                system.debug('oWraperSObject'+oWraperSObject); 
                                invtTransactionRecord.setTransactionRecord(oWraperSObject.sObj);                                
                            }
                        }
                    }                    

                    if(invtConfigurationRecord.isActualQuantityEditable()) {
                        invtTransactionRecord.getTransactionRecord().put( invtConfigurationRecord.getActualQuantityAPIName(), invtTransactionRecord.getActualQty() );
                    }
                    
                    lineRecordList.add( invtTransactionRecord.getTransactionRecord() );
                }                
            }
            system.debug('isAllLineZero'+isAllLineZero);
            if( isAllLineZero ) {
                
                addError( oCommUtils.getTAG058());
                return false;
            }
            
            for( SObject clonedObject : lstCloneLine ) { lineRecordList.add( clonedObject ); }
            system.debug('lineRecordList'+lineRecordList);           
                        
            //Integer getQueries = Limits.getQueries();
            //Integer getDmlStatements = Limits.getDmlStatements();
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lineRecordList, COMM_SecurityUtils.Access.Upsertable)){
            //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            upsert lineRecordList;
            }
            else{
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 

            
            
            //emailBody += '\nUpdate Line closure Action, Number of queries = ' + ( Limits.getQueries() - getQueries );
            //emailBody += '\nUpdate Line closure Action, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
        }
        catch(exception ex)
        {
            System.debug( LoggingLevel.WARN, 'catch  updateHeaderAndLineClosureAction: '+ex);
            addError( ex.getMessage());
            return false;
        }
        
        if( anyLineOpen ) return true;
        
        return updateHeaderClosureAction( headerClosureActionList );
    }
    
    private void addError(string strValue)
    {
        isErrorAdded = true;
        INVT_WrapperDef.SVMXMessage objMessage = new INVT_WrapperDef.SVMXMessage(strValue, '', 'ERROR');
        svmxMessageList.add(objMessage);
        isRollBack = true;
        
    }
    
    private void addError( String id, String message, Boolean isError ) {
        
        if( isError ) { addError( message ); } 
        
        if( !idResultListMap.containsKey( id ) ) {
            idResultListMap.put( id, new List<String>() );
        }
        
        idResultListMap.get(id).add(message); 
    }

    private void addWarn(string strValue)
    {
        INVT_WrapperDef.SVMXMessage objMessage = new INVT_WrapperDef.SVMXMessage(strValue, '', 'WARN');
        svmxMessageList.add(objMessage);
        isRollBack = true;
    }
    
    private List<String> getAllowedStockStatusValuesForInventory(){

        
        if(settingObjectMap != null && settingObjectMap.get('GBL004') != null && settingObjectMap.get('GBL004').SVMXC__Internal_Value__c != null && settingObjectMap.get('GBL004').SVMXC__Internal_Value__c.length() > 0)
            return settingObjectMap.get('GBL004').SVMXC__Internal_Value__c.split(',');
        return new List<String>();
    }
    
    private boolean isNegativeStockUpdateAllow()
    {
        if(settingObjectMap.get('GBL002') != null && settingObjectMap.get('GBL002').SVMXC__Internal_Value__c.ToUpperCase() == 'TRUE')
            return true;
        return false;
    }
    
    private boolean isValidString(String strValue)
    {
        if(strValue != null && strValue.length() > 0)
            return true;
        else
            return false;
    }
    
     private String getRecordType( String objectName, String recordTypeName) {
        
        String strReturnValue;
        if( recordTypeMap.containsKey(objectName) ) {
            
            Map<String,String> objectRecordTypeMap = recordTypeMap.get(objectName);
            if( objectRecordTypeMap.containsKey(recordTypeName) ) {
                strReturnValue = objectRecordTypeMap.get(recordTypeName);
            }
        }
        return strReturnValue;
    }
    
}