/* Security Scanned */
/**
 * This class contains on load validations for inventory.
 */
public with sharing class INVT_ValidationEngine {       
    
    /*
     * Private instance variable to hold Common service utils class instance.
     */ 
    private COMM_SVMXC_Utils3 oCommUtils;
    
    /*
     * Private instance variable to hold servicemax process object instance.
     */
    private SVMXC__ServiceMax_Processes__c oInvProcess; 
    
    /*
     * Private instance variable to hold inventory api engine. This class 
     * instance is more used to initialize data which are required for save operation. 
     */
    private INVT_InventoryAPIEngine invtInventoryAPIEngine;
            
    /*
     * Private instance variable to hold boolean flag for valid line.
     */
    private Boolean isValidLine = true;
    
    /*
     * Private instance variable to hold boolean flag for process complete.
     */
    private Boolean isProcessComplete = true;       
    
    /*
     * Private instance variable to hold header record object reference.
     */
    private SObject headerRecord;
    
    /*
     * Private instance variable to hold header id passed by caller.
     */
    private String strHeaderRecordId;
    
    /*
     * Private instance variable to hold header object name.
     */
    private String headerName;
    
    /*
     * Private instance variable to hold line field name.
     */
    private String lineNameField;
    
    /*
     * Private instance variable to hold  label of name field of line object
     */
    private String lineNameFieldLabel;
    
    /*
     * Private instance variable to hold  label of name field of header object
     */
    private String headerNameFieldLabel;
    
    /*
     * Private instance variable to hold list of svmx messages.
     */
    private List<INVT_WrapperDef.SVMXMessage> responceList;
    
    /*
     * Private instance variable to hold configuration record informations.
     */
    private INVT_ConfigurationRecord invtConfigurationRecord;
    
    private Map<Id,List<String>> idResultListMap = new Map<Id,List<String>>();
    
    /**
     * Class constructor to create instance of this class.
     */
    public INVT_ValidationEngine( INVT_InventoryAPIEngine invtInventoryAPIEngine ) {
        
        this.invtInventoryAPIEngine = invtInventoryAPIEngine;
        responceList = new List<INVT_WrapperDef.SVMXMessage>();
        oCommUtils = new COMM_SVMXC_Utils3( true );
    }
    
    /**
     * Returns true if the value passed as argument is not null or empty, returns false otherwise.
     */
    private Boolean isValidString( String value ) {
        return (value != null && !value.trim().equalsIgnoreCase(INVT_Consts.EMPTY_STRING) );
    }
    
    /**
     * Returnd process complete status.
     */
    public Boolean isProcessComplete() {
        return isProcessComplete;
    }
    
    public Map<Id,List<String>> getRecordStatusMap() {
        return idResultListMap;
    }
    
    /**
     * This public method executes on load validation for given header id, inventory id and list of line id's.
     *
     * Returns list of SVMXMessage object instance in case of any error occured 
     * while processing validation, Otherwise returns an empty list.
     */
    public List<INVT_WrapperDef.SVMXMessage> onLoadValidation( String strHeaderRecordId, String inventoryProcessId, List<Id> lstIdsLine ) {
    
        System.debug( LoggingLevel.DEBUG, 'onLoadValidation() - enter, Header Id = ' + strHeaderRecordId + '; Inventory process ID = ' + inventoryProcessId );
        
        this.strHeaderRecordId = strHeaderRecordId;
        try {
        
            if( !isValidString( strHeaderRecordId ) || !isValidString( inventoryProcessId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'onLoadValidation() : Invalid header id or inventory process id received' );
                addError( oCommUtils.getTAG038() );
                return responceList;
            }
            
            //Integer getQueries = Limits.getQueries();
            //Integer getDmlStatements = Limits.getDmlStatements();
            
            init( inventoryProcessId );
            
            //INVT_InventoryAPIEngine.emailBody += '\n\nInit inventory process, Number of queries = ' + ( Limits.getQueries() - getQueries );
            //INVT_InventoryAPIEngine.emailBody += '\n\nInit inventory process, Number of DML statements = ' + ( Limits.getDmlStatements() - getDmlStatements );
                                            
            System.debug( LoggingLevel.INFO, 'onLoadValidation() : Retrieving global describe objects' );
            
            // Inventory Configuration field value validation.
            
            if( invtConfigurationRecord.getSerialNumberFieldAPIName() == null && invtConfigurationRecord.isEnableSerialSelection() ) {
                
                System.debug( LoggingLevel.ERROR, 'onLoadValidation() : Invalid Serial number field API name.' );
                addError( System.Label.INVT001_TAG069 );
                return responceList;
            }
                        
            if( invtConfigurationRecord.getStockResultUpdateFieldAPIName() == null ) {
                
                System.debug( LoggingLevel.ERROR, 'onLoadValidation() : Invalid Transaction results API name' );                
                addError( System.Label.INVT001_TAG070 );
                return responceList;
            }
                
            /*
             * Building map of object name and global describe object instance. 
             */
            Map<String, Schema.SObjectType> mapAllObjectDescribe = getGlobalDescribe();
            
            if( oInvProcess != null && isValidString( oInvProcess.Id ) ) {  
                                    
                Schema.Sobjecttype schemaSobjectType = mapAllObjectDescribe.get( (String) invtConfigurationRecord.getParentObjectName() );
                map<String,Schema.SObjectField> objectHeaderFieldMap = getObjectFieldMap(schemaSobjectType, (String) invtConfigurationRecord.getParentObjectName());
                map<String,Schema.SObjectField> objectLineFieldMap = null;
                
                /*
                 * If multilune transaction is enabled, retrieve child object name.
                 */
                if( invtConfigurationRecord.isMultilineTransaction() ) {
                    
                    schemaSobjectType = mapAllObjectDescribe.get(invtConfigurationRecord.getChildObjectName() );
                    objectLineFieldMap = getObjectFieldMap(schemaSobjectType, invtConfigurationRecord.getChildObjectName());                    
                }
                
                initLables( schemaSobjectType, objectHeaderFieldMap, objectLineFieldMap);
                /*
                 * Initializing header and line records.
                 */
                if( isProcessComplete ) {
                    
                    System.debug( LoggingLevel.INFO, 'onLoadValidation() : Initializing header and line records' );
                    
                    if( !initHeaderRecord( mapAllObjectDescribe ) ) { return responceList; }
                    /*
                     * Entry criteria validation.
                     */
                    if( !responceList.isEmpty() ) { return responceList; }
                    
                    initLineRecords( mapAllObjectDescribe, lstIdsLine );
                }
                
                if( isProcessComplete && responceList.isEmpty() ) {
                    
                    validateLocationRelationship();
                    validateLineRecords(); 
                }
                
            } else {
                
                System.debug( LoggingLevel.ERROR, 'onLoadValidation() : Invalid inventory process or inventory process id.' );
                addError( oCommUtils.getTAG039() );
            }           
        }       
        catch(Exception ex) {
            
            System.debug( LoggingLevel.ERROR, 'onLoadValidation() : ' + ex.getStackTraceString()  );
            addError( ex.getMessage() );
        }
        
        return responceList;
    }   
    
    
    private Map<String,Schema.SObjectField> getObjectFieldMap(Schema.Sobjecttype schemaSobjectType, String strObjectName ) {
        
        Map<String,Schema.SObjectField> objectFieldMap = oCommUtils.mapObjectFieldmap.get( strObjectName );
        
        /*
         * Initializing line field name from schema.
         */
        if( schemaSobjectType != null ) {
             
            if( objectFieldMap == null || objectFieldMap.isEmpty() ) {
                objectFieldMap = schemaSobjectType.getDescribe().fields.getMap();
            }                    
        }
        return objectFieldMap;
    }
    
    /**
     * This private method used to validate line records.
     */
    private void validateLineRecords() {
        
        System.debug( LoggingLevel.INFO, 'validateLineRecords() : Validating line records.' );
        
        if( !isProcessComplete ) {
            
            System.debug( LoggingLevel.WARN, 'validateLineRecords() : Skipping line record validation, isProcessComplete : ' + isProcessComplete );
            return;
        }
                
        List<SObject> lineRecordList = invtInventoryAPIEngine.getLineRecordList();
        
        if( ( lineRecordList == null || lineRecordList.isEmpty() ) && (oInvProcess.SVMXC__Child_Error_Msg__c != null && oInvProcess.SVMXC__Child_Error_Msg__c != '')) {
            
            System.debug( LoggingLevel.ERROR, 'validateLineRecords() : Null or empty line record list.' );
            addError( oInvProcess.SVMXC__Child_Error_Msg__c );
            return;
        }
                
        /*
         * Validation failes for following conditions
         * 1. Number of locations set to TWO and source location API name is invalid.
         * 2. Source location API name is invalid.
         */
        if( invtInventoryAPIEngine.isInventoryEnabled() && invtInventoryAPIEngine.isLocationInvolved() && 
            (!((invtConfigurationRecord.getNumberOfLocation().ToUpperCase().equalsIgnoreCase( INVT_Consts.NUMBER_OF_LOCATIONS_TWO ) && isValidString(invtConfigurationRecord.getTargetLocationAPIName()) ) || 
                !invtConfigurationRecord.getNumberOfLocation().ToUpperCase().equalsIgnoreCase( INVT_Consts.NUMBER_OF_LOCATIONS_TWO ) ) || !isValidString(invtConfigurationRecord.getSourceLocationAPIName()))) {
            
            System.debug( LoggingLevel.ERROR, 'validateLineRecords() : Invalid source or target location API name.' );
            //addError( oCommUtils.getTAG038() + ': Source location API name='+invtConfigurationRecord.getSourceLocationAPIName() +'; Target location API name=' + invtConfigurationRecord.getTargetLocationAPIName() );
            isProcessComplete = false;
            return;
        }
        
        System.debug( LoggingLevel.DEBUG, 'validateLineRecords() : Starting line record validation.' );
        
        List<INVT_TransactionRecord> invtTransactionRecordList = new List<INVT_TransactionRecord>();
        
        for( SObject lineRecord: lineRecordList ) {
        
            /*
             * Validation failes for following conditions.
             * 1. Invalid product field API name.
             * 2. User enter quantity is disabled and Invalid actual quantity API name.
             * 3. Invalid original quantity API name. 
             */
            if( isValidString(invtConfigurationRecord.getProductFieldAPIName()) && 
                ( !invtConfigurationRecord.isActualQuantityEditable() || isValidString(invtConfigurationRecord.getActualQuantityAPIName()) ) && 
                isValidString(invtConfigurationRecord.getOriginalQuantityAPIName()) ) {
                
                isValidLine = true;
                INVT_TransactionRecord invtTransactionRecord = new INVT_TransactionRecord( lineRecord );                
                
                updateInvtTransactionRecord( invtTransactionRecord, lineRecord );
                
                List<String> serialNumberList = invtTransactionRecord.getSerialNumberList();
                
                if(  serialNumberList != null && !serialNumberList.isEmpty() && !invtConfigurationRecord.isEnableSerialSelection() && 
                    invtTransactionRecord.isEnableSerialSelection() ) {
                
                    System.debug( LoggingLevel.ERROR, 'updateInvtTransactionRecord() : Serial number field must be empty.' );
                    addError( invtTransactionRecord.getTransactionRecordId(), System.Label.INVT001_TAG073, false );
                    invtTransactionRecord.getSerialNumberList().clear();
                    isValidLine = false;
                } else if(  serialNumberList != null && !serialNumberList.isEmpty() && !invtConfigurationRecord.isEnableSerialSelection() && 
                    !invtTransactionRecord.isEnableSerialSelection() ) {
                    
                    invtTransactionRecord.getSerialNumberList().clear();
                }

                if(invtConfigurationRecord.isMultilineTransaction() ) {
                
                    if( isValidString( invtConfigurationRecord.getRelationshipNameToProduct() ) )  {
                    
                        sobject nameToProduct = lineRecord.getSObject( invtConfigurationRecord.getRelationshipNameToProduct() );
                        if( nameToProduct != null ) {
                            
                            Product2 product2Record = (Product2) nameToProduct;
                            invtInventoryAPIEngine.getProduct2List().add( product2Record );
                            invtInventoryAPIEngine.getProduct2Map().put( product2Record.Id, product2Record );                            
                            
                            if( !invtInventoryAPIEngine.isInventoryEnabled() || 
                                ( product2Record.get( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING ) != null && 
                                (Boolean) product2Record.get( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING ) && 
                                product2Record.get( INVT_Consts.FIELD_NAME_STOCKABLE ) != null && (Boolean)product2Record.get( INVT_Consts.FIELD_NAME_STOCKABLE ) ) ) {
                
                                invtInventoryAPIEngine.getSerializedProduct2Map().put(product2Record.Id, product2Record);
                            }                                                       
                        } else {
                            System.debug( LoggingLevel.ERROR, 'validateLineRecords() : Name to product not exists in line record.' );
                            addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG051()+ ': ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ), false );
                            isValidLine = false;
                        }
                    } else {
                        
                        System.debug( LoggingLevel.ERROR, 'validateLineRecords() : Invalid relationship name to product.' );
                        isProcessComplete = false;        
                        //addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG038() + ': ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ), false );                
                    }
                }
                
                if( isValidLine ) {
                    
                    invtTransactionRecordList.add( invtTransactionRecord );                    
                }
                
                invtInventoryAPIEngine.getINVTTransactionRecordList().add( invtTransactionRecord );
                
            } else {
                System.debug( LoggingLevel.ERROR, 'validateLineRecords() : Invalid product field API name or Invalid origianl/actual quantity' );
                isProcessComplete = false;
                //addError( lineRecord.Id, oCommUtils.getTAG038() + ': ' + ( isValidString( lineNameField ) ? (String) lineRecord.get( lineNameField ) : '' ), false );
            }                               
        }       
        
        invtInventoryAPIEngine.setInvtTransactionRecordList( invtTransactionRecordList );
    }
    
    /**
     * This method used to update transection record from line record.
     */
    private void updateInvtTransactionRecord( INVT_TransactionRecord invtTransactionRecord, SObject lineRecord ) {
                    
        invtTransactionRecord.setEnableSerialSelection( invtConfigurationRecord.isEnableSerialSelection() );
        
        SObject nameToProduct = lineRecord.getSObject(invtConfigurationRecord.getRelationshipNameToProduct());
        
        invtTransactionRecord.setLineObjectNameFieldLabel(lineNameFieldLabel);
        invtTransactionRecord.setHeaderObjectNameFieldLabel(headerNameFieldLabel);        
        invtTransactionRecord.setProductId( (String) lineRecord.get( invtConfigurationRecord.getProductFieldAPIName() ) );
        invtTransactionRecord.setOriginalQty( String.valueOf( lineRecord.get( invtConfigurationRecord.getOriginalQuantityAPIName() ) ) );
        invtTransactionRecord.setTransactionRecordId( lineRecord.Id );
        
        if( isValidString( lineNameField ) ) {
            invtTransactionRecord.setNameFieldValue( (String) lineRecord.get( lineNameField ) );
        }
        
        if( nameToProduct != null ) {
        
            invtTransactionRecord.setProductName( (String) nameToProduct.get(invtConfigurationRecord.getRelatedProductField() ) );
            if( nameToProduct.get( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING ) != null ) {
                invtTransactionRecord.setEnableSerialSelection( (Boolean) nameToProduct.get( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING ) );
            }
        } 
        
        if( !isValidString(invtTransactionRecord.getProductName() ) ) {
            
            isProcessComplete = false;
            //addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG038() + ': ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ), false );
        }
        
        if( invtConfigurationRecord.getSerialNumberFieldAPIName() != null ) {
            
            String serialNumberString = (String) lineRecord.get( invtConfigurationRecord.getSerialNumberFieldAPIName() );
            
            if( serialNumberString != null ) {
                
                List<String> serialNumberList = serialNumberString.split( INVT_Consts.SEPARATOR_COMMA );
                for( Integer i = 0; i < serialNumberList.size(); i++ ) {
                    serialNumberList[i] = serialNumberList[i].trim();
                }
                invtTransactionRecord.setSerialNumberList( serialNumberList );
            } else if( invtConfigurationRecord.isEnableSerialSelection() && invtTransactionRecord.isEnableSerialSelection() ) {   
            
                System.debug( LoggingLevel.ERROR, 'updateInvtTransactionRecord() : Empty serial number field value.' );            
                addError( invtTransactionRecord.getTransactionRecordId(), System.Label.INVT001_TAG072, false );
                isValidLine = false;             
            }        
        }
        
        invtTransactionRecord.setActualQty( invtTransactionRecord.getOriginalQty() );
        
        if( invtConfigurationRecord.isActualQuantityEditable() ) {
            invtTransactionRecord.setActualQty( String.valueOf( lineRecord.get( invtConfigurationRecord.getActualQuantityAPIName() ) ) );
        }
       
        if( !( invtTransactionRecord.getActualQty() > 0 || ( invtTransactionRecord.getActualQty() == 0 && 
            ( invtTransactionRecord.doCloseLine() || invtConfigurationRecord.getSourceAction() == INVT_Consts.SOURCE_ACTION_SET || 
              invtConfigurationRecord.getTargetAction() == INVT_Consts.SOURCE_ACTION_SET ) ) ) ) {
                
            addError( invtTransactionRecord.getTransactionRecordId(), System.Label.INVT001_TAG071 + ': ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ), false );
        }
        
        if( invtInventoryAPIEngine.isInventoryEnabled() && invtInventoryAPIEngine.isLocationInvolved() ) {
        
            System.debug( LoggingLevel.INFO, 'updateInvtTransactionRecord() : Updating source and target location information.' );
                
            updateSourceLocationInfo( invtTransactionRecord, lineRecord );
            updateTargetLocationInfo( invtTransactionRecord, lineRecord );
        }
    }
    
    /*
     * This private method used to update target location information to transection record object instance.
     */
    private void updateTargetLocationInfo( INVT_TransactionRecord invtTransactionRecord, SObject lineRecord ) {
                    
        if( invtConfigurationRecord.getNumberOfLocation().ToUpperCase().equalsIgnoreCase( INVT_Consts.NUMBER_OF_LOCATIONS_TWO) ) {
        
            if(!invtConfigurationRecord.isTargetLocationFromHeader() && invtConfigurationRecord.isMultilineTransaction() ) {
            
                if( isValidString( invtConfigurationRecord.getRelationshipToTargetLocation() ) ) {
                
                    SObject relationShipToTargetLocation = lineRecord.getSObject( invtConfigurationRecord.getRelationshipToTargetLocation() );
                    /*
                     * Validation will fail if target location is stockable in settings, But 
                     * relationship to target location not exists in line record.
                     */
                    if( relationShipToTargetLocation != null ) {
                    
                        invtTransactionRecord.setToLocationName( (String) relationShipToTargetLocation.get(INVT_Consts.FIELD_NAME_NAME) );
                        if( (Boolean) relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) {
                            
                            invtTransactionRecord.setToLocationId( (String) relationShipToTargetLocation.ID );
                        }
                        
                        /*
                         * Validation will fail if target location is stockable in settings 
                         * and not stocking location in location table.
                         */
                        if( invtConfigurationRecord.isTargetLocationStockable() && 
                            !( (Boolean) relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) ) {
                            
                            System.debug( LoggingLevel.ERROR, 'updateTargetLocationInfo() : Target location stockable in location, But not stocking location in location table.' );
                            addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG036()+ ' ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '') + ' ' + ( invtTransactionRecord.getProductName() != null ? ('('+ invtTransactionRecord.getProductName() +')') : ''), false );
                            isValidLine = false;
                        } else {
                            
                            String targetLocationAPIName = (String) lineRecord.get( invtConfigurationRecord.getTargetLocationAPIName() );
                            if(!invtInventoryAPIEngine.getToLocationMap().containsKey( (String) invtTransactionRecord.getProductId()) && targetLocationAPIName != null ) {
                                invtInventoryAPIEngine.getToLocationMap().put( (String) invtTransactionRecord.getProductId(), targetLocationAPIName );
                            }
                        }
                    } else if( invtConfigurationRecord.isTargetLocationStockable() ) {
                    
                        System.debug( LoggingLevel.DEBUG, 'updateTargetLocationInfo() : Target location is stockable, But relationship to target location not exist in line record.' );
                        addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG036()+ ' ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ) + ' ' +( invtTransactionRecord.getProductName() != null ? ('('+ invtTransactionRecord.getProductName() +')') : ''), false );
                        isValidLine = false;
                    }
                }
            } else {
            
                SObject relationShipToTargetLocation = headerRecord.getSObject( invtConfigurationRecord.getRelationshipToTargetLocation() );
                if( relationShipToTargetLocation != null ) {
                
                    /*
                     * Validation will fail if target location is stockable in settings, But 
                     * stocking location in location table is invalid or disabled.
                     */
                    if ( invtConfigurationRecord.isTargetLocationStockable() && 
                        (relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) == null || 
                        ( relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) != null && 
                        !((Boolean)relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ))))) {
                        
                        System.debug( LoggingLevel.ERROR, 'updateTargetLocationInfo() : Target location is stockable, But stocking location field disabled in location table.' );
                        isValidLine = false;
                    }
                    
                    /*
                     * Update to location name
                     */
                    invtTransactionRecord.setToLocationName( (String) relationShipToTargetLocation.get(INVT_Consts.FIELD_NAME_NAME) );
                    
                    /*
                     * Update to location map if stocking location enabled in location table.
                     */
                    if( (Boolean) relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) {
                    
                        System.debug( LoggingLevel.INFO, 'updateTargetLocationInfo() : Updating location id and to location map.' );
                        
                        invtTransactionRecord.setToLocationId( relationShipToTargetLocation.ID );
                        String targetLocationAPIName = (String) headerRecord.get( invtConfigurationRecord.getTargetLocationAPIName() );
                        
                        /*
                         * If target location API is valid and not exists in to location map, 
                         * Then update to location map with new product id and target location API name.
                         */
                        if( !invtInventoryAPIEngine.getToLocationMap().containsKey( (String) invtTransactionRecord.getProductId() ) && 
                            targetLocationAPIName != null ) {
                                
                            invtInventoryAPIEngine.getToLocationMap().put( (String) invtTransactionRecord.getProductId() , targetLocationAPIName );
                        }
                    }
                } else if( invtConfigurationRecord.isTargetLocationStockable() ) {
                    
                    System.debug( LoggingLevel.ERROR, 'updateTargetLocationInfo() : Target location is stockable, But relationship to target not exists in header record.' );
                    isValidLine = false;
                }
            }
        }
    }
    
    /**
     * This method updates and validates source location.
     */
    private void updateSourceLocationInfo( INVT_TransactionRecord invtTransactionRecord, SObject lineRecord ) {
                    
        if( !invtConfigurationRecord.isSourceLocationFromHeader() && invtConfigurationRecord.isMultilineTransaction() ) {
        
            if( isValidString( invtConfigurationRecord.getRelationshipToSourceLocation() ) ) {
                
                sobject relationShipToSourceLocation = lineRecord.getSObject(invtConfigurationRecord.getRelationshipToSourceLocation());
                /*
                 * Validation will fail if source location is stockable in settings, But 
                 * relationship to source location not exists in line record.
                 */
                if( relationShipToSourceLocation != null ) {
                
                    invtTransactionRecord.setFromLocationName( (String) relationShipToSourceLocation.get(INVT_Consts.FIELD_NAME_NAME) );
                    if( (Boolean)relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) {
                        
                        invtTransactionRecord.setFromLocationId( (String) relationShipToSourceLocation.Id );
                    }                   
                    
                    /*
                     * Validation will fail if source location is stockable in settings and not stocking 
                     * location in location table.
                     */
                    if( invtConfigurationRecord.isSourceLocationStockable() && 
                        !((Boolean)relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) ) {
                            
                        System.debug( LoggingLevel.ERROR, 'updateSourceLocationInfo() : Source location stockable in location, But not stocking location in location table.' );
                        addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG034() + ' ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ) + ' ' +( invtTransactionRecord.getProductName() != null ? ('('+ invtTransactionRecord.getProductName() +')') : ''), false );
                        isValidLine = false;
                    } else {
                    
                        String sourceLocationAPIName = (String) lineRecord.get(invtConfigurationRecord.getSourceLocationAPIName());
                        if( !invtInventoryAPIEngine.getFromLocationMap().containsKey( (String) invtTransactionRecord.getProductId() ) && 
                            sourceLocationAPIName != null ) {
                            
                            invtInventoryAPIEngine.getFromLocationMap().put( (String) invtTransactionRecord.getProductId(), sourceLocationAPIName );
                        }
                    }
                } else if( invtConfigurationRecord.isSourceLocationStockable() ) {
                
                    System.debug( LoggingLevel.ERROR, 'updateSourceLocationInfo() : Source location is stockable, But relationship to source location not exist in line record.' );
                    addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG034() + ' ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ) + ' ' + ( invtTransactionRecord.getProductName() != null ? ('('+ invtTransactionRecord.getProductName() +')') : '' ), false );
                    isValidLine = false;
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'updateSourceLocationInfo() : Invalid relationship to source location.' );
                //addError( invtTransactionRecord.getTransactionRecordId(), oCommUtils.getTAG038() + ' ' + ( invtTransactionRecord.getNameFieldValue() != null ? invtTransactionRecord.getNameFieldValue() : '' ) + ' ' + ( invtTransactionRecord.getProductName() != null ? ('('+ invtTransactionRecord.getProductName() +')') : '' ), true );
                isProcessComplete = false;
            }
        } else {
        
            SObject relationShipToSourceLocation = headerRecord.getSObject( invtConfigurationRecord.getRelationshipToSourceLocation() );
            if( relationShipToSourceLocation != null ) {
            
                if( invtConfigurationRecord.isSourceLocationStockable() && 
                    ( relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) == null || 
                    ( relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) != null && 
                    !( (Boolean) relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) ) ) ) {
                        
                    System.debug( LoggingLevel.ERROR, 'updateSourceLocationInfo() : Source location is stockable, But stocking location field disabled in location table.' );
                    isValidLine = false;
                }
                /*
                 * Updating from location name.
                 */
                invtTransactionRecord.setFromLocationName( (String) relationShipToSourceLocation.get(INVT_Consts.FIELD_NAME_NAME) );
                if( (Boolean)relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) {
                
                    System.debug( LoggingLevel.INFO, 'updateSourceLocationInfo() : Updating location id and from location map.' );
                    
                    invtTransactionRecord.setFromLocationId( relationShipToSourceLocation.Id );
                    String sourceLocationAPIName = (String) headerRecord.get(invtConfigurationRecord.getSourceLocationAPIName());
                    
                    /*
                     * If source location API is valid and not exists in from location map, 
                     * Then update from location map with new product id and source location API name.
                     */
                    if( !invtInventoryAPIEngine.getFromLocationMap().containsKey( (String) invtTransactionRecord.getProductId() ) && 
                        sourceLocationAPIName != null ) {
                            
                        invtInventoryAPIEngine.getFromLocationMap().put( (String) invtTransactionRecord.getProductId(), sourceLocationAPIName );
                    }
                }
            } else if( invtConfigurationRecord.isSourceLocationStockable() ) {
                
                System.debug( LoggingLevel.ERROR, 'updateSourceLocationInfo() : Soruce location is stockable, But relationship to source not exists in header record.' );
                isValidLine = false;
            }
        }
    }
    
    /**
     * This method is used to validate source and target location relationships.
     */
    private void validateLocationRelationship() {
            
        System.debug( LoggingLevel.INFO, 'validateLocationRelationship() : Validating source/target location relationships.' );
        
        if( headerRecord == null || !isValidString( (String) headerRecord.get('id') ) ) {
            
            System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Invalid header record or record id' );
            return;
        }       
        
        if( invtInventoryAPIEngine.isInventoryEnabled() && invtInventoryAPIEngine.isLocationInvolved() ) {
        
            System.debug( LoggingLevel.INFO, 'validateLocationRelationship() : Validating source location from header' );
            
            if(invtConfigurationRecord.isSourceLocationFromHeader()) {
            
                if( isValidString(invtConfigurationRecord.getRelationshipToSourceLocation() ) )  {
                
                    SObject relationShipToSourceLocation = headerRecord.getSObject(invtConfigurationRecord.getRelationshipToSourceLocation());
                    /*
                     * Validation failes for following conditions.
                     * 1. Source location is stockable and no relarionship to source location exists in header record.
                     * 2. Source location is stockable in settings and stocking location not stockable in location table.
                     */
                    if( relationShipToSourceLocation != null ) {
                    
                        if( invtConfigurationRecord.isSourceLocationStockable() && 
                            ( relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) == null || 
                            ( relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) != null && 
                            !( (Boolean) relationShipToSourceLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) ) ) ) {
                                
                            System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Source location is stockable, But stocking location field disabled in location table.' );
                            addError( (String) headerRecord.get('id'), oCommUtils.getTAG033() + ' ' + headerName, false );
                            isValidLine = false;
                        }
                    } else if(invtConfigurationRecord.isSourceLocationStockable()) {
                        
                        System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Source location is stockable, But relationship to source location not exists in header record.' );
                        addError( (String) headerRecord.get('id'), oCommUtils.getTAG033() + ' ' + headerName, false );
                        isValidLine = false;
                    }
                } else {
                    
                    System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Invalid relationship to source location field.' );
                    //addError( oCommUtils.getTAG038() + ': Relationship to source location name=' + invtConfigurationRecord.getRelationshipToSourceLocation() );
                    isProcessComplete = false;
                }
            }
            
            System.debug( LoggingLevel.INFO, 'validateLocationRelationship() : Validating target location from header' );
            
            if(invtConfigurationRecord.getNumberOfLocation().ToUpperCase().equalsIgnoreCase( INVT_Consts.NUMBER_OF_LOCATIONS_TWO ) ) {
            
                if( invtConfigurationRecord.isTargetLocationFromHeader() != null && invtConfigurationRecord.isTargetLocationFromHeader() ) {
                
                    if( isValidString(invtConfigurationRecord.getRelationshipToTargetLocation()) ) {
                    
                        /*
                         * Validation failes for following conditions.
                         * 1. Target location is stockable and no relarionship to target location exists in header record.
                         * 2. Target location is stockable in settings and stocking location not stockable in location table.
                         */
                        SObject relationShipToTargetLocation = headerRecord.getSObject( invtConfigurationRecord.getRelationshipToTargetLocation() );
                        if( relationShipToTargetLocation != null ) {
                        
                            if( invtConfigurationRecord.isTargetLocationStockable() && 
                                (relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) == null || 
                                ( relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) != null && 
                                !( (Boolean) relationShipToTargetLocation.get( INVT_Consts.FIELD_NAME_STOCKING_LOCATION ) ) ) ) ) {
                                
                                System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Target location is stockable, But stocking location field in relationship to target location has value false.' );
                                addError( (String) headerRecord.get('id'), oCommUtils.getTAG035() + ' ' + headerName, false );
                                isValidLine = false;
                            }
                        } else if(invtConfigurationRecord.isTargetLocationStockable()) {
                        
                            System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Target location is stockable, But relationship to target location not exists in header record.' );
                            addError( (String) headerRecord.get('id'), oCommUtils.getTAG035() + ' ' + headerName, false );
                            isValidLine = false;
                        }
                    } else { 
                        System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Invalid relationship to target location field.' );
                        //addError( oCommUtils.getTAG038() + ': Relationship to target location field name=' + invtConfigurationRecord.getRelationshipToTargetLocation() );
                        isProcessComplete = false;
                    }
                }
            }
        }
     
        if( !invtConfigurationRecord.isMultilineTransaction() ) {
        
            if( isValidString( invtConfigurationRecord.getRelationshipNameToProduct() ) ) {
            
                SObject relationShipNameToProduct = headerRecord.getSObject( invtConfigurationRecord.getRelationshipNameToProduct() );
                if( relationShipNameToProduct != null ) {
                    
                    Product2 product2Record = (Product2) relationShipNameToProduct;
                    invtInventoryAPIEngine.getProduct2List().add( product2Record );
                    invtInventoryAPIEngine.getProduct2Map().put( product2Record.Id, product2Record );                    
                            
                    if( !invtInventoryAPIEngine.isInventoryEnabled() || 
                        ( product2Record.get( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING ) != null && 
                        (Boolean) product2Record.get( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING ) && 
                        product2Record.get( INVT_Consts.FIELD_NAME_STOCKABLE ) != null && (Boolean)product2Record.get( INVT_Consts.FIELD_NAME_STOCKABLE ) ) ) {
                
                        invtInventoryAPIEngine.getSerializedProduct2Map().put(product2Record.Id, product2Record);
                    }
                } else {    
                    
                    System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Relationship name to product not existe in header record.' );           
                    addError( (String) headerRecord.get('id'), oCommUtils.getTAG051() + ' ' + headerName, false );
                    isValidLine = false;
                } 
            } else {
                System.debug( LoggingLevel.ERROR, 'validateLocationRelationship() : Invalid relationship name to product field.' );
                //addError( oCommUtils.getTAG038() + ': Relationship name to product field name=' + invtConfigurationRecord.getRelationshipNameToProduct() );
                isProcessComplete = false;
            }
        }        
    }
    
    /**
     * This method retrieves line records from database.
     */
    private void initLineRecords(  Map<String, Schema.SObjectType> mapAllObjectDescribe, List<Id> lstIdsLine ) {
                    
        if( invtConfigurationRecord.isMultilineTransaction() && headerRecord != null && 
            isValidString( (String) headerRecord.get('id') ) ) {
            
            String lineFieldNames = buildLineFieldNames( mapAllObjectDescribe, getDefaultFieldNames() );
            String soqlLine = buildLineQuery( lineFieldNames );
            List<SObject> lineRecordList;
            try {
                System.debug( LoggingLevel.INFO, 'initLineRecords() : Retrieving line records from database' );
                System.debug( LoggingLevel.DEBUG, 'initLineRecords() : Line Query : ' + soqlLine );
                
                if( lstIdsLine != null && !lstIdsLine.isEmpty() ) {
                    lineRecordList = Database.query(soqlLine + ' AND Id = :lstIdsLine ');
                } else {
                    lineRecordList = Database.query(soqlLine);
                }
                
                invtInventoryAPIEngine.setLineRecordList( lineRecordList );
                invtInventoryAPIEngine.setLineRecordQueryString( soqlLine );
                
                if( ( lineRecordList == null || lineRecordList.isEmpty() ) && (oInvProcess.SVMXC__Child_Error_Msg__c != null && oInvProcess.SVMXC__Child_Error_Msg__c != '')) {
                    
                    System.debug( LoggingLevel.ERROR, 'initLineRecords() : Line record not exists in database.' );
                    addError( oInvProcess.SVMXC__Child_Error_Msg__c );
                }
            }
            catch( Exception ex ) {
                
                System.debug( LoggingLevel.ERROR, 'initLineRecords() : ' + ex.getMessage()  );
                addError( ex.getMessage() );               
            }
        }
    }
    
    /**
     * This private method used to retrieve header record object and header name
     */
    private boolean initHeaderRecord(  Map<String, Schema.SObjectType> mapAllObjectDescribe ) {
            
        String headerFieldNames = buildHeaderFieldNames( mapAllObjectDescribe, getDefaultFieldNames() );        
        String soqlHeader = buildHeaderQuery( headerFieldNames );        
        
        try {           
            
            System.debug( LoggingLevel.INFO, 'initHeaderRecord() - Retrieving header record from database' );
            System.debug( LoggingLevel.INFO, 'initHeaderRecord() : Header Query : ' + soqlHeader );
            
            List<SObject> sObjectList = Database.query( soqlHeader );
            if( !invtConfigurationRecord.isMultilineTransaction() ) {
                invtInventoryAPIEngine.setLineRecordList( sObjectList );
            }
            
            if( sObjectList != null && !sObjectList.isEmpty() && 
                sObjectList[0] != null && isValidString( (String) sObjectList[0].get('Id') ) )  {           
                        
                headerRecord = sObjectList[0];
                invtInventoryAPIEngine.setHeaderRecord( headerRecord );
                try {               
                    if( oCommUtils.mapObjectNameField.containsKey( invtConfigurationRecord.getParentObjectName() ) ) {
                        headerName = (String) headerRecord.get(oCommUtils.mapObjectNameField.get(invtConfigurationRecord.getParentObjectName()));
                    } else {
                        headerName = (String) headerRecord.get(INVT_Consts.FIELD_NAME_NAME);
                    }                   
                }
                catch( Exception exc ) {
                    
                    System.debug( LoggingLevel.ERROR, 'initHeaderRecord() : ' + exc.getMessage()  );
                    addError( (String) headerRecord.get('Id'), exc.getMessage(), false );
                }               
            } else {
                
                System.debug( LoggingLevel.ERROR, 'initHeaderRecord() : Header data not exists in database.');
                System.debug( LoggingLevel.ERROR, 'initHeaderRecord() : sObjectList : ' + sObjectList );
                if(oInvProcess.SVMXC__Parent_Error_Msg__c  != null && oInvProcess.SVMXC__Parent_Error_Msg__c != ''){
                    addError( oInvProcess.SVMXC__Parent_Error_Msg__c );
                } else {
                    return false;
                }   
            }
        }
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, 'initHeaderRecord() : ' + ex.getMessage()  );
            addError( ex.getMessage() );
        } 
        
        return true;   
    }
    
    /**
     * Private method to get default field list as string.
     */
    private String getDefaultFieldNames() {
        
        String fieldNames = '';
        if( isValidString( invtConfigurationRecord.getRelatedProductField() ) && isValidString( invtConfigurationRecord.getRelationshipNameToProduct() ) ) {               
            fieldNames = INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipNameToProduct() + INVT_Consts.SEPARATOR_DOT + invtConfigurationRecord.getRelatedProductField();
        } else {
            System.debug( LoggingLevel.ERROR, 'getDefaultFieldNames() : Invalid related product field or relationship name to product field.' );    
            //addError( oCommUtils.getTAG038() + ': Related product field name=' + invtConfigurationRecord.getRelatedProductField() + '; Relationship name to product field name=' + invtConfigurationRecord.getRelationshipNameToProduct() );
            isProcessComplete = false;
        }
        
        if( Schema.Sobjecttype.SVMXC__Product_Stock__c.getSobjectType() != null ) {
        
            fieldNames += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipNameToProduct() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_STOCKABLE;
            fieldNames += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipNameToProduct() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING;
        }
        
        return fieldNames;
    }
    
    private void initLables( Schema.Sobjecttype schemaSobjectType, map<String,Schema.SObjectField> objectHeaderFieldMap, map<String,Schema.SObjectField> objectLineFieldMap) {
       
        try {       
            if(invtConfigurationRecord.isMultilineTransaction()){
                for( Schema.SObjectField sObjectField : objectLineFieldMap.values() ) {
            
                    Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
                    
                    if(( schemaSobjectType == Account.SObjectType && describeFieldResult.getName().equalsIgnoreCase( INVT_Consts.FIELD_NAME_NAME ) ) || 
                    (schemaSobjectType != Account.SObjectType && describeFieldResult.isNameField() ) ) {
                    
                        lineNameField = describeFieldResult.getName();
                        lineNameFieldLabel = describeFieldResult.getLabel();
                        
                    }
                }
                for( Schema.SObjectField sObjectField : objectHeaderFieldMap.values() ) {
                    if(sObjectField.getDescribe().isNameField())
                    headerNameFieldLabel = sObjectField.getDescribe().getLabel();
                }
            }   
            else{
                for( Schema.SObjectField sObjectField : objectHeaderFieldMap.values() ) {
                    Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
                
                    if(( schemaSobjectType == Account.SObjectType && describeFieldResult.getName().equalsIgnoreCase( INVT_Consts.FIELD_NAME_NAME ) ) || 
                    (schemaSobjectType != Account.SObjectType && describeFieldResult.isNameField() ) ) {
                    
                        lineNameField = describeFieldResult.getName();
                        headerNameFieldLabel = describeFieldResult.getLabel();
                    }
                }
            }
        }
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, 'initLables() : ' + ex.getMessage()  );
        }
    }
    
    /**
     * This method builds additional field names in string format.
     */
    private String buildHeaderFieldNames( Map<String, Schema.SObjectType> mapAllObjectDescribe, String fieldNames ) {
        
        String headerFields = (String) oCommUtils.getFieldString( mapAllObjectDescribe.get( invtConfigurationRecord.getParentObjectName() ) );
        
        if( !invtConfigurationRecord.isMultilineTransaction() ) {
            
            if( isValidString( invtConfigurationRecord.getParentObjectName() ) ) {
                headerFields += fieldNames;         
            } else {
                System.debug( LoggingLevel.ERROR, 'buildHeaderFieldNames() : Invalid parent object name. Parent object name = ' + invtConfigurationRecord.getParentObjectName() ); 
                //addError( oCommUtils.getTAG038() + ': Parent object name field=' + invtConfigurationRecord.getParentObjectName() );
                isProcessComplete = false; 
            }
        }
        
        if( invtInventoryAPIEngine.isInventoryEnabled() && invtInventoryAPIEngine.isLocationInvolved() ) { 
            
            System.debug( LoggingLevel.INFO, 'buildHeaderFieldNames() - Updating fields with stocking location and name' );
        
            if( invtConfigurationRecord.isSourceLocationFromHeader() ) {
                
                if( isValidString( invtConfigurationRecord.getRelationshipToSourceLocation() ) ) {
                    
                    headerFields += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToSourceLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_STOCKING_LOCATION;
                    headerFields += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToSourceLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_NAME;
                } else { 
                    System.debug( LoggingLevel.ERROR, 'buildHeaderFieldNames() : Invalid relationship to source location field.' );
                    //addError( oCommUtils.getTAG038() + ': Relationship to source location field name=' + invtConfigurationRecord.getRelationshipToSourceLocation() );
                    isProcessComplete = false; 
                }
            }
            
            if(invtConfigurationRecord.getNumberOfLocation().ToUpperCase().equalsIgnoreCase( INVT_Consts.NUMBER_OF_LOCATIONS_TWO ) && 
                invtConfigurationRecord.getRelationshipToSourceLocation() != invtConfigurationRecord.getRelationshipToTargetLocation() ) {
                
                if( invtConfigurationRecord.isTargetLocationFromHeader() ) {
                    
                    if( isValidString( invtConfigurationRecord.getRelationshipToTargetLocation() ) ) {
                
                        headerFields += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToTargetLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_STOCKING_LOCATION;
                        headerFields += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToTargetLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_NAME;                   
                    } else {
                        System.debug( LoggingLevel.ERROR, 'buildHeaderFieldNames() : Invalid relationship to target location field.' );
                        //addError( oCommUtils.getTAG038() + ': Relationship to target location field name=' + invtConfigurationRecord.getRelationshipToTargetLocation() );
                        isProcessComplete = false;
                    } 
                }
            }
        }
        
        return headerFields;
    }
    
    /*
     * This method used to create list of field required to retrieve for line record.
     */
    private String buildLineFieldNames( Map<String, Schema.SObjectType> mapAllObjectDescribe, String fieldNames ) {
        
        String lineFieldNames = (String) oCommUtils.getFieldString( mapAllObjectDescribe.get( invtConfigurationRecord.getChildObjectName() ) );  
        
        if( invtConfigurationRecord.isMultilineTransaction() ){            
            if( isValidString( invtConfigurationRecord.getChildObjectName() ) ) {             
                lineFieldNames += fieldNames;           
            } else {
                System.debug( LoggingLevel.DEBUG, 'buildLineFieldNames() : Multiline transaction has been enabled, But has invalid child object name.' ); 
                //addError( oCommUtils.getTAG038() + ': Child object name=' + invtConfigurationRecord.getChildObjectName() );
                isProcessComplete = false;  
            }
        }       
        
        if( invtInventoryAPIEngine.isInventoryEnabled() && invtInventoryAPIEngine.isLocationInvolved() ) {
        
            if( invtConfigurationRecord.isMultilineTransaction() && !invtConfigurationRecord.isSourceLocationFromHeader() ) {               
                if( isValidString( invtConfigurationRecord.getRelationshipToSourceLocation() ) ) {   
                            
                    lineFieldNames += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToSourceLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_STOCKING_LOCATION;
                    lineFieldNames += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToSourceLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_NAME;             
                } else { 
                
                    System.debug( LoggingLevel.ERROR, 'buildLineFieldNames() : Multiline transaction has been enabled, But has invalid relationship to source location.' );
                    //addError( oCommUtils.getTAG038() + ': Relationship to source location field name=' + invtConfigurationRecord.getRelationshipToSourceLocation() );
                    isProcessComplete = false; 
                }
            }
    
            if( invtConfigurationRecord.getNumberOfLocation().ToUpperCase().equalsIgnoreCase( INVT_Consts.NUMBER_OF_LOCATIONS_TWO ) && 
                invtConfigurationRecord.getRelationshipToSourceLocation() != invtConfigurationRecord.getRelationshipToTargetLocation() ) {                
                
                if( invtConfigurationRecord.isMultilineTransaction() && !invtConfigurationRecord.isTargetLocationFromHeader() ) {
                    
                    if( isValidString( invtConfigurationRecord.getRelationshipToTargetLocation() ) ) {
                
                        linefieldNames += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToTargetLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_STOCKING_LOCATION;
                        linefieldNames += INVT_Consts.SEPARATOR_COMMA + invtConfigurationRecord.getRelationshipToTargetLocation() + INVT_Consts.SEPARATOR_DOT + INVT_Consts.FIELD_NAME_NAME;
                    } else {
                    
                        System.debug( LoggingLevel.ERROR, 'buildLineFieldNames() : Multiline transaction has been enabled, But has invalid relationship to target location.' ); 
                        //addError( oCommUtils.getTAG038() + ': Relationship to target location field name=' + invtConfigurationRecord.getRelationshipToTargetLocation()  );
                        isProcessComplete = false;
                    } 
                }
            }
        }
                
        return lineFieldNames;
    }
    
    /**
     * This method builds header quiry to retrieve header record objects.
     */
    private String buildHeaderQuery( String headerFields ) {
        
        String soqlHeader = 'SELECT ' + headerFields + ' FROM ' ;
        if( isValidString(invtConfigurationRecord.getParentObjectName()) ) {
            
            soqlHeader += invtConfigurationRecord.getParentObjectName() + ' WHERE Id=:strHeaderRecordId';
        } else {
            System.debug( LoggingLevel.ERROR, 'buildHeaderQuery() : Invalid parent object name.' ); 
            //addError( oCommUtils.getTAG038() + ': Parent object name=' + invtConfigurationRecord.getParentObjectName() );
            isProcessComplete = false;
        }
        
        /*
         * Include parent object criteria if exists.
         */
        if ( isValidString( invtConfigurationRecord.getParentObjectCriteria() ) ) {
            soqlHeader += ' AND (' + invtConfigurationRecord.getParentObjectCriteria().replace( 'SVMX.CurrentUser',UserInfo.getUserId() ) +')';
        }
        
        return soqlHeader;
    }
    
    /*
     * This private method will create SOQL query to retrieve line record for given header id.
     */
    private String buildLineQuery( String lineFieldNames ) {
        
        String soqlLine = 'SELECT ' + lineFieldNames + ' FROM ' ;   
        
        if( invtConfigurationRecord.isMultilineTransaction() ) {
        
            if(isValidString( invtConfigurationRecord.getChildObjectName() ) && isValidString( invtConfigurationRecord.getLookupFieldToParent() ) ) {
                
                soqlLine += invtConfigurationRecord.getChildObjectName() + ' WHERE ' + invtConfigurationRecord.getLookupFieldToParent() + '=:strHeaderRecordId ';
            } else {
                
                System.debug( LoggingLevel.ERROR, 'buildLineQuery() : Invalid child object name or lookup field to parent.' );
                //addError( oCommUtils.getTAG038() + ': Child object name=' + invtConfigurationRecord.getChildObjectName() + '; Lookup field to parent field name=' + invtConfigurationRecord.getLookupFieldToParent());
                isProcessComplete = false; 
            }

            if( isValidString( invtConfigurationRecord.getChildObjectRecordType() ) ) {
                soqlLine += ' AND RecordType.Name ' + '=\''+ invtConfigurationRecord.getChildObjectRecordType() +'\' ';
            }
        }
        
        /*
         * Invlude child object criteria if exists.
         */ 
        if( isValidString( invtConfigurationRecord.getChildObjectCriteria() ) ) {
            soqlLine += ' AND (' + invtConfigurationRecord.getChildObjectCriteria().replace( 'SVMX.CurrentUser',UserInfo.getUserId() ) + ')';
        }
        
        return soqlLine;
    }   
        
    /*
     * This private method used to build schema object name vs object type reference map.
     */
    private Map<String, Schema.SObjectType> getGlobalDescribe() {
        
        Map<String, Schema.SObjectType> mapObjectAPINameDescResult = new Map<String, Schema.SObjectType>();      
        Map<String, Schema.SObjectType> mapAllObjectDescribe = Schema.getGlobalDescribe();
        if( mapAllObjectDescribe != null ) {
            for( Schema.SObjectType sObjectType : mapAllObjectDescribe.values() ) {
                mapObjectAPINameDescResult.put( sObjectType.getDescribe().getName(), sObjectType );
            }
        }
        
        return mapObjectAPINameDescResult;
    }

    /*
     * Private method to initialize inventory process.
     */
    private void init( String inventoryProcessId ) {
    
        try {
        /*
         * Query for ServiceMax Process table to retrieve inventory process object.
         */
         //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            oInvProcess = [Select ID, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, Name, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Module__c, SVMXC__ProcessID__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Child_Object_Criteria__c 
                                FROM SVMXC__ServiceMax_Processes__c 
                                WHERE SVMXC__ProcessID__c = :inventoryProcessId limit 1];
        }
        catch( Exception ex ) {
            System.debug( LoggingLevel.ERROR, 'init() : Failed to get inventory process.' );
            return;
        }
        
        if( oInvProcess != null && isValidString( oInvProcess.SVMXC__Tag_Keys__c ) ) {
            /*
             * Logic to translate inventory process.
             */
            oInvProcess = new I18N_TranslationDelivery( oInvProcess.SVMXC__Tag_Keys__c, UserInfo.getLanguage() ).SVMX_GetProcessTranslation(oInvProcess);
        }        
        
        Map<String, SVMXC__ServiceMax_Config_Data__c> settingObjectMap = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingObjectList(oInvProcess.SVMXC__Submodule__r.SVMXC__SubmoduleID__c);         
        invtConfigurationRecord = new INVT_ConfigurationRecord( oInvProcess, settingObjectMap );
        
        /*
         * Se location involved flag to false if the number of location field is not configured. 
         */
        if( !isValidString( invtConfigurationRecord.getNumberOfLocation() ) ) {
            invtInventoryAPIEngine.setLocationInvolved( false ); 
        }
        
        System.debug( LoggingLevel.INFO, 'Initializing record type map' );
        
        Map<String, Map<String, String>> recordTypeMap = new Map<String, Map<String, String>>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA        
        for( RecordType recordType : [Select SobjectType, Name, Id From RecordType WHERE SobjectType = 'SVMXC__Stock_History__c'] )
        {
            if( !recordTypeMap.containsKey(recordType.SobjectType) ) {
                recordTypeMap.put( recordType.SobjectType, new Map<String, String>() );
            }
            recordTypeMap.get(recordType.SobjectType).put( recordType.Name, recordType.Id );
        }
        
        /*
         * Set initialized object references to inventory API engine.
         */
        invtInventoryAPIEngine.setObjInventoryProcess( oInvProcess );
        invtInventoryAPIEngine.setConfigurationRecord( invtConfigurationRecord );
        invtInventoryAPIEngine.setRecordTypeMap( recordTypeMap );   
        invtInventoryAPIEngine.setSettingObjectMap( settingObjectMap );
    }
    
    private void addError( String message ) {
        
        INVT_WrapperDef.SVMXMessage svmxMessage = new INVT_WrapperDef.SVMXMessage( message, '', 'ERROR');
        responceList.add( svmxMessage );
    }
    
    private void addError( Id id, String message, Boolean isError ) {
        
        if( isError ) { addError( message ); } 
        
        if( !idResultListMap.containsKey( id ) ) {
            idResultListMap.put( id, new List<String>() );
        }
        
        idResultListMap.get(id).add(message); 
    }
}