/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Inventory Transaction services implementation.
 *
 * @author Ramachandra Mohan
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       29 Jan 2020     Created.
 *              Jaysukh Patel           18 AUg 2020     Implimented
 *****************************************************************************************************/
public class INVT_InventoryTransactionImpl {

    private class ProductSerial {
        
        public String id;
        public String name;
        public String batchLotId;
        public String batchLotName;
        public Boolean active;
        public Double batchLotQuantity;
        public String productStockId;
        public ProductSerial(){}

    }
    private class ProductStock{
        public String id;
        public String locationId;
        public String locationName;
        public String productId;
        public String productName;
        public Double productStockQuantity;
        public String productStockStatus;
        public String locationEmail;
        public List<ProductSerial> productSerialList;
    }
    private class StockDetail{
        private String lineId;
        private Double quentityBefore;
        private Double transactionQuentity;
        private Double quantityAfter;
        private String lineName;
    }
    private class LineRecordSobject{
        INVT_Structure.INVT_LineInfo lineinfo;
        public SObject sObjRecord;
        public LineRecordSobject(INVT_Structure.INVT_LineInfo lineinfo, SObject sObjRecord)
        {
            this.lineinfo = lineinfo;
            this.sObjRecord = sObjRecord;
        }
        
    }

    private class InventoryException extends Exception{
        public List<INVT_Structure.INVT_Error> lstOfError{get;set;}
        InventoryException(List<INVT_Structure.INVT_Error> lstOfError)
        {
          this.lstOfError = lstOfError;   
        }
        
    }
    private final String UNDERSCORE = '_';
    private Boolean respectActiveProductSerial = false;
    private COMM_SVMXC_Utils3 comm_svmxc_utils3 = new COMM_SVMXC_Utils3(true);
    private Sobject HeaderRecord = null;
    //private boolean getGBL002 = true;
    
    Boolean isSourceStockingLocation = false;
    Boolean isTargetStockingLocation = false;
    Sobject sourceLocationSObject = null;
    Sobject targetLocationSObject = null;
    Set<String> nonStockinglocationSet = new Set<String>();
    
    public Map<ID,StockDetail> stockDetailWrapper = new Map<ID,StockDetail>();
    

    public INVT_InventoryTransactionImpl() {
        init();
    }
    /*
     * Get invetory call entry point
    */
    @testVisible private Map<String,ProductStock> getProductStockInfo( COMM_Inventory_Classes.InventoryProcess inventoryProcess, final List<SObject> processRecords, Boolean isAllStatus ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProductStockInfo() - enter;');
        
        Map<String,ProductStock> productStockMap = new Map<String,ProductStock>();
        
        Set<String> statusSet = new Set<String>();
        statusSet.add(inventoryProcess.Source_Status);
        
        if( isAllStatus ) {
            
            statusSet.add(inventoryProcess.Target_Status);
            statusSet.add('DECREASED');
            statusSet.add('ADJUSTED');
            
        }
        
        try {
            
            final Set<String> locationSetTest = new Set<String>();
            
            Set<String> nonStockingLocationIds = new Set<String>();
            
            List<Sobject> sourceTargetLocation = getAllSourceTargetLocations(inventoryProcess , processRecords);
            this.nonStockinglocationSet = getNonStockingLocation(sourceTargetLocation);
            
            
            System.debug('sourceTargetLocation '+ sourceTargetLocation);

            
            final Set<String> productSet = new Set<String>();
            final Set<String> locationSet = new Set<String>();
            for( SObject record : processRecords ) {
                
                productSet.add( (String) record.get( inventoryProcess.Product_Field_API_Name ) );
                
                //Added for stock transfer
                if( String.isNotEmpty( inventoryProcess.Source_Location_API_Name ) ) {
                    
                    if( inventoryProcess.Is_Source_Location_From_Header  && String.isNotEmpty( inventoryProcess.RelationShip_Name_to_Parent ) ) {
                        locationSet.add((String)record.getSobject(inventoryProcess.RelationShip_Name_to_Parent).get(inventoryProcess.Source_Location_API_Name));
                    } else {
                        locationSet.add( (String) record.get( inventoryProcess.Source_Location_API_Name ) );
                    }
                }
                
                if( String.isNotEmpty( inventoryProcess.Target_Location_API_Name ) ) {
                    
                    if(inventoryProcess.Is_Target_Location_From_Header && String.isNotEmpty( inventoryProcess.RelationShip_Name_to_Parent ) ) {
                        locationSet.add((String)record.getSobject(inventoryProcess.RelationShip_Name_to_Parent).get(inventoryProcess.Target_Location_API_Name));
                    } else {
                        locationSet.add( (String) record.get( inventoryProcess.Target_Location_API_Name ) );
                    }
                }
            }
            
            //Added for defect 
            System.debug('locationSet: '+ locationSet);
            if(!nonStockinglocationSet.isEmpty())
            {
                locationSet.removeAll (nonStockinglocationSet);
            }
            Map<String, SVMXC__Product_Stock__c> productStockRecordMap = new Map<String,SVMXC__Product_Stock__c>( [Select Id, LastModifiedDate , SVMXC__Quantity2__c, SVMXC__Location__r.SVMXC__Email__c, SVMXC__Location__c, SVMXC__Location__r.name, SVMXC__Status__c, SVMXC__Product__c, SVMXC__Product__r.Name From SVMXC__Product_Stock__c WHERE SVMXC__Status__c = :statusSet AND SVMXC__Product__c IN :productSet AND SVMXC__Location__c IN :locationSet ORDER BY SVMXC__Quantity2__c DESC]);
            
            
            if( !productStockRecordMap.isEmpty() ) {
                
                productStockMap = buildProductStockMap(productStockRecordMap.values() );
                // To - do need to remove product stock field
                /*List<SVMXC__Product_Serial__c> productSerialList = [Select Id, Name, SVMXC__SM_Batch_Lot__c, SVMXC__SM_Batch_Lot__r.Name, SVMXC__SM_Batch_Lot__r.SVMXC__SM_Batch_Lot_Number__c ,SVMXC__SM_Quantity__c, SVMXC__Active__c, SVMXC__Product_Stock__r.SVMXC__Location__c, SVMXC__Product_Stock__r.SVMXC__Location__r.Name, SVMXC__Product_Stock__r.SVMXC__Quantity2__c, SVMXC__Product_Stock__r.SVMXC__Product__c, SVMXC__Product_Stock__r.SVMXC__Product__r.Name, SVMXC__Product_Stock__c, SVMXC__Product_Stock__r.SVMXC__Status__c FROM SVMXC__Product_Serial__c WHERE SVMXC__Active__c = true AND SVMXC__Product_Stock__c  IN : productStockRecordMap.keySet() AND SVMXC__Product__c IN : productSet ORDER BY Name ASC];
*/
                //For batch/lot
                List<SVMXC__Product_Serial__c> productSerialList = new List<SVMXC__Product_Serial__c>();
                System.debug('Is_InactiveBatch_Supported: '+ inventoryProcess.Is_InactiveBatch_Supported);
                if(inventoryProcess.Is_InactiveBatch_Supported)
                {
                    productSerialList = [Select Id, Name, SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.Name,SVMXC__SM_Quantity__c, SVMXC__Active__c, SVMXC__Product_Stock__r.SVMXC__Location__c, SVMXC__Product_Stock__r.SVMXC__Location__r.Name, SVMXC__Product_Stock__r.SVMXC__Quantity2__c, SVMXC__Product_Stock__r.SVMXC__Product__c, SVMXC__Product_Stock__r.SVMXC__Product__r.Name, SVMXC__Product_Stock__c, SVMXC__Product_Stock__r.SVMXC__Status__c FROM SVMXC__Product_Serial__c WHERE SVMXC__Active__c = true AND SVMXC__Product_Stock__c  IN : productStockRecordMap.keySet() AND SVMXC__Product__c IN : productSet ORDER BY Name ASC];
                
                }else
                {
                    productSerialList = [Select Id, Name, SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.Name, SVMXC__SM_Quantity__c, SVMXC__Active__c, SVMXC__Product_Stock__r.SVMXC__Location__c, SVMXC__Product_Stock__r.SVMXC__Location__r.Name, SVMXC__Product_Stock__r.SVMXC__Quantity2__c, SVMXC__Product_Stock__r.SVMXC__Product__c, SVMXC__Product_Stock__r.SVMXC__Product__r.Name, SVMXC__Product_Stock__c, SVMXC__Product_Stock__r.SVMXC__Status__c FROM SVMXC__Product_Serial__c WHERE ((SVMXC__SM_Batch_Lot2__c != null AND SVMXC__SM_Batch_Lot2__r.SVMXC__SM_Active__c = true) OR SVMXC__SM_Batch_Lot2__c = null) AND SVMXC__Active__c = true AND SVMXC__Product_Stock__c  IN : productStockRecordMap.keySet() AND SVMXC__Product__c IN : productSet ORDER BY Name ASC];
                }
                for(SVMXC__Product_Serial__c productSerialRecord : productSerialList ) {
                    
                    ProductSerial productSerial = new ProductSerial();
                    productSerial.id = productSerialRecord.Id;
                    productSerial.name = productSerialRecord.Name;
                    productSerial.active = productSerialRecord.SVMXC__Active__c;
                    productSerial.batchLotId = productSerialRecord.SVMXC__SM_Batch_Lot2__c;
                    productSerial.batchLotName = productSerialRecord.SVMXC__SM_Batch_Lot2__r.Name;
                    productSerial.batchLotQuantity = productSerialRecord.SVMXC__SM_Quantity__c;
                    productSerial.productStockId = productSerialRecord.SVMXC__Product_Stock__c;
                    
                    System.debug('serial id: '+ productSerialRecord.Id );
                    System.debug('Batch number: '+ productSerialRecord.SVMXC__SM_Batch_Lot2__r.Name);
                    
                    SVMXC__Product_Stock__c productStockRecord = productStockRecordMap.get(productSerial.productStockId);
                    String key = productStockRecord.SVMXC__Product__c +'_'+ productStockRecord.SVMXC__Location__c +'_'+ productStockRecord.SVMXC__Status__c;
                    
                    productStockMap.get(key).productSerialList.add(productSerial);
                }
            }
        }
        
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR,  'getProductStockInfo exception '+ e.getStackTraceString());
            throw e;
        }
        
        finally {
            
        }
        System.debug( LoggingLevel.DEBUG, 'getProductStockInfo() - exist');
        
        return productStockMap;
    }
    private Map<String,ProductStock> buildProductStockMap(final List<SVMXC__Product_Stock__c> productStockRecordList) {
        
        Map<String,ProductStock> productStockMap = new Map<String,ProductStock>();
        
        for( SVMXC__Product_Stock__c productStockRecord : productStockRecordList ) {
                
            String key = productStockRecord.SVMXC__Product__c +'_'+productStockRecord.SVMXC__Location__c +'_'+ productStockRecord.SVMXC__Status__c;
            
            ProductStock productStcok = new ProductStock();
            productStcok.id = productStockRecord.id;
            productStcok.productStockQuantity = productStockRecord.SVMXC__Quantity2__c;
            productStcok.productId = productStockRecord.SVMXC__Product__c;
            productStcok.productName = productStockRecord.SVMXC__Product__r.Name;
            productStcok.productStockStatus = productStockRecord.SVMXC__Status__c;
            productStcok.locationId = productStockRecord.SVMXC__Location__c;
            productStcok.locationName = productStockRecord.SVMXC__Location__r.Name;
            productStcok.locationEmail = productStockRecord.SVMXC__Location__r.SVMXC__Email__c;
            productStcok.productSerialList = new List<ProductSerial>();
            
            productStockMap.put(key, productStcok);
            
        }
        
        return productStockMap;
    }
    
    public Map<String,List<SVMXC__ServiceMax_Config_Data__c>> getCloserActions(String invtProcessId)
    {
        // Below map will be having INV_Header_Closure_Action, INV_Line_Closure_Action ,INV_Related_Update_Action as a expression type , key
        Map<String,List<SVMXC__ServiceMax_Config_Data__c>> closerActionMap = new Map<String,List<SVMXC__ServiceMax_Config_Data__c>>();
       
        //Initilizing map because we don' need to check nulll when we use this map in for loop directly
        List<SVMXC__ServiceMax_Config_Data__c> closerActionList= [select id, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Object_Name__c, SVMXC__Expression_Type__c, SVMXC__Field_Name__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Inventory_Process__r.SVMXC__ProcessID__c = : invtProcessId ];
        closerActionMap.put('INV_Header_Closure_Action', new List<SVMXC__ServiceMax_Config_Data__c>());
        closerActionMap.put('INV_Line_Closure_Action', new List<SVMXC__ServiceMax_Config_Data__c>());
        closerActionMap.put('INV_Related_Update_Action', new List<SVMXC__ServiceMax_Config_Data__c>());
        
        for(SVMXC__ServiceMax_Config_Data__c closerAction : closerActionList)
        {
            if(closerActionMap.containsKey(closerAction.SVMXC__Expression_Type__c))
            {
                closerActionMap.get(closerAction.SVMXC__Expression_Type__c).add(closerAction);
            }
            
        }
        
        return closerActionMap;
    }
    private Map<Id,Sobject> getSobjectLineMap(List<SObject> xRecords)
    {
        Map<Id,Sobject> mapOfRecord = new Map<Id,Sobject>();
        for(Sobject sobj : xRecords)
        {
            mapOfRecord.put(sobj.id, sobj);
        }
        return mapOfRecord;
    }
    //Validate number of record based on actual request
    public List<INVT_Structure.INVT_Error> validateSerialNumbers(List<INVT_Structure.INVT_LineInfo> requestLines,COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig, Map<Id, SObject> mapOfxRecords)
    {
        List<INVT_Structure.INVT_Error> lstOferrors = new List<INVT_Structure.INVT_Error>();
        System.debug('requestLines: '+ requestLines);
        //Map<Id,Sobject> sobjectRecords = getSobjectLineMap(xRecords);
        boolean isQtyWrong = true;
        boolean isQtyCorrect = true;
        List<String> errorLineName = new List<String>();
        List<String> wrongLineName = new List<String>();

        
        for(INVT_Structure.INVT_LineInfo invtLineInfo: requestLines){
            
            //commented below code after creating method bindingDataWithRequest
            /*Sobject tempsObjectRec = mapOfxRecords.get(invtLineInfo.id);
            Sobject productsobj = tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Product);
            String partName = String.valueOf(productsobj.get(inventoryProcessConfig.Related_Product_Field));
            Boolean isStockable = (Boolean) productsobj.get('SVMXC__Stockable__c');
            Boolean isSerializedTracked = (Boolean)productsobj.get('SVMXC__Enable_Serialized_Tracking__c');
            */
            if(invtLineInfo.actualQuantity >= 0)
            {
                if(invtLineInfo.isStockable && invtLineInfo.isSerializedTracked)
                {
                    if(invtLineInfo.targetSerialList.isEmpty() ||  (invtLineInfo.actualQuantity != invtLineInfo.targetSerialList.size()))
                    {
                        errorLineName.add(invtLineInfo.name +' (' + invtLineInfo.partName + ')');
                        isQtyCorrect = false;
                    } 
                }

            }else
            {
                wrongLineName.add( invtLineInfo.name +' (' + invtLineInfo.partName + ')' );
                isQtyWrong = false;
            }
        }
        if(!isQtyCorrect)
        {
            INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
            invt_error.error = comm_svmxc_utils3.getTAG042 ();
            invt_error.entityName = String.join (errorLineName, ', ');
            lstOferrors.add(invt_error);
        }
        if(!isQtyWrong)
        {
            INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
            invt_error.error = comm_svmxc_utils3.getTAG055();
            invt_error.entityName = String.join (wrongLineName, ', ');
            lstOferrors.add(invt_error);
        }
        return lstOferrors;
    }
    //Validate the qty actually allowed based on setting
    private List<INVT_Structure.INVT_Error> onSubmitValidation(final COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig, List<INVT_Structure.INVT_LineInfo> requestLines, Map<Id,Sobject> mapOfxRecords)
    {
     
        List<INVT_Structure.INVT_Error> lstOferrors = new List<INVT_Structure.INVT_Error>();
        
        //Map<Id,Sobject> sobjectRecords = getSobjectLineMap(xRecords);
        List<String> excessLines = new List<String>();
        List<String> partialLines = new List<String>();
        List<String> batchlotLines = new List<String>();
        List<String> batchlotLinesEmpty = new List<String>();
        

        
        for(INVT_Structure.INVT_LineInfo lineIfo: requestLines)
        {
            
            //commented after creating method bindingDataWithRequest
            //Sobject tempsObjectRec = mapOfxRecords.get(lineIfo.id);
            /*Sobject productsobj = tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Product);
            String partName =  String.valueOf(productsobj.get(inventoryProcessConfig.Related_Product_Field));*/

            //Batch lot code
            if (lineIfo.isBatchLotTracked && !lineIfo.isSerializedTracked) {
                
                //Below validation for just to validate if Batch to check not support adjustment means single location
                if(String.isNotBlank(inventoryProcessConfig.Number_of_locations) && inventoryProcessConfig.Number_of_locations.toUpperCase() == 'ONE')
                {
                    INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                    invt_error.error = comm_svmxc_utils3.getTAG102(); // Batched Inventory Processing is currently not Supported for Processes with a Single Location
                    
                    throw new InventoryException(new List<INVT_Structure.INVT_Error>{invt_error});
                }
                doBatchUniquenessValidation(lineIfo.targetSerialList,lineIfo.productId);
                doBatchLotValidation(batchlotLines, lineIfo.targetSerialList ,lineIfo.name , lineIfo.actualQuantity);
            }
            
            //End batch lot validation code
            if(!inventoryProcessConfig.Allow_Excess_Quantity && (lineIfo.originalQuantity < lineIfo.actualQuantity))
            {
                excessLines.add(lineIfo.name +' (' + lineIfo.partName + ')');
            }
            if(!inventoryProcessConfig.Allow_Partial_Quantity && (lineIfo.originalQuantity > lineIfo.actualQuantity))
            {
                partialLines.add(lineIfo.name +' (' + lineIfo.partName + ')');
            }
        }

        if(!batchlotLines.isEmpty())
        {
            INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
            invt_error.error = comm_svmxc_utils3.getTAG105();
            invt_error.entityName = String.join (batchlotLines, ', ');
            lstOferrors.add(invt_error);
            
        }

        if(!excessLines.isEmpty())
        {
            INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
            invt_error.error = comm_svmxc_utils3.getTAG048 ();
            invt_error.entityName = String.join (excessLines, ', ');
            lstOferrors.add(invt_error);
            
        }
        if(!partialLines.isEmpty())
        {
            INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
            invt_error.error = comm_svmxc_utils3.getTAG049 ();
            invt_error.entityName = String.join (partialLines, ', ');
            lstOferrors.add(invt_error);
        }
        return lstOferrors;
    }
    //Doing batch lot non serialization validation only
    private void doBatchLotValidation(List<String> batchlotLines, List<INVT_Structure.INVT_ProductSerialInfo> productSerialNumbers, String lineRecordName, Double actualQty){
        Double sumOfbatchLotTargetQuantity = 0.0;
                
        for(INVT_Structure.INVT_ProductSerialInfo productSerialNumber: productSerialNumbers)
            {
                if (productSerialNumber.batchLotQuantity != null && Double.valueOf(productSerialNumber.batchLotTargetQuantity) != null && Double.valueOf(productSerialNumber.batchLotTargetQuantity) > productSerialNumber.batchLotQuantity) {
                    batchlotLines.add(lineRecordName +' (' + productSerialNumber.batchLotName + ')');
                }
                if (productSerialNumber.batchLotTargetQuantity != null) {
                    sumOfbatchLotTargetQuantity = sumOfbatchLotTargetQuantity + productSerialNumber.batchLotTargetQuantity;
                }
                
            }
    
        if (sumOfbatchLotTargetQuantity != actualQty) { //Added for BAC-6100
            batchlotLines.add(lineRecordName);
        }
    }
    //Same name batch not allowed in case of batch and non-serialiaz 
    private void doBatchUniquenessValidation(List<INVT_Structure.INVT_ProductSerialInfo> productSerialNumbers, String productId)
    {
        Set<String> setOfBatchSerial = new Set<String>();
        for(INVT_Structure.INVT_ProductSerialInfo productSerial: productSerialNumbers)
        {
            if(setOfBatchSerial.contains(productSerial.serialName+'_'+productId))
            {
                INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                invt_error.error = comm_svmxc_utils3.getTAG106() + ' '+ productSerial.serialName;
                
                throw new InventoryException(new List<INVT_Structure.INVT_Error>{invt_error});
            }
            setOfBatchSerial.add(productSerial.serialName+'_'+productId);
        }
    }

    /*
     * Uniquness validation for all serialization type of process
     * In case of batch serial user should able to enter the duplicate serial if serial doent have batch   
    */
    public List<INVT_Structure.INVT_Error> validateSerialNumberUniquness(COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig, List<INVT_Structure.INVT_LineInfo> requestLines)
    {
        List<INVT_Structure.INVT_Error> lstOferrors = new List<INVT_Structure.INVT_Error>();
        
        String uniquenessType = inventoryProcessConfig.Enforce_Uniqueness_In_Serial_Selection;
        try{
            if(String.isNotEmpty(uniquenessType) && uniquenessType =='STRICT')
            {
                Set<String> setOfSerialNumber = new Set<String>();
                Set<String> setOfDuplicateSerialNumber = new Set<String>();
                for(INVT_Structure.INVT_LineInfo lineIfo: requestLines)
                {
                    //Added for BAC-6064
                    if(lineIfo.isBatchLotTracked && lineIfo.isSerializedTracked)
                    {
                        for(INVT_Structure.INVT_ProductSerialInfo productSerialNumber: lineIfo.targetSerialList)
                        {
                            if(String.isNotBlank(productSerialNumber.batchLotName))  
                            {
                                if(setOfSerialNumber.contains(productSerialNumber.serialName+'_'+productSerialNumber.batchLotName))
                                {
                                    setOfDuplicateSerialNumber.add(productSerialNumber.batchLotName+'-'+productSerialNumber.serialName);
                                    
                                }else
                                {
                                    setOfSerialNumber.add(productSerialNumber.serialName+'_'+productSerialNumber.batchLotName);
                                }
                            }
                                                     
                        }
                    }else if(lineIfo.isSerializedTracked)
                    {
                        for(INVT_Structure.INVT_ProductSerialInfo productSerialNumber: lineIfo.targetSerialList)
                        {
                            if(setOfSerialNumber.contains(productSerialNumber.serialName))
                            {
                                setOfDuplicateSerialNumber.add(productSerialNumber.serialName);
                                
                            }else
                            {
                                setOfSerialNumber.add(productSerialNumber.serialName);
                            }
                            
                        }
                    }
                    
                }
                if(!setOfDuplicateSerialNumber.isEmpty())
                {
                    INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                    invt_error.error = comm_svmxc_utils3.getTAG045();
                    invt_error.entityName = String.join ( new List<String>(setOfDuplicateSerialNumber), ', ');
                    lstOferrors.add(invt_error);
                }
                
                
            }
        }catch(Exception e)
        {
            throw e;
        }
        
        return lstOferrors;
    }
    //Constructing a wrapper for update line
    public List<LineRecordSobject> buildLineRecordWrapper(List<INVT_Structure.INVT_LineInfo> requestLines , Map<Id,Sobject> mapOfxRecord)
    {
        List<LineRecordSobject> listLineRecordSobject = new List<LineRecordSobject>();
        
        for(INVT_Structure.INVT_LineInfo lineInfo :  requestLines)
        {
            if(mapOfxRecord.get(lineInfo.id) !=null )
            {
                LineRecordSobject lineRecord = new LineRecordSobject(lineInfo,mapOfxRecord.get(lineInfo.id));
                listLineRecordSobject.add(lineRecord);
            }
        }
        return listLineRecordSobject;
    }
    /*
     * This method written bind data with requet which will reduce some of the data 
     * dependency from client
    */
    private void bindingDataWithRequest(COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig , List<INVT_Structure.INVT_LineInfo> requestLine , Map<Id,Sobject> mapOfxRecord)
    {
        for(INVT_Structure.INVT_LineInfo lineInfo : requestLine){
            Sobject tempsObjectRec = mapOfxRecord.get(lineInfo.id);
            if(tempsObjectRec !=null){
                lineInfo.name = String.valueOf(tempsObjectRec.get('Name'));
       
                Sobject productsobj = tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Product);
                if(productsobj != null){
                    lineInfo.partName = String.valueOf(productsobj.get(inventoryProcessConfig.Related_Product_Field));
                    lineInfo.isStockable = lineInfo.isStockable == null ? (Boolean) productsobj.get('SVMXC__Stockable__c'): lineInfo.isStockable;
                    lineInfo.isSerializedTracked = lineInfo.isSerializedTracked == null ? (Boolean) productsobj.get('SVMXC__Enable_Serialized_Tracking__c'): lineInfo.isSerializedTracked;
                    lineInfo.isBatchLotTracked = lineInfo.isBatchLotTracked == null ? (Boolean)productsobj.get('SVMXC__SM_Enable_Batch_Lot_Tracking__c') : lineInfo.isBatchLotTracked;
                }
            }
        }            
        
    }
    /*
        Save entry :
        1. Will create a product stock if not exist
        2. Update the stock
        3. Serial Record update and creation
        4. Closer action and Related record update
        5. Email Notification in case of negative stock
        6. Create history for Stock and Serailc chnages
    */
    public INVT_Structure.INVT_Response updateInventoryProcess(final INVT_Structure.InventoryProcessInfo inventoryProcessInfo)
    {
        Savepoint sp = Database.setSavepoint();
        

        //Creation of product stock if not found for specific product with location
        List<INVT_Structure.INVT_LineInfo> requestLines = inventoryProcessInfo.lineInfoList;
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        
        response.success = true;
        Sobject headerObject = null;
        try{
            
            final COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig = getInventoryConfiguration( inventoryProcessInfo.processId );
            List<SObject> xRecords = retrieveInventoryProcessRecords( inventoryProcessInfo, inventoryProcessConfig  );
            
            //Location map to check is stocking location or not.
            //Added for location defect
            Boolean isSourceStockingLocation = false;
            Boolean isTargetStockingLocation = false;
            Sobject sourceLocationSObject = null;
            Sobject targetLocationSObject = null;
            
            
            List<Sobject> sourceTargetLocation = getAllSourceTargetLocations(inventoryProcessConfig , xRecords);
            this.nonStockinglocationSet = getNonStockingLocation(sourceTargetLocation);
            
            
            Map<Id,Sobject> mapOfxRecord = getSobjectLineMap(xRecords);
            //Modifying reqeust 
            //We are binding product stockable detail with reqeust in below method
            bindingDataWithRequest(inventoryProcessConfig, requestLines , mapOfxRecord);
            
            //Modifying reqeust 
            List<LineRecordSobject> lineRecordSobjectWrapper = buildLineRecordWrapper(requestLines, mapOfxRecord);
            if(inventoryProcessConfig.Is_Multiline_Transaction)
            {
                headerObject = getHeaderRecord(inventoryProcessConfig, inventoryProcessInfo.headerRecordId);
            }
            List<INVT_Structure.INVT_Error> invt_errorList1 = onSubmitValidation(inventoryProcessConfig, requestLines, mapOfxRecord);
            if(invt_errorList1.isEmpty())
            {
                List<INVT_Structure.INVT_Error> invt_errorList2 = validateSerialNumberUniquness(inventoryProcessConfig, requestLines);
                if(invt_errorList2.isEmpty())
                {
                    List<INVT_Structure.INVT_Error> invt_errorList = new List<INVT_Structure.INVT_Error>();
                    if(inventoryProcessConfig.Enable_Serial_Selection)
                    {
                        invt_errorList = validateSerialNumbers(requestLines,inventoryProcessConfig, mapOfxRecord);
                    }
                    System.debug('invt_errorList: '+ invt_errorList);
                    if(invt_errorList.isEmpty())
                    {
                        
                        Map<String,ProductStock> productStockMap = getProductStockInfo(inventoryProcessConfig,xRecords , true);
                        
                        Schema.SObjectType STProductStock, STProductSerial,STStockHistory;
                        STProductStock = Schema.SobjectType.SVMXC__Product_Stock__c.getSobjectType();
                        Set<String> setOfRecordId = new Set<String>();
                        //List<SObject> newSourceStock = new List<Sobject>();
                        //List<SObject> newSourceStockDecreased = new List<Sobject>();
                        
                        System.debug('source and target action : '+ inventoryProcessConfig.Source_Action + ' '+inventoryProcessConfig.Target_Action);
                        
                        List<Sobject> allStockSobject = new  List<SObject>();
                        if(String.isNotBlank(inventoryProcessConfig.Number_of_locations))
                        {
                            
                            Set<string> setNewSourceStock = new Set<String>();
                            Set<String> setNewSourceStockDecreased = new Set<String>();
                            Set<String> setNewTargetStock = new Set<String>();
                            
                            for(INVT_Structure.INVT_LineInfo lineIfo: requestLines)
                            {
                                //setOfRecordId.add(lineIfo.id);// To update the line for closer actions : currently not in use
                                
                                String productId = lineIfo.productId;
                                String fromLocation = lineIfo.fromLocationId;
                                String toLocation = lineIfo.toLocationId;
                                Double actualQuantity = lineIfo.actualQuantity;
                                
                                
                                if( (actualQuantity != null && actualQuantity > 0) || ( actualQuantity == 0 && (inventoryProcessConfig.Source_Action == 'Set' || inventoryProcessConfig.Target_Action == 'Set')))
                                {
                                    Boolean sourceFound = false;
                                    Boolean sourceDecreasedFound = false;
                                    Boolean targetFound = false;
                                    for(ProductStock tempProductStock : productStockMap.values())
                                    {
                                        
                                        if(productId == tempProductStock.productId && fromLocation == tempProductStock.locationId)
                                        {
                                            if(tempProductStock.productStockStatus == inventoryProcessConfig.Source_Status)
                                            {
                                                sourceFound = true;
                                            }
                                            if(tempProductStock.productStockStatus == 'DECREASED')
                                            {
                                                sourceDecreasedFound = true;
                                            }
                                            
                                        }
                                        System.debug(inventoryProcessConfig.Target_Status);
                                        System.debug(tempProductStock.productStockStatus);
                                        if(productId == tempProductStock.productId && toLocation == tempProductStock.locationId && tempProductStock.productStockStatus == inventoryProcessConfig.Target_Status)
                                        {
                                            System.debug('targetFound: '+ targetFound);
                                            targetFound = true;
                                        }
                                        if(String.isBlank(toLocation))
                                        {
                                            System.debug('targetFound: '+ targetFound);
                                            if(productId == tempProductStock.productId && (tempProductStock.productStockStatus).toUpperCase() == 'DECREASED' && !(inventoryProcessConfig.Number_of_locations.ToUpperCase() == 'ONE' && inventoryProcessConfig.Source_Action.ToUpperCase() == 'SET'))
                                            {
                                                targetFound = true;
                                            }
                                        }
                                        if(inventoryProcessConfig.Number_of_locations.ToUpperCase() == 'ONE' && inventoryProcessConfig.Source_Action.ToUpperCase() == 'SET')
                                        {
                                            System.debug('targetFound: '+ targetFound);
                                            if(productId == tempProductStock.productId && fromLocation == tempProductStock.locationId && (tempProductStock.productStockStatus).toUpperCase() == 'ADJUSTED')
                                            {
                                                targetFound = true;
                                            }
                                        }
                                    }
                                    if(!sourceFound && !nonStockinglocationSet.contains(fromLocation) && !setNewSourceStock.contains(productId+fromLocation+inventoryProcessConfig.Source_Status))
                                    {
                                        sObject productStockSobj = STProductStock.newSObject();
                                        productStockSobj.put('SVMXC__Quantity2__c', 0);
                                        productStockSobj.put('SVMXC__ActualQtyBeforeUpdate__c', productStockSobj.get('SVMXC__Quantity2__c') );
                                        productStockSobj.put('SVMXC__Product__c', productId);
                                        productStockSobj.put('SVMXC__Location__c', fromLocation);
                                        productStockSobj.put('SVMXC__Status__c', inventoryProcessConfig.Source_Status);
                                        //newSourceStock.add(productStockSobj);
                                        allStockSobject.add(productStockSobj);
                                        setNewSourceStock.add(productId+fromLocation+inventoryProcessConfig.Source_Status);    
                                    }
                                    if(!sourceDecreasedFound && !nonStockinglocationSet.contains(fromLocation) && !setNewSourceStockDecreased.contains(productId+fromLocation+'DECREASED'))
                                    {
                                        sObject productStockSobj = STProductStock.newSObject();
                                        productStockSobj.put('SVMXC__Quantity2__c', 0);
                                        productStockSobj.put('SVMXC__ActualQtyBeforeUpdate__c', productStockSobj.get('SVMXC__Quantity2__c') );
                                        productStockSobj.put('SVMXC__Product__c', productId);
                                        productStockSobj.put('SVMXC__Location__c', fromLocation);
                                        productStockSobj.put('SVMXC__Status__c', 'DECREASED');
                                        //newSourceStockDecreased.add(productStockSobj);
                                        allStockSobject.add(productStockSobj);
                                        setNewSourceStockDecreased.add(productId+fromLocation+'DECREASED');
                                        
                                    }
                                    
                                    if(!targetFound)
                                    {
                                        sObject productStockSobj = STProductStock.newSObject();
                                        productStockSobj.put('SVMXC__Quantity2__c', 0);
                                        productStockSobj.put('SVMXC__ActualQtyBeforeUpdate__c', 0);
                                        productStockSobj.put('SVMXC__Product__c', productId); 
                                        if(!String.isBlank(toLocation)  && !nonStockinglocationSet.contains(toLocation) && !String.isBlank(productId) && !String.isBlank(productId) && !String.isBlank(toLocation) && !setNewTargetStock.contains(productId+fromLocation+inventoryProcessConfig.Target_Status))
                                        {
                                            productStockSobj.put('SVMXC__Status__c', inventoryProcessConfig.Target_Status);
                                            productStockSobj.put('SVMXC__Location__c', toLocation);
                                            allStockSobject.add(productStockSobj);
                                            setNewTargetStock.add(productId+fromLocation+inventoryProcessConfig.Target_Status);
                                        }
                                        if(inventoryProcessConfig.Number_of_locations.toUpperCase() == 'ONE' && inventoryProcessConfig.Source_Action.toUpperCase() == 'SET' && !nonStockinglocationSet.contains(fromLocation) && !setNewTargetStock.contains(productId+fromLocation+'ADJUSTED'))
                                        {
                                            productStockSobj.put('SVMXC__Status__c', 'ADJUSTED');
                                            productStockSobj.put('SVMXC__Location__c', fromLocation);
                                            allStockSobject.add(productStockSobj);
                                            setNewTargetStock.add(productId+fromLocation+'ADJUSTED');
                                        }
                                    }
                                    System.debug('targetFound: '+ targetFound);
                                    System.debug('sourceFound: '+ sourceFound);
                                    System.debug('sourceDecreasedFound: '+ sourceDecreasedFound);
                                    
                                }
                            }
                            
                            System.debug('upsert: '+ allStockSobject);
                            if(allStockSobject!=null && !allStockSobject.isEmpty())
                            {
                                //insert allStockSobject;
                                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(allStockSobject, COMM_SecurityUtils.Access.Createable)){
                                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    insert allStockSobject;
                                }
                                else{
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                } 
                            }
                            if(!allStockSobject.isEmpty())
                            {
                                productStockMap.putAll(buildProductStockMap(allStockSobject));
                            }
                            
                        }
                        Map<String,SVMXC__Product_Stock__c> productStockActualRecordMap = getProductStockMap(productStockMap);
                        List<Sobject> listOfhistoryObjectRecords = new List<Sobject>();
                        //Update Product Stock Object qty
                        updateProductStock(inventoryProcessConfig, requestLines, productStockActualRecordMap, mapOfxRecord, listOfhistoryObjectRecords, headerObject);
                        
                        //Update stock serial product stock in case of batch-non serial will update qty as well
                        updateStockSerial(inventoryProcessConfig,requestLines,productStockActualRecordMap, listOfhistoryObjectRecords, headerObject, productStockMap);
                        
                        List<String> listAllClonedIds = new List<String>();
                        //This method will perform closer action and related line update
                        SVMX_doUpdateXLines(inventoryProcessInfo, inventoryProcessConfig, setOfRecordId, lineRecordSobjectWrapper , headerObject, listAllClonedIds);
                        
                        //Will create product stock history
                        updateStockedHistory(listOfhistoryObjectRecords);//
                        
                        //Send and generate the email based on setting on negative stock
                        emailNotification(inventoryProcessInfo, inventoryProcessConfig,requestLines,xRecords, headerObject);

                        //Added for Batch/Lot API
                        if (!listAllClonedIds.isEmpty()) {
                            response.message = 'Inventory Lines have been partially processed for this Inventory Transaction';
                            response.data = 'newLines:['+String.join(listAllClonedIds, ',')+']';
                        }
                        
                        //End
                    }else
                    {
                        throw new InventoryException(invt_errorList);
                        //response.errordata = invt_errorList;
                        //response.success = false;
                    }
                }
                else
                {
                    throw new InventoryException(invt_errorList2);
                }
            }else{
                throw new InventoryException(invt_errorList1);
                //response.errordata = invt_errorList1;
                //response.success = false;
            }
        }catch(InventoryException e)
        {
           
            
            response.success = false;
            response.errordata = e.lstOfError;
            //response.errordata = String.valueOf(e.lstOfError);
        }
        catch(Exception e)
        {
            response.success = false;
            System.debug('exeception in submitInventoryProcess : '+ e.getStackTraceString());
            System.debug('exeception in submitInventoryProcess : '+ e.getMessage());
            throw e; 
        }
        finally{
            
            if(!response.success)
            {
               Database.rollback(sp); 
            }
        }
        return response;
    }
    private void updateProductStock(COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig , List<INVT_Structure.INVT_LineInfo> requestLines, Map<String,SVMXC__Product_Stock__c> productStockMap ,Map<Id, Sobject> mapOfxRecords, List<Sobject> listOfhistoryObjectRecords , Sobject headerObject)
    {
        
        //Map<String, List<INVT_Structure.INVT_LineInfo>> mapEMailLineList = new Map<String, List<INVT_Structure.INVT_LineInfo>>();
        if(String.isNotEmpty(inventoryProcessConfig.Number_of_locations)){
            for(INVT_Structure.INVT_LineInfo lineIfo: requestLines)
            {
                System.debug('lineIfo '+lineIfo);
                String productId = lineIfo.productId;
                String fromLocation = lineIfo.fromLocationId;
                String toLocation = lineIfo.toLocationId;
                Double actualQuantity = lineIfo.actualQuantity;
                
                System.debug(productId + '_' + toLocation + '_' + inventoryProcessConfig.Source_Status);
                System.debug(productId + '_' + fromLocation + '_' + inventoryProcessConfig.Source_Status);
                if( (actualQuantity != null && actualQuantity > 0) || ( actualQuantity == 0 && (inventoryProcessConfig.Source_Action == 'Set' || inventoryProcessConfig.Target_Action == 'Set')))
                {
                    Boolean isNegativeQty = false;
                    Double newQuantity = 0;
                    Double adjusetedQty = 0;
                    
                    String key = productId + '_'+ fromLocation+ '_' + inventoryProcessConfig.Source_Status;
                    
                    //Source product stock
                    SVMXC__Product_Stock__c productStock = productStockMap.get(key);
                    
                    //Source stopck update
                    if(!nonStockinglocationSet.contains(fromLocation)){
                        if (inventoryProcessConfig.Source_Action == 'Decrease') 
                        {
                            newQuantity = productStock.SVMXC__Quantity2__c - actualQuantity;
                            
                            if(lineIfo.isSerializedTracked && newQuantity >= 0 )
                            {
                                newQuantity = newQuantity;
                            }
                            else if(!lineIfo.isSerializedTracked &&  newQuantity >= 0 )
                            {
                                newQuantity = newQuantity;
                            }
                            else if(!inventoryProcessConfig.allow_inventory_withoutSufficientStock)
                            {
                                throw new InventoryException(comm_svmxc_utils3.getTAG057());
                                
                            }else
                            {
                                
                                StockDetail stockDetail = new StockDetail();
                                stockDetail.lineId = lineIfo.id;
                                stockDetail.quentityBefore = productStock.SVMXC__Quantity2__c;
                                stockDetail.transactionQuentity = actualQuantity;
                                stockDetail.quantityAfter = newQuantity;
                                //stockDetail.lineName = String.valueOf(mapOfxRecords.get(lineIfo.id).get('Name')) ;
                                stockDetail.lineName = lineIfo.name ;
                                stockDetailWrapper.put(lineIfo.id,stockDetail);
                                
                                if(inventoryProcessConfig.Email_For_Negative_Stock_Alert !=null )
                                {
                                    if(!mapEMailLineList.containsKey(inventoryProcessConfig.Email_For_Negative_Stock_Alert))
                                    {
                                        mapEMailLineList.put(inventoryProcessConfig.Email_For_Negative_Stock_Alert, new List<INVT_Structure.INVT_LineInfo>());
                                    }
                                    mapEMailLineList.get(inventoryProcessConfig.Email_For_Negative_Stock_Alert).add(lineIfo);
                                }
                                if(inventoryProcessConfig.Is_Email_Sent_To_Location_Owner && productStock.SVMXC__Location__r.SVMXC__Email__c != null )
                                {
                                    if(!mapEMailLineList.containsKey(productStock.SVMXC__Location__r.SVMXC__Email__c))
                                    {
                                        mapEMailLineList.put(productStock.SVMXC__Location__r.SVMXC__Email__c, new List<INVT_Structure.INVT_LineInfo>());
                                    }
                                    mapEMailLineList.get(productStock.SVMXC__Location__r.SVMXC__Email__c).add(lineIfo);
                                } 
                                isNegativeQty = true;
                                newQuantity = 0;
                            }
                            System.debug('productStock: '+ productStock);
                            System.debug('productStockStatus: '+ productStock.SVMXC__Status__c);
                            if(newQuantity < 0)
                            {
                                newQuantity = 0;
                                //this line need to send for alert
                            }
                            createStockHistoryRefrence(listOfhistoryObjectRecords, inventoryProcessConfig,actualQuantity,productStock.SVMXC__Quantity2__c, newQuantity , productId, productStock.id, fromLocation, inventoryProcessConfig.Source_Action, inventoryProcessConfig.Source_Status, lineIfo.id, headerObject, isNegativeQty);
                            productStock = updateProducStockRefrence(productStock,newQuantity);
                            isNegativeQty = false;
                        }
                        if(inventoryProcessConfig.Source_Action == 'Increase')
                        {
                            newQuantity =  productStock.SVMXC__Quantity2__c + actualQuantity;
                            createStockHistoryRefrence(listOfhistoryObjectRecords, inventoryProcessConfig,actualQuantity,productStock.SVMXC__Quantity2__c, newQuantity , productId, productStock.id, fromLocation, inventoryProcessConfig.Source_Action, inventoryProcessConfig.Source_Status, lineIfo.id, headerObject, false);
                            productStock = updateProducStockRefrence(productStock,newQuantity);
                        }
                        if(inventoryProcessConfig.Source_Action == 'Set') // Condition for stock adjustment quauntity 
                        {
                            adjusetedQty = productStock.SVMXC__Quantity2__c - actualQuantity;
                            newQuantity = actualQuantity; //Adusted quauntity 
                            createStockHistoryRefrence(listOfhistoryObjectRecords, inventoryProcessConfig,actualQuantity,productStock.SVMXC__Quantity2__c, newQuantity , productId, productStock.id, fromLocation, inventoryProcessConfig.Source_Action, inventoryProcessConfig.Source_Status, lineIfo.id, headerObject, false);
                            productStock = updateProducStockRefrence(productStock,newQuantity);
                            
                        }
                        
                        // Adjusted product stock 
                        key = productId + '_' + fromLocation + '_' + 'ADJUSTED';
                        productStock = productStockMap.get(key);
                        
                        if(String.isNotEmpty(inventoryProcessConfig.Number_of_locations) && inventoryProcessConfig.Number_of_locations.ToUpperCase() == 'ONE' && inventoryProcessConfig.Source_Action.ToUpperCase() == 'SET' && lineIfo.isSerializedTracked)
                        {
                            //key = productId + '_' + fromLocation + '_' + 'ADJUSTED';
                            //productStock = productStockMap.get(key);
                            if(adjusetedQty > 0)
                            {
                                newQuantity =  productStock.SVMXC__Quantity2__c  + adjusetedQty ;
                            }else
                            {
                                newQuantity = productStock.SVMXC__Quantity2__c;
                            }
                            productStock = updateProducStockRefrence(productStock,newQuantity);
                        }
                        
                    }
                    
                    //Target Product Stock
                    
                    key = productId + '_' + toLocation + '_' + inventoryProcessConfig.Target_Status;
                    if(nonStockinglocationSet.contains(toLocation))
                    {
                        key = productId + '_' + fromLocation + '_' + 'DECREASED';  
                    }
                    productStock = productStockMap.get(key);
                    if(inventoryProcessConfig.Target_Action == 'Increase')
                    {
                        newQuantity = productStock.SVMXC__Quantity2__c + actualQuantity;
                        createStockHistoryRefrence(listOfhistoryObjectRecords, inventoryProcessConfig,actualQuantity,productStock.SVMXC__Quantity2__c, newQuantity , productId, productStock.id, toLocation, inventoryProcessConfig.Target_Action, inventoryProcessConfig.Target_Status, lineIfo.id, headerObject, false);
                        productStock = updateProducStockRefrence(productStock,newQuantity);
                    }
                    if(inventoryProcessConfig.Target_Action == 'Decrease')
                    {
                        newQuantity = productStock.SVMXC__Quantity2__c - actualQuantity;
                        if(newQuantity >= 0)
                        {
                            newQuantity = newQuantity;
                        }
                        else if(!inventoryProcessConfig.allow_inventory_withoutSufficientStock)
                        {
                            throw new InventoryException(comm_svmxc_utils3.getTAG057());
                            
                        }else
                        {
                            StockDetail stockDetail = new StockDetail();
                            stockDetail.lineId = lineIfo.id;
                            stockDetail.quentityBefore = productStock.SVMXC__Quantity2__c;
                            stockDetail.transactionQuentity = actualQuantity;
                            stockDetail.quantityAfter = newQuantity;
                            //stockDetail.lineName = String.valueOf(mapOfxRecords.get(lineIfo.id).get('Name'));
                            stockDetail.lineName = lineIfo.name;
                            stockDetailWrapper.put(lineIfo.id,stockDetail);
                            
                            if(inventoryProcessConfig.Email_For_Negative_Stock_Alert !=null )
                            {
                                if(!mapEMailLineList.containsKey(inventoryProcessConfig.Email_For_Negative_Stock_Alert))
                                {
                                    mapEMailLineList.put(inventoryProcessConfig.Email_For_Negative_Stock_Alert, new List<INVT_Structure.INVT_LineInfo>());
                                }
                                mapEMailLineList.get(inventoryProcessConfig.Email_For_Negative_Stock_Alert).add(lineIfo);
                            }
                            if(inventoryProcessConfig.Is_Email_Sent_To_Location_Owner && productStock.SVMXC__Location__r.SVMXC__Email__c != null )
                            {
                                if(!mapEMailLineList.containsKey(productStock.SVMXC__Location__r.SVMXC__Email__c))
                                {
                                    mapEMailLineList.put(productStock.SVMXC__Location__r.SVMXC__Email__c, new List<INVT_Structure.INVT_LineInfo>());
                                }
                                mapEMailLineList.get(productStock.SVMXC__Location__r.SVMXC__Email__c).add(lineIfo);
                            } 
                            isNegativeQty = true;
                            newQuantity = 0;
                        }
                        createStockHistoryRefrence(listOfhistoryObjectRecords, inventoryProcessConfig,actualQuantity,productStock.SVMXC__Quantity2__c, newQuantity , productId, productStock.id, toLocation, inventoryProcessConfig.Target_Action, inventoryProcessConfig.Target_Status, lineIfo.id, headerObject, isNegativeQty);
                        productStock = updateProducStockRefrence(productStock,newQuantity);
                        isNegativeQty = false;
                    }
                    if(inventoryProcessConfig.Target_Action == 'Set')
                    {
                        newQuantity = actualQuantity;
                        createStockHistoryRefrence(listOfhistoryObjectRecords, inventoryProcessConfig,actualQuantity,productStock.SVMXC__Quantity2__c, newQuantity , productId, productStock.id, toLocation, inventoryProcessConfig.Target_Action, inventoryProcessConfig.Target_Status, lineIfo.id, headerObject, false);
                        productStock = updateProducStockRefrence(productStock,newQuantity);
                    }
                }
            }
            System.debug('productStockMap: '+ productStockMap);
            //update productStockMap.values();
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(productStockMap.values(), COMM_SecurityUtils.Access.Updateable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update productStockMap.values();
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
        }
    }
    private SVMXC__Product_Stock__c updateProducStockRefrence(SVMXC__Product_Stock__c productStockRef, Double newQuantity)
    {
        productStockRef.put('SVMXC__Quantity2__c', newQuantity);
        return productStockRef;
    }
    private void  createStockHistoryRefrence(List<Sobject> historyObjectRecords, COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig , Double actualQuantity, Decimal quentityBeforeChange, Double newQuantity, String productId, ID productStockId,String locationId, String changeType, String stockStatus, Id lineinfoVarId, Sobject headerObject, Boolean isNegative)
    {
        if (inventoryProcessConfig.Maintain_Stock_History) 
        { //Maintain the Stock History
            Sobject stockHistory = schema.Sobjecttype.SVMXC__Stock_History__c.getSobjectType().newSObject();
            stockHistory.put('RecordTypeId',  Id.valueOf(COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__Stock_History__c','Stock_History')));
            stockHistory.put('SVMXC__Transaction_Type__c', inventoryProcessConfig.SVMXProcess.SVMXC__Name__c);
            stockHistory.put('SVMXC__Inventory_Process__c',inventoryProcessConfig.SVMXProcess.Id);
            stockHistory.put('SVMXC__Transaction_Quantity2__c', actualQuantity);
            stockHistory.put('SVMXC__Quantity_before_change2__c', quentityBeforeChange);
            stockHistory.put('SVMXC__Quantity_after_change2__c', newQuantity);
            stockHistory.put('SVMXC__Product__c', productId);
            stockHistory.put('SVMXC__Product_Stock__c', productStockId);
            stockHistory.put('SVMXC__Negative_Stock__c', isNegative);
            stockHistory.put('SVMXC__Location__c', locationId);
            stockHistory.put('SVMXC__Date_Changed__c',datetime.now());
            stockHistory.put('SVMXC__Changed_By__c', UserInfo.getUserId());
            stockHistory.put('SVMXC__Change_Type__c', changeType);
            stockHistory.put('SVMXC__Status__c', stockStatus);
            if(inventoryProcessConfig.Is_Multiline_Transaction)
            {
                stockHistory.put(inventoryProcessConfig.Stock_History_Header_API_Name,headerObject.id);
                stockHistory.put(inventoryProcessConfig.Stock_History_Line_API_Name,lineinfoVarId);
            }else
            {
                stockHistory.put(inventoryProcessConfig.Stock_History_Header_API_Name,lineinfoVarId);
            }
            
            historyObjectRecords.add(stockHistory);
        }
    }
    private void updateStockSerial(COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig,List<INVT_Structure.INVT_LineInfo> requestLines, Map<String,SVMXC__Product_Stock__c> productStockMap, List<Sobject> listStockhistoryObjectRecords, Sobject headerObject, Map<String,ProductStock> productStockMap1)
    {
        System.debug('productStockMap: '+ productStockMap);
        System.debug('requestLines '+requestLines);
        
        //Batch lot
        List<SVMXC__Product_Serial__c> stockedSerialToBeDeleted = new List<SVMXC__Product_Serial__c>();
        
        List<SVMXC__Product_Serial__c> productstockSerial = new List<SVMXC__Product_Serial__c>();
        List<String> sourceProductStockIds = new  List<String>();
        List<String> listOfLineInofId = new  List<String>(); 
        List<Decimal> listOfOldQty = new List<Decimal>();
        for(INVT_Structure.INVT_LineInfo lineinfo : requestLines)
        {
            //String key = lineinfo.productId +'_'+lineinfo.toLocationId +'_'+ lineinfo.targetStatus;
            //System.debug('key: '+ key );
            
            if(String.isNotEmpty(inventoryProcessConfig.Number_of_locations)) {
                
                if(lineinfo.isBatchLotTracked && !lineinfo.isSerializedTracked)
                {
                    Map<String,ProductSerial> mapOfTargetProductSerial = new Map<String,ProductSerial>();
                    
                    String key = lineinfo.productId +'_'+lineinfo.toLocationId +'_'+ inventoryProcessConfig.Target_Status;
                    if(nonStockinglocationSet.contains(lineinfo.toLocationId))
                    {
                        key = lineinfo.productId +'_'+lineinfo.fromLocationId +'_'+ 'DECREASED';
                    }
                    ProductStock productStock1 = productStockMap1.get(key);
                    
                    
                    for(ProductSerial stockedSerial : productStock1.productSerialList)
                    {
                        System.debug('serial_name: '+ stockedSerial.Name);
                        mapOfTargetProductSerial.put( productStock1.productId+'_'+stockedSerial.batchLotId +'_'+ stockedSerial.Name ,stockedSerial);
                    }
                    
                    SVMXC__Product_Stock__c productStock = productStockMap.get(key);
                    for(INVT_Structure.INVT_ProductSerialInfo productSerialInfo : lineinfo.targetSerialList)
                    {
                        
                        if(productSerialInfo.batchLotTargetQuantity != null && productSerialInfo.batchLotTargetQuantity != 0)
                        {
                            Double newQuentity = productSerialInfo.batchLotQuantity - productSerialInfo.batchLotTargetQuantity;
                            Double batchLotTargetQty = productSerialInfo.batchLotTargetQuantity;
                            
                            if(newQuentity > 0)
                            {   
                                listOfLineInofId.add(lineinfo.id);
                                listOfOldQty.add(productSerialInfo.batchLotQuantity);//capturing old qty
                                if(String.isNotEmpty(productSerialInfo.productSerialId))
                                {
                                    sourceProductStockIds.add(productSerialInfo.productStockId);
                                }else
                                {
                                    sourceProductStockIds.add(null);
                                }                            
                                SVMXC__Product_Serial__c stockSerial1 = createProducStockSerialRefrence(productSerialInfo.productSerialId,productSerialInfo.serialName,lineinfo.productId,productSerialInfo.productStockId, true, true, newQuentity ,productSerialInfo.batchLotId);  
                                
                                productstockSerial.add(stockSerial1);
                                
                            }
                            if(newQuentity == 0)
                            {
                                SVMXC__Product_Serial__c stockSerial3 = new SVMXC__Product_Serial__c();
                                stockSerial3.id = productSerialInfo.productSerialId;
                                stockedSerialToBeDeleted.add(stockSerial3);
                            }
                            if(newQuentity >= 0)
                            {
                                listOfLineInofId.add(lineinfo.id);
                                if(String.isNotEmpty(productSerialInfo.productSerialId))
                                {
                                    sourceProductStockIds.add(productSerialInfo.productStockId);
                                }else
                                {
                                    sourceProductStockIds.add(null);
                                }
                                SVMXC__Product_Serial__c stockSerial2  = null;
                                System.debug( mapOfTargetProductSerial.get(productStock.SVMXC__Product__c+'_'+productSerialInfo.batchLotId + '_'+ productSerialInfo.serialName));
                                if(mapOfTargetProductSerial.containsKey(productStock.SVMXC__Product__c+'_'+productSerialInfo.batchLotId + '_'+ productSerialInfo.serialName))
                                {
                                    //If batch stocked serial already exist at the target
                                    
                                    ProductSerial stockedSerialRef =  mapOfTargetProductSerial.get(productStock.SVMXC__Product__c+'_'+productSerialInfo.batchLotId+ '_'+ productSerialInfo.serialName);
                                    batchLotTargetQty = stockedSerialRef.batchLotQuantity + batchLotTargetQty ;
                                    stockSerial2 = createProducStockSerialRefrence(stockedSerialRef.id,stockedSerialRef.name,lineinfo.productId,productStock.id, true, true, batchLotTargetQty ,stockedSerialRef.batchLotId);  
                                    
                                    listOfOldQty.add(stockedSerialRef.batchLotQuantity);
                                    
                                }else
                                {
                                    //If batch stocked serial not exist at target
                                    listOfOldQty.add(null);
                                    stockSerial2 = createProducStockSerialRefrence(null,productSerialInfo.serialName,lineinfo.productId,productStock.id, true, true, batchLotTargetQty, productSerialInfo.batchLotId);  
                                    
                                }
                                productstockSerial.add(stockSerial2);
                            }
                            
                        }   
                        
                    } 
                    mapOfTargetProductSerial.clear();
                }// added isBatchLotTracked for batch lot
                else if(inventoryProcessConfig.Enable_Serial_Selection || (lineinfo.isBatchLotTracked && lineinfo.isSerializedTracked))
                {
                    
                    if(inventoryProcessConfig.Number_of_locations.toUpperCase() == 'ONE')
                    {
                        if(!nonStockinglocationSet.contains(lineinfo.fromLocationId)){
                            if(inventoryProcessConfig.Source_Action.toUpperCase() == 'Decrease')
                            {
                                for(INVT_Structure.INVT_ProductSerialInfo productSerialInfo : lineinfo.targetSerialList)
                                {
                                    //De-linking serial from product stock and if enterned any manual serial it should have product id
                                    listOfLineInofId.add(lineinfo.id);
                                    listOfOldQty.add(null);
                                    if(String.isNotEmpty(productSerialInfo.productSerialId))
                                    {
                                        sourceProductStockIds.add(productSerialInfo.productStockId);
                                    }else
                                    {
                                        sourceProductStockIds.add(null);
                                    }
                                    SVMXC__Product_Serial__c stockSerial = createProducStockSerialRefrence(productSerialInfo.productSerialId,productSerialInfo.serialName,lineinfo.productId,null, true, false, null, productSerialInfo.batchLotId); 
                                    productstockSerial.add(stockSerial);
                                }
                            }
                            if(inventoryProcessConfig.Source_Action.toUpperCase() == 'SET' || inventoryProcessConfig.Source_Action == 'Increase')
                            {
                                //String key = lineinfo.productId +'_'+lineinfo.fromLocationId +'_'+ lineinfo.sourceStatus;
                                String key = lineinfo.productId +'_'+lineinfo.fromLocationId +'_'+ inventoryProcessConfig.Source_Status;
                                
                                for(INVT_Structure.INVT_ProductSerialInfo productSerialInfo : lineinfo.targetSerialList)
                                {
                                    //Added to capture the history record 
                                    listOfOldQty.add(null);
                                    listOfLineInofId.add(lineinfo.id);
                                    if(String.isNotEmpty(productSerialInfo.productSerialId))
                                    {
                                        sourceProductStockIds.add(productSerialInfo.productStockId);
                                    }else
                                    {
                                        sourceProductStockIds.add(null);
                                    }
                                    
                                    SVMXC__Product_Stock__c productStock = productStockMap.get(key);
                                    
                                    System.debug('productStock: '+ productStock);
                                    SVMXC__Product_Serial__c stockSerial = createProducStockSerialRefrence(productSerialInfo.productSerialId,productSerialInfo.serialName,productStock.SVMXC__Product__c,productStock.id, true, false ,null, productSerialInfo.batchLotId);
                                    System.debug('productSerialInfo after target '+productSerialInfo);
                                    productstockSerial.add(stockSerial);
                                }
                                
                                if(inventoryProcessConfig.Source_Action.toUpperCase() == 'SET')
                                {
                                    key = lineinfo.productId +'_'+lineinfo.fromLocationId +'_'+ 'ADJUSTED';
                                    
                                    
                                    for(INVT_Structure.INVT_ProductSerialInfo productSerialInfo : lineinfo.sourceSerialList)
                                    {
                                        System.debug('productSerialInfo before source '+productSerialInfo);
                                        
                                        //Added to capture the history record
                                        listOfLineInofId.add(lineinfo.id);
                                        listOfOldQty.add(null);
                                        if(String.isNotEmpty(productSerialInfo.productSerialId))
                                        {
                                            sourceProductStockIds.add(productSerialInfo.productStockId);// available
                                        }else
                                        {
                                            sourceProductStockIds.add(null);
                                        }
                                        
                                        SVMXC__Product_Stock__c productStock = productStockMap.get(key);
                                        // productStock.id
                                        System.debug('productStock: '+ productStock);
                                        SVMXC__Product_Serial__c stockSerial = createProducStockSerialRefrence(productSerialInfo.productSerialId,productSerialInfo.serialName,productStock.SVMXC__Product__c,productStock.id, false, false , null, productSerialInfo.batchLotId);
                                        System.debug('productSerialInfo after source '+productSerialInfo);
                                        productstockSerial.add(stockSerial);
                                    }  
                                }
                                
                            }    
                        }   
                    }
                    else
                    {
                        //String key = lineinfo.productId +'_'+lineinfo.toLocationId +'_'+ lineinfo.targetStatus;
                        String key = lineinfo.productId +'_'+lineinfo.toLocationId +'_'+ inventoryProcessConfig.Target_Status;
                        if(nonStockinglocationSet.contains(lineinfo.toLocationId))
                        {
                            key = lineinfo.productId +'_'+lineinfo.fromLocationId +'_'+ 'DECREASED';
                        }
                        System.debug('key: '+ key );
                        for(INVT_Structure.INVT_ProductSerialInfo productSerialInfo : lineinfo.targetSerialList)
                        {
                            ////Added to capture the history record
                            listOfLineInofId.add(lineinfo.id);
                            listOfOldQty.add(null);
                            if(String.isNotEmpty(productSerialInfo.productSerialId))
                            {
                                sourceProductStockIds.add(productSerialInfo.productStockId);
                            }else
                            {
                                sourceProductStockIds.add(null);
                            }
                            SVMXC__Product_Stock__c productStock = productStockMap.get(key);
                            //Target produc stock : productStock.id
                            System.debug('productStock: '+ productStock);
                            SVMXC__Product_Serial__c stockSerial = createProducStockSerialRefrence(productSerialInfo.productSerialId,productSerialInfo.serialName,productStock.SVMXC__Product__c,productStock.id, true, false , null, productSerialInfo.batchLotId);
                            productstockSerial.add(stockSerial);
                        }
                    }
                }    
            } 
        }
        
        System.debug('productstockSerial: '+ productstockSerial);
        if(!productstockSerial.isEmpty())
        {
            //upsert productstockSerial; 
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(productstockSerial, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert productstockSerial;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
        }
        if(!stockedSerialToBeDeleted.isEmpty())
        {
            delete stockedSerialToBeDeleted;
        }
        cerateStockSerialHistoryRef(productstockSerial, inventoryProcessConfig , sourceProductStockIds,listOfLineInofId , listOfOldQty, listStockhistoryObjectRecords, headerObject);
        
    }
    private SVMXC__Product_Serial__c createProducStockSerialRefrence(String id, String serialNumber,String productId, String productStockId, Boolean isActive, Boolean isBatchNonSerialized, Double newQuentity, String batchLotId)
    {
        
        SVMXC__Product_Serial__c productStockSerialSobj = new SVMXC__Product_Serial__c();
        productStockSerialSobj.put('ID', (ID) id);
        if(String.isEmpty(id))
        {
            productStockSerialSobj.put('Name', serialNumber);
            productStockSerialSobj.put('SVMXC__Product__c', productId); 
        }
        productStockSerialSobj.put('SVMXC__Product_Stock__c', productStockId);
        productStockSerialSobj.put('SVMXC__Active__c', isActive);
        if(String.isNotEmpty(batchLotId))
        {
            productStockSerialSobj.put('SVMXC__SM_Batch_Lot2__c', batchLotId);  
        }
        if(isBatchNonSerialized)
        {
            productStockSerialSobj.put('SVMXC__SM_Quantity__c', newQuentity);
        }
        return productStockSerialSobj;
    }
    private void cerateStockSerialHistoryRef(List<SVMXC__Product_Serial__c> productstockSerial,COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig ,List<String> sourceProductStockIds,List<String> listOfLineInofId , List<Decimal> listOfOldQty, List<Sobject> listStockhistoryObjectRecords,  Sobject headerObject)
    {
        if (inventoryProcessConfig.Maintain_Serial_History && !sourceProductStockIds.isEmpty()) { //Maintain the Serial History
            Integer index = 0;
            for(SVMXC__Product_Serial__c productserial: productstockSerial)
            {
                Sobject serialHistory = schema.Sobjecttype.SVMXC__Stock_History__c.getSobjectType().newSObject();
                serialHistory.put('RecordTypeId', Id.valueOf(COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__Stock_History__c','Serial_History')));
                serialHistory.put('SVMXC__Transaction_Type__c', inventoryProcessConfig.SVMXProcess.SVMXC__Name__c);
                serialHistory.put('SVMXC__Inventory_Process__c',inventoryProcessConfig.SVMXProcess.Id);
                
                if(sourceProductStockIds.get(index) != null && productserial.SVMXC__Product_Stock__c != sourceProductStockIds.get(index))
                {
                    serialHistory.put('SVMXC__From_Product_Stock__c',sourceProductStockIds.get(index));
                }
                serialHistory.put('SVMXC__To_Product_Stock__c', productserial.SVMXC__Product_Stock__c);
                serialHistory.put('SVMXC__Date_Changed__c', datetime.now());
                serialHistory.put('SVMXC__Changed_By__c', UserInfo.getUserId());
                serialHistory.put('SVMXC__Product_Serial__c',productserial.id);
                if (productserial.SVMXC__SM_Batch_Lot2__c !=null) {//check 
                    serialHistory.put('SVMXC__SM_Batch_Lot2__c', productserial.SVMXC__SM_Batch_Lot2__c);
                    serialHistory.put('SVMXC__Quantity_before_change2__c', listOfOldQty.get(index));
                    serialHistory.put('SVMXC__Quantity_after_change2__c', productserial.SVMXC__SM_Quantity__c);
                }
                if(inventoryProcessConfig.Is_Multiline_Transaction)
                {
                    serialHistory.put(inventoryProcessConfig.Stock_History_Header_API_Name,headerObject.id);
                    serialHistory.put(inventoryProcessConfig.Stock_History_Line_API_Name,listOfLineInofId.get(index));
                }else
                {
                    serialHistory.put(inventoryProcessConfig.Stock_History_Header_API_Name,listOfLineInofId.get(index));
                }
                listStockhistoryObjectRecords.add(serialHistory);
                index ++;
            }
        }
    }
    //Added by SP
    private void updateStockedHistory(List<Sobject> listStockhistoryObjectRecords)
    {
        
        if(listStockhistoryObjectRecords.size() > 0)
        {
        
            System.System.debug('historyObjectRecords '+listStockhistoryObjectRecords);
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listStockhistoryObjectRecords, COMM_SecurityUtils.Access.Upsertable)){
            //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert listStockhistoryObjectRecords;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
            
                
        }
        
    }
    private Map<String,SVMXC__Product_Stock__c> getProductStockMap(Map<String,ProductStock> productStockMap)
    {
        Map<String, SVMXC__Product_Stock__c> productStockRecordMap = new Map<String, SVMXC__Product_Stock__c>();
        Set<Id> setOfID = new Set<Id>();
        
                    
        for(ProductStock productStock : productStockMap.values())
        {
            setOfID.add(productStock.id);
        }
        for(SVMXC__Product_Stock__c productStockRecord : [Select Id, LastModifiedDate , SVMXC__Quantity2__c, SVMXC__Location__r.SVMXC__Email__c, SVMXC__Location__c, SVMXC__Location__r.name, SVMXC__Status__c, SVMXC__Product__c, SVMXC__Product__r.Name From SVMXC__Product_Stock__c WHERE Id IN : setOfID])
        {
           String key = productStockRecord.SVMXC__Product__c +'_'+ productStockRecord.SVMXC__Location__c +'_'+ productStockRecord.SVMXC__Status__c;   
           productStockRecordMap.put(key,productStockRecord);
        }
        
        return productStockRecordMap;
    }

    private Map<String, List<INVT_Structure.INVT_LineInfo>> mapEMailLineList = new Map<String, List<INVT_Structure.INVT_LineInfo>>();
    
    private void emailNotification(final INVT_Structure.InventoryProcessInfo inventoryProcessInfo, COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig ,List<INVT_Structure.INVT_LineInfo> requestLines, List<Sobject> xRecords, Sobject headerSobject)
    {
     
        System.debug(LoggingLevel.DEBUG , 'emailNotification method entry');
        
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
       
        try{
            
            for(String emailAddress : mapEMailLineList.keySet())
            {
                String emailBody =''; 
                emailBody = comm_svmxc_utils3.getTAG021();
                for(INVT_Structure.INVT_LineInfo lineInfo  : mapEMailLineList.get(emailAddress))
                {
                    if(stockDetailWrapper.containsKey(lineInfo.id))
                    {
                        StockDetail stockDetail = stockDetailWrapper.get(lineInfo.id);
                        
                        emailBody += '\n\n' + comm_svmxc_utils3.getTAG022() + inventoryProcessConfig.Name;
                        
                        if(inventoryProcessConfig.Is_Multiline_Transaction)
                        {
                           emailBody += '\n' + comm_svmxc_utils3.getTAG023() + headerSobject.get('Name'); 
                        }
                        if(String.isNotEmpty(inventoryProcessConfig.Child_Object_Name))
                        {
                           //emailBody += '\n' + comm_svmxc_utils3.getTAG032() + lineInfo.name;  
                           emailBody += '\n' + comm_svmxc_utils3.getTAG032() + stockDetail.lineName;  
                        }
                        
                        if(String.isNotBlank(lineInfo.partName))
                        {
                            emailBody += '\n' + comm_svmxc_utils3.getTAG024() + lineInfo.partName;
                        }
                        if(String.isNotBlank(lineInfo.fromLocationName))
                        {
                            emailBody += '\n' + comm_svmxc_utils3.getTAG025() + lineInfo.fromLocationName;
                        }
                        // To do activity
                        emailBody += '\n' + comm_svmxc_utils3.getTAG026() + inventoryProcessConfig.Source_Status;
                        emailBody += '\n' + comm_svmxc_utils3.getTAG027() + stockDetail.quentityBefore;
                        emailBody += '\n' + comm_svmxc_utils3.getTAG028() + stockDetail.transactionQuentity;
                        emailBody += '\n' + comm_svmxc_utils3.getTAG029() + stockDetail.quantityAfter;
                        
                        emailBody += '\n' + comm_svmxc_utils3.getTAG030() + UserInfo.getName();
                        emailBody += '\n' + comm_svmxc_utils3.getTAG031() + DateTime.now();
                        
                        
                    }
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                String[] toAddresses = new String[] {emailAddress};
                    email.setToAddresses(toAddresses);
                email.setSubject(comm_svmxc_utils3.getTAG020());
                email.setPlainTextBody(emailBody);
                lstEmails.add(email); 
            }
            if(!lstEmails.isEmpty())
            {
                Messaging.sendEmail(lstEmails);
            }
        }catch(Exception e)
        {
            //If email exception will be not displaying on invetory ui, just we adding into log
            System.debug(LoggingLevel.DEBUG , e.getMessage());
            System.debug(LoggingLevel.DEBUG , e.getStackTraceString());
            
        }
        finally{
            System.debug(LoggingLevel.DEBUG , 'emailNotification method exit');
        }

    }
    public void SVMX_doUpdateXLines(final INVT_Structure.InventoryProcessInfo inventoryProcessInfo,COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig,  Set<String> setOfRecordId, List<LineRecordSobject> listLineRecordSobject , Sobject headerRecord, List<String> listAllClonedIds)
    {
        try{
            
            List<COMM_SVMXC_Utils3.WraperSObject> lstClonedLine = new List<COMM_SVMXC_Utils3.WraperSObject>();
            
            Map<String,List<SVMXC__ServiceMax_Config_Data__c>> closerActionsMap= getCloserActions(inventoryProcessConfig.processID);
            List<SObject> lstLineRecordTobeUpdated = new List<SObject>();
            List<SObject> listOfclonedLineToCreate = new List<SObject>();
            Boolean isAnyLineOpen = false;
            
            
            for(LineRecordSobject lineSobject : listLineRecordSobject )
            {
                INVT_Structure.INVT_LineInfo lineInfo = lineSobject.lineinfo;
                SObject record = lineSobject.sObjRecord;
                Boolean isClone = false;
                Boolean isClose = false;
                if(lineInfo.actualQuantity > 0 || (lineInfo.actualQuantity == 0 && (lineInfo.closeLine || inventoryProcessConfig.Source_Action == 'Set' || inventoryProcessConfig.Target_Action == 'Set')))
                {
                    if(lineInfo.originalQuantity - lineInfo.actualQuantity <= 0 || lineInfo.closeLine)
                    {
                        isClose = true;
                        
                    }else if(lineInfo.originalQuantity - lineInfo.actualQuantity > 0 && !lineInfo.closeLine)
                    {
                        isClone = true;
                        isAnyLineOpen = true;
                    }
                    if(isClone)
                    {
                        Sobject clonedRecord = record.clone(false,true);
                        clonedRecord.put(inventoryProcessConfig.Original_Qty_API_Name,(lineInfo.originalQuantity - lineInfo.actualQuantity));
                        if(inventoryProcessConfig.Is_User_Enter_Qty)
                            clonedRecord.put(inventoryProcessConfig.Actual_Qty_API_Name,null);
                        isClose = true;
                        listOfclonedLineToCreate.add(clonedRecord);
                    }
                    Boolean isUpdateSuccess = false;
                    if(isClose)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c cD : closerActionsMap.get('INV_Line_Closure_Action'))
                        {
                            COMM_SVMXC_Utils3.WraperSObject oWraperSObject;
                            oWraperSObject = comm_svmxc_utils3.sObjectUpdate(record, cD.SVMXC__Field_Name__c, cD.SVMXC__Display_Type__c, cD.SVMXC__Operand__c,cD.SVMXC__Object_Name__c );
                            if(oWraperSObject.IsSuccess)
                            {
                                record = oWraperSObject.sObj;
                                isUpdateSuccess = true;
                            }
                            
                        }
                        if(inventoryProcessConfig.Is_User_Enter_Qty)
                            record.put(inventoryProcessConfig.Actual_Qty_API_Name,lineInfo.actualQuantity); 
                        if(isUpdateSuccess)
                        {
                            lstLineRecordTobeUpdated.add(record);
                        }
                    }
                }
                
            }
            
            System.debug('lstLineRecordTobeUpdated: '+ lstLineRecordTobeUpdated);
            if(!lstLineRecordTobeUpdated.isEmpty())
            {
                //update lstLineRecordTobeUpdated;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstLineRecordTobeUpdated, COMM_SecurityUtils.Access.Updateable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update lstLineRecordTobeUpdated;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            }
            if(!listOfclonedLineToCreate.isEmpty())
            {
                //insert listOfclonedLineToCreate;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfclonedLineToCreate, COMM_SecurityUtils.Access.Createable)){
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert listOfclonedLineToCreate;
                    //Added for Batch/Lot API
                        for (Sobject intVar : listOfclonedLineToCreate) {
                            listAllClonedIds.add(intVar.id);
                        }
                    //
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            if(!isAnyLineOpen)    
            {
                SVMX_doUpdateXHeader(inventoryProcessInfo,inventoryProcessConfig,closerActionsMap, listLineRecordSobject , headerRecord);
            }
            SVMX_doUpdateRelatedLines(closerActionsMap, setOfRecordId, listLineRecordSobject);
            
        }catch(Exception e)
        {
            INVT_Structure.INVT_Error invt_error1 = new INVT_Structure.INVT_Error();
            invt_error1.error = e.getMessage();
            
            INVT_Structure.INVT_Error invt_error2 = new INVT_Structure.INVT_Error();
            invt_error2.error = comm_svmxc_utils3.getTAG043();
            
            throw new InventoryException( new List<INVT_Structure.INVT_Error>{invt_error1, invt_error2});
        }
    }
    private void SVMX_doUpdateXHeader(final INVT_Structure.InventoryProcessInfo inventoryProcessInfo, final COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig, Map<String,List<SVMXC__ServiceMax_Config_Data__c>> closerActionsMap, List<LineRecordSobject> listLineRecordSobject , Sobject headerRecord)
    {

        Sobject headerObjectToUpdate = null;
        if(!inventoryProcessConfig.Is_Multiline_Transaction)
        {
            headerObjectToUpdate = listLineRecordSobject[0].sObjRecord;
            if(inventoryProcessConfig.Is_User_Enter_Qty)
            {
                //INVT_Structure.INVT_LineInfo lineInfo = listLineRecordSobject[0].lineinfo;
                headerObjectToUpdate.put(inventoryProcessConfig.Actual_Qty_API_Name,listLineRecordSobject[0].lineinfo.actualQuantity); 
            }
        }else
        {
            headerObjectToUpdate = headerRecord;
        }
        
        boolean isUpdateSuccess = false;
        for(SVMXC__ServiceMax_Config_Data__c cD : closerActionsMap.get('INV_Header_Closure_Action'))
        {
            COMM_SVMXC_Utils3.WraperSObject oWraperSObject;
            oWraperSObject = comm_svmxc_utils3.sObjectUpdate(headerObjectToUpdate, cD.SVMXC__Field_Name__c, cD.SVMXC__Display_Type__c, cD.SVMXC__Operand__c,cD.SVMXC__Object_Name__c );
            if(oWraperSObject.IsSuccess)
            {
                headerObjectToUpdate = oWraperSObject.sObj;
                isUpdateSuccess = true;
            }
            
        }
        if(isUpdateSuccess)
        {
            System.debug('headerObjectToUpdate: '+ headerObjectToUpdate);
            //update headerObjectToUpdate;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(headerObjectToUpdate, COMM_SecurityUtils.Access.Updateable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update headerObjectToUpdate;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
        }
    
    }
    public void SVMX_doUpdateRelatedLines(Map<String,List<SVMXC__ServiceMax_Config_Data__c>> closerActionsMap, Set<String> setOfRecordId, List<LineRecordSobject> listLineRecordSobject)
    {
        for(SVMXC__ServiceMax_Config_Data__c cD : closerActionsMap.get('INV_Related_Update_Action'))
        {
           
            Set<String> setOfLookupFieldId = new Set<String>();
            for(LineRecordSobject lineSobject : listLineRecordSobject)
            {
                SObject lineRecord = lineSobject.sObjRecord;
                String strid = (String) lineRecord.get(cD.SVMXC__Lookup_Field_API_Name__c);
                if(String.isNotEmpty(strid))
                {
                    setOfLookupFieldId.add(strid);
                }
                
            }                
            list<sObject> lstsObj = Database.query('select id, ' + cD.SVMXC__Field_Name__c + ' from '+ cD.SVMXC__Object_Name__c + ' where id IN : setOfLookupFieldId'); 
            for(sObject sobj :lstsObj)
            {
                for(LineRecordSobject lineSobject : listLineRecordSobject)
                {
                    if(sobj.get('Id') == lineSobject.sObjRecord.get(cD.SVMXC__Lookup_Field_API_Name__c))
                    {
                        if(cD.SVMXC__Operator__c != null && cD.SVMXC__Operator__c.ToUpperCase() == 'SET')
                            sobj.put(cD.SVMXC__Field_Name__c, lineSobject.lineInfo.actualQuantity);
                        else if(cD.SVMXC__Operator__c != null && cD.SVMXC__Operator__c.ToUpperCase() == 'INCREASE')
                            sobj.put(cD.SVMXC__Field_Name__c, (sobj.get(cD.SVMXC__Field_Name__c) != null ? (double)sobj.get(cD.SVMXC__Field_Name__c) : 0) + lineSobject.lineInfo.actualQuantity);
                        else if(cD.SVMXC__Operator__c != null && cD.SVMXC__Operator__c.ToUpperCase() == 'DECREASE')
                            sobj.put(cD.SVMXC__Field_Name__c, (sobj.get(cD.SVMXC__Field_Name__c) != null ? (double)sobj.get(cD.SVMXC__Field_Name__c) : 0) - lineSobject.lineInfo.actualQuantity);
                        break;
                    }
                }     
            }
            update lstsObj;
        }  
    }
    @testVisible private List<SObject> retrieveInventoryProcessRecords( final INVT_Structure.InventoryProcessInfo inventoryProcessInfo, final COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig ) {
        
        List<SObject> xRecords = new List<SObject>();
        
        try {

            final String headerRecordId = inventoryProcessInfo.headerRecordId;
            final String lineRecordId = inventoryProcessInfo.lineRecordId;
            final String childObjectRecordType = inventoryProcessConfig.Child_Object_RecordType;
            final String sourceObjectName = inventoryProcessConfig.Is_Multiline_Transaction ? inventoryProcessConfig.Child_Object_Name : inventoryProcessConfig.Parent_Object_Name;
            Schema.SObjectType sObjectType = ( (SObject) Type.forName( sourceObjectName ).newInstance() ).getSObjectType();
            
            String fields = getFieldString( sObjectType );
            
            fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Product + '.' + inventoryProcessConfig.Related_Product_Field;
            fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Product + '.SVMXC__Stockable__c';
            fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Product + '.SVMXC__Enable_Serialized_Tracking__c';
            fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Product + '.SVMXC__SM_Enable_Batch_Lot_Tracking__c ';
            
            if(String.isNotEmpty( inventoryProcessConfig.RelationShip_to_Source_Location ) && !inventoryProcessConfig.Is_Source_Location_From_Header) {
                
                fields = fields + ',' + inventoryProcessConfig.RelationShip_to_Source_Location + '.SVMXC__Stocking_Location__c';
                fields = fields + ',' + inventoryProcessConfig.RelationShip_to_Source_Location + '.Name';
            }
            
            if(!inventoryProcessConfig.Is_Target_Location_From_Header && String.isNotBlank(inventoryProcessConfig.Number_of_locations ) && (inventoryProcessConfig.Number_of_locations.ToUpperCase() == 'TWO' && ( inventoryProcessConfig.RelationShip_to_Source_Location != inventoryProcessConfig.RelationShip_to_Target_Location )) ) {
                fields = fields + ',' + inventoryProcessConfig.RelationShip_to_Target_Location +'.SVMXC__Stocking_Location__c';
                fields = fields + ',' + inventoryProcessConfig.RelationShip_to_Target_Location +'.Name';
            }
            if(!inventoryProcessConfig.Is_Multiline_Transaction)//Added to stock adjustment, there is not target
            {
                fields = fields + ',' + inventoryProcessConfig.RelationShip_to_Source_Location + '.SVMXC__Stocking_Location__c';
                fields = fields + ',' + inventoryProcessConfig.RelationShip_to_Source_Location + '.Name'; 
            }
            
            if( String.isNotEmpty( inventoryProcessConfig.RelationShip_Name_to_Parent ) && inventoryProcessConfig.Is_Multiline_Transaction ) {
                fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Parent + '.Name';
                
                if( inventoryProcessConfig.Is_Source_Location_From_Header && String.isNotEmpty(inventoryProcessConfig.RelationShip_to_Source_Location) ) {
                    fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Parent + '.' + inventoryProcessConfig.RelationShip_to_Source_Location + '.SVMXC__Stocking_Location__c';
                    fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Parent + '.' + inventoryProcessConfig.RelationShip_to_Source_Location + '.Name';//Added for stock transfer
                }
                
                if( (inventoryProcessConfig.Is_Target_Location_From_Header && inventoryProcessConfig.RelationShip_to_Source_Location != inventoryProcessConfig.RelationShip_to_Target_Location) && String.isNotEmpty(inventoryProcessConfig.RelationShip_to_Source_Location)) {
                    
                    fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Parent + '.' + inventoryProcessConfig.RelationShip_to_Target_Location + '.SVMXC__Stocking_Location__c';
                    fields = fields + ',' + inventoryProcessConfig.RelationShip_Name_to_Parent + '.' + inventoryProcessConfig.RelationShip_to_Target_Location + '.Name';//Added for stock transfer
                }
            }
            
            String soql = 'SELECT ' + fields + ' FROM ';
            
            if( inventoryProcessConfig.Is_Multiline_Transaction ) {
                
                
                soql = soql + inventoryProcessConfig.Child_Object_Name + ' WHERE ' + inventoryProcessConfig.Lookup_Field_to_Parent + ' = :headerRecordId ';
                if(String.isNotEmpty(childObjectRecordType))
                {
                    soql = soql + ' AND RecordType.Name = :childObjectRecordType ' ;
                }
                
                
                System.debug('inventoryProcessConfig.Child_Object_Criteria: '+ inventoryProcessConfig.Child_Object_Criteria);
                if( String.isNotEmpty( inventoryProcessConfig.Child_Object_Criteria )) {
                    soql += ' AND (' + inventoryProcessConfig.Child_Object_Criteria.replace('SVMX.CurrentUser', UserInfo.getUserId() ) + ')';
                }
                
                if(String.isNotEmpty(lineRecordId))
                {
                   soql += ' AND Id = :lineRecordId ';
                }
            } else {
                
                soql = soql + inventoryProcessConfig.Parent_Object_Name + ' WHERE Id=:headerRecordId ';
                
                if( String.isNotEmpty( inventoryProcessConfig.Parent_Object_Criteria )) {
                    soql += ' AND (' + inventoryProcessConfig.Parent_Object_Criteria.replace('SVMX.CurrentUser', UserInfo.getUserId() ) + ')';
                }
            }
            
            System.debug('soql: '+ soql);
            mDebugUntruncated(soql);
            xRecords = Database.query(soql);
            
        }
        
        catch(QueryException e ) {
            throw e;
        }
        
        catch(Exception e ) {
            throw e;
        }
        
        finally {
            
        }
        
        return xRecords;
    }
    
    private Sobject getHeaderRecord(final COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig,final String headerRecordId)
    {
        List<Sobject> sobjectHeaderRecord = new List<Sobject> ();
        Sobject headerSobject = null;
        try
        {
            if(String.isNotEmpty(inventoryProcessConfig.Parent_Object_Name))
            {
                String headerSoql = 'SELECT ID, Name FROM ' + inventoryProcessConfig.Parent_Object_Name + ' WHERE Id=:headerRecordId';
                if(String.isNotBlank(inventoryProcessConfig.Parent_Object_Criteria))
                {
                    headerSoql = headerSoql + ' AND ' + inventoryProcessConfig.Parent_Object_Criteria.replace('SVMX.CurrentUser', UserInfo.getUserId());
                }
                sobjectHeaderRecord = Database.query(headerSoql); 
                if(!sobjectHeaderRecord.isEmpty())
                {
                    headerSobject = sobjectHeaderRecord[0];
                }
            }
        }catch(Exception e)
        {
            System.debug('Exception in getHeaderRecord' + e);
            throw e;
        }
        return headerSobject;
    }
    public void mDebugUntruncated(String sMsg) {
        for (Integer i = 0; i < sMsg.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (sMsg.length()) ? sMsg.length()-1 : i+300);
            System.debug(sMsg.substring(i,iEffectiveEnd));
        }
    }

    
    @testVisible private COMM_Inventory_Classes.InventoryProcess getInventoryConfiguration( String processId ) {
        
        COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig;
            
        try {
            
            final List<SVMXC__ServiceMax_Processes__c> lstInvProcess = [Select ID, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, Name, SVMXC__Parent_Error_Msg__c,SVMXC__Child_Error_Msg__c,SVMXC__Module__c, SVMXC__ProcessID__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Child_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :processId];
        
            if( lstInvProcess != null && lstInvProcess.size() > 0 ) {
                
                SVMXC__ServiceMax_Processes__c oInvProcess = lstInvProcess[0];
                
                if(oInvProcess.SVMXC__Tag_Keys__c != NULL && oInvProcess.SVMXC__Tag_Keys__c.length() > 0) {
                    oInvProcess = ( new I18N_TranslationDelivery( oInvProcess.SVMXC__Tag_Keys__c, UserInfo.getLanguage() ) ).SVMX_GetProcessTranslation( oInvProcess );
                }
                
                Map<String, SVMXC__ServiceMax_Config_Data__c> settingObjectList = (new SVMXC.COMM_Utils_ManageSettings()).SVMX_getSettingObjectList( oInvProcess.SVMXC__Submodule__r.SVMXC__SubmoduleID__c );
                inventoryProcessConfig = new COMM_Inventory_Classes.InventoryProcess( oInvProcess, settingObjectList, false );
            }
            
        }
        
        catch( Exception e ){
           throw e; 
        }
        
        finally {
            
        }
        
        return inventoryProcessConfig;
    }
    

    public  INVT_Structure.INVT_Response getProductStockLine(final INVT_Structure.InventoryProcessInfo inventoryProcessInfo ) {
        
        List<SObject> lstofobject = new List<SObject>();
        System.debug(LoggingLevel.DEBUG, 'getProductStockLine() - enter');
        
        //INVT_Structure.InventoryProcessInfo invtProcessInfo = new INVT_Structure.InventoryProcessInfo();
        INVT_Structure.INVT_ConfigInfo invtConfigInfo = new INVT_Structure.INVT_ConfigInfo();
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        response.success = true;
        
        List<INVT_Structure.INVT_Error> invt_errorList = new List<INVT_Structure.INVT_Error>();
        
        try {
            
            final COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig = getInventoryConfiguration( inventoryProcessInfo.processId );
            if( inventoryProcessConfig != null ) {// validate the invatory process
                
                List<SObject> xRecords = retrieveInventoryProcessRecords( inventoryProcessInfo, inventoryProcessConfig  );
                
                
                if(inventoryProcessConfig.Is_Multiline_Transaction) // if multiline enabled query than queary the header and validate
                {
                   headerRecord = getHeaderRecord(inventoryProcessConfig, inventoryProcessInfo.headerRecordId);
                }
                if(headerRecord == null && inventoryProcessConfig.Is_Multiline_Transaction && String.isNotBlank(inventoryProcessConfig.Parent_Object_Criteria)) //validation on header
                {
                       INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                       invt_error.error = inventoryProcessConfig.Parent_Error_Msg;
                       invt_errorList.add(invt_error); 
                }
                else if((xRecords == null || xRecords.isEmpty()) && !inventoryProcessConfig.Is_Multiline_Transaction ) // if multiline not enabled query the header and validate, retrive method itself return header record just validate
                {
                   
                    INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                    invt_error.error = inventoryProcessConfig.Parent_Error_Msg;
                    invt_errorList.add(invt_error);
                
                }else if((xRecords == null || xRecords.isEmpty()) && inventoryProcessConfig.Is_Multiline_Transaction) // If multiline enable validate the line after parent validation success
                {
                    INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                    //invt_error.error = comm_svmxc_utils3.getTAG046();
                    invt_error.error = inventoryProcessConfig.Child_Error_Msg;
                    invt_errorList.add(invt_error);
                }else
                {
                    List<INVT_Structure.INVT_LineInfo> lineInfoRecord = new List<INVT_Structure.INVT_LineInfo>();
                    invt_errorList.addAll(validateInventoryTransaction(inventoryProcessConfig,xRecords) );
                    
                    if(invt_errorList.isEmpty())
                    {
                        lineInfoRecord = retrieveProductStockMap(inventoryProcessConfig,xRecords);
                    }else
                    {
                        INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                        invt_error.error = comm_svmxc_utils3.getTAG046();
                        invt_errorList.add(0,invt_error);
                    }
                    
                    System.debug('lineInfoRecord '+ lineInfoRecord);
                    
                    //Process info to client
                    invtConfigInfo.disableUsrToEnterQty = (!(Boolean) inventoryProcessConfig.Is_User_Enter_Qty);
                    invtConfigInfo.allowPartialClose = (Boolean) inventoryProcessConfig.Allow_Partial_Closure;
                    invtConfigInfo.isLocationInvolved = String.isNotBlank(inventoryProcessConfig.Number_of_locations);
                    invtConfigInfo.isSerialSelectionEnabled = (Boolean) inventoryProcessConfig.Enable_Serial_Selection ; 
                    invtConfigInfo.serialUniquenessType = inventoryProcessConfig.Enforce_Uniqueness_In_Serial_Selection;
                        
                    String objectApiName = inventoryProcessConfig.Is_Multiline_Transaction ? inventoryProcessConfig.Child_Object_Name : inventoryProcessConfig.Parent_Object_Name;
                    
                    Map<String, Schema.sObjectField> fieldMap  = COMM_Utils_DescribeCall.getInstance().getObjectFieldMap(objectApiName);
                    System.debug(inventoryProcessConfig.Original_Qty_API_Name);
                    System.debug(inventoryProcessConfig.Actual_Qty_API_Name);
                    for(String key : fieldMap.keyset())
                    {
                        System.debug('key: '+ key);
                    }
                    if(String.isNotEmpty(inventoryProcessConfig.Actual_Qty_API_Name))
                    {
                        Schema.DescribeFieldResult result = COMM_Utils_DescribeCall.getInstance().describeField(fieldMap.get(inventoryProcessConfig.Actual_Qty_API_Name.toLowercase()));
                        invtConfigInfo.actualyQuantityLabel = result.getLabel();
                    }
                    if(String.isNotEmpty(inventoryProcessConfig.Original_Qty_API_Name))
                    {
                        Schema.DescribeFieldResult result = COMM_Utils_DescribeCall.getInstance().describeField(fieldMap.get(inventoryProcessConfig.Original_Qty_API_Name.toLowercase()));
                        invtConfigInfo.originalQuantityLabel = result.getLabel();
                    }
                    if(String.isNotEmpty(inventoryProcessConfig.Product_Field_API_Name))
                    {
                        Schema.DescribeFieldResult result = COMM_Utils_DescribeCall.getInstance().describeField(fieldMap.get(inventoryProcessConfig.Product_Field_API_Name.toLowercase()));
                        invtConfigInfo.productLabel = result.getLabel();
                    }
                    if(xRecords !=null && !xRecords.isEmpty() && inventoryProcessConfig.Is_Multiline_Transaction)
                    {
                        inventoryProcessInfo.headerRecordName = (String) xRecords[0].getSobject(inventoryProcessConfig.RelationShip_Name_to_Parent).get('Name');
                    }else
                    {
                        inventoryProcessInfo.headerRecordName = (String) xRecords[0].get('Name');
                    }
                    inventoryProcessInfo.processName = inventoryProcessConfig.Name;
                    
                    inventoryProcessInfo.lineInfoList = lineInfoRecord;
                    inventoryProcessInfo.invtConfigInfo = invtConfigInfo;
                    
                    response.data = inventoryProcessInfo;
                } 

            } else {
                
                INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                invt_error.error = comm_svmxc_utils3.getTAG039();
                invt_errorList.add(invt_error);
            }
            if(invt_errorList !=null && !invt_errorList.isEmpty())
            {
                response.success = false;  
                response.message = 'Process configuration error'; 
                response.errordata = invt_errorList;
                //response.errordata = String.valueOf(invt_errorList);
            }
                        
        }
        
        catch(Exception e) {
            
        
            
            System.debug( LoggingLevel.ERROR, 'getProductStockLine() : Failed to process request; Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'getProductStockLine() - exit');
        }
        
        return response;
    }
    
    
    @testVisible private List<INVT_Structure.INVT_LineInfo> retrieveProductStockMap(COMM_Inventory_Classes.InventoryProcess inventoryProcessConfig, final List<SObject> processRecords )
    {
        System.debug(LoggingLevel.ERROR, 'retrieveProductStockMap enter');
        List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo>();
           
        try{   
            Map<String,ProductStock>  productStockMap  = getProductStockInfo(inventoryProcessConfig, processRecords, false);
            
            Map<String,List<INVT_Structure.INVT_ProductSerialInfo>> productSerialMap = new Map<String,List<INVT_Structure.INVT_ProductSerialInfo>>();
            
            for(ProductStock productStock : productStockMap.values())
            {
                if(inventoryProcessConfig.Source_Status.equalsIgnoreCase (productStock.productStockStatus) ) {
                    String key = productStock.productId + '_' + productStock.locationId + '_' + productStock.productStockStatus;

                    for(ProductSerial productSerial : productStock.productSerialList)
                    {
                        if(!productSerialMap.containsKey(key)) {
                            productSerialMap.put( key, new List<INVT_Structure.INVT_ProductSerialInfo>() );
                        }
                        INVT_Structure.INVT_ProductSerialInfo productSerialInfo = new  INVT_Structure.INVT_ProductSerialInfo();
                        productSerialInfo.productSerialId = productSerial.id;
                        productSerialInfo.serialName = productSerial.name;
                        productSerialInfo.productStockId = productSerial.productStockId;
                        
                        //Batch/Lot
                        productSerialInfo.batchLotQuantity = productSerial.batchLotQuantity;
                        productSerialInfo.batchLotName = productSerial.batchLotName;
                        productSerialInfo.batchLotId = productSerial.batchLotId;
                        
                        System.debug('batch Name 2: '+ productSerial.batchLotName);
                        
                        productSerialMap.get(key).add(productSerialInfo);
                    }
                } 
            }
            
            for(Sobject tempsObjectRec : processRecords) {
                
                //String key = tempsObjectRec.get(inventoryProcessConfig.Product_Field_API_Name) + '_' + tempsObjectRec.get(inventoryProcessConfig.Source_Location_API_Name) + '_' + inventoryProcessConfig.Source_Status;
                String key = '';
                System.debug('key pro: '+key);
                
                INVT_Structure.INVT_LineInfo lineIfo = new INVT_Structure.INVT_LineInfo();
                lineIfo.id = (String) tempsObjectRec.get('Id');
                lineIfo.name = (String) tempsObjectRec.get('Name');
                Sobject productsobj = tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Product);
                if(productsobj != null){
                    lineIfo.partName = String.valueOf(productsobj.get(inventoryProcessConfig.Related_Product_Field));
                    lineIfo.isStockable = (Boolean) productsobj.get('SVMXC__Stockable__c');
                    lineIfo.isSerializedTracked = (Boolean)productsobj.get('SVMXC__Enable_Serialized_Tracking__c');
                    lineIfo.isBatchLotTracked = (Boolean)productsobj.get('SVMXC__SM_Enable_Batch_Lot_Tracking__c');
                }
                
                Double initialQuentity = tempsObjectRec.get(inventoryProcessConfig.Original_Qty_API_Name)!=null ? (Double) tempsObjectRec.get(inventoryProcessConfig.Original_Qty_API_Name):0.0;
                lineIfo.originalQuantity =  initialQuentity;
                lineIfo.actualQuantity =    initialQuentity;
                lineIfo.productId = (String) tempsObjectRec.get(inventoryProcessConfig.Product_Field_API_Name);
                
                lineIfo.sourceStatus = inventoryProcessConfig.Source_Status; // To do - confirm( Do we need or not )
                //Added for stock transfer
                
                if(String.isNotEmpty( inventoryProcessConfig.Source_Location_API_Name ) && String.isNotBlank(inventoryProcessConfig.Number_of_locations))
                {
                    if(inventoryProcessConfig.Is_Source_Location_From_Header  && String.isNotEmpty( inventoryProcessConfig.RelationShip_Name_to_Parent ))
                    {
                        key = tempsObjectRec.get(inventoryProcessConfig.Product_Field_API_Name) + '_' + (String) tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Parent).get(inventoryProcessConfig.Source_Location_API_Name) + '_' + inventoryProcessConfig.Source_Status;
                        
                        System.debug('inventoryProcessConfig.RelationShip_Name_to_Parent '+ inventoryProcessConfig.RelationShip_Name_to_Parent);
                        System.debug('inventoryProcessConfig.RelationShip_to_Source_Location: '+ inventoryProcessConfig.RelationShip_to_Source_Location);
                      
                        Sobject headerFromRecordLocation = tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Parent).getSobject(inventoryProcessConfig.RelationShip_to_Source_Location);
                        if(headerFromRecordLocation !=null )
                        {
                            lineIfo.fromLocationId =(String) headerFromRecordLocation.get('Id');
                            lineIfo.fromLocationName = (String) headerFromRecordLocation.get('Name');
                        }

                        if(inventoryProcessConfig.Number_of_locations.ToUpperCase() == 'TWO')
                        {
                            lineIfo.toLocationId = (String) tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Parent).getSObject(inventoryProcessConfig.RelationShip_to_Target_Location).get('Id'); 
                            lineIfo.toLocationName = (String) tempsObjectRec.getSobject(inventoryProcessConfig.RelationShip_Name_to_Parent).getSObject(inventoryProcessConfig.RelationShip_to_Target_Location).get('Name');
                            lineIfo.targetStatus = inventoryProcessConfig.Target_Status;
                        }
                    }else
                    {
                        key = tempsObjectRec.get(inventoryProcessConfig.Product_Field_API_Name) + '_' + tempsObjectRec.get(inventoryProcessConfig.Source_Location_API_Name) + '_' + inventoryProcessConfig.Source_Status;
                        
                        lineIfo.fromLocationId = (String) tempsObjectRec.getSObject(inventoryProcessConfig.RelationShip_to_Source_Location).get('Id');
                        lineIfo.fromLocationName = (String) tempsObjectRec.getSObject(inventoryProcessConfig.RelationShip_to_Source_Location).get('Name');
                        if(inventoryProcessConfig.Number_of_locations.ToUpperCase() == 'TWO')
                        {
                            lineIfo.toLocationId = (String) tempsObjectRec.getSObject(inventoryProcessConfig.RelationShip_to_Target_Location).get('Id'); 
                            lineIfo.toLocationName = (String) tempsObjectRec.getSObject(inventoryProcessConfig.RelationShip_to_Target_Location).get('Name');
                            lineIfo.targetStatus = inventoryProcessConfig.Target_Status;
                        } 
                    }
                }
                  
                
                System.debug('productStockMap : '+ productSerialMap);
                System.debug('productStockMap key : '+ productSerialMap.containsKey(key));
                if(productSerialMap.containsKey(key))
                {
                    lineIfo.sourceSerialList = productSerialMap.get(key);   
                }
                lineInfoList.add(lineIfo);
            }
        }catch(Exception e)
        {
            System.debug('Exception in retrieveProductStockMap: '+ e.getStackTraceString());
            System.debug('Exception '+ e);
            throw e;
        }
        finally {
            
        }
        System.debug(LoggingLevel.ERROR, 'retrieveProductStockMap exit');
        
        return lineInfoList;
    }
   //On load on retrieval validation of invetory process
   @testVisible private List<INVT_Structure.INVT_Error> validateInventoryTransaction(COMM_Inventory_Classes.InventoryProcess inventoryProcess,List<Sobject> processRecords) {

        List<INVT_Structure.INVT_Error> invt_errorList = new List<INVT_Structure.INVT_Error>();
        try {
            
            boolean headerSourceValidationComplete = false;
            boolean headerTargetValidatioCompleted = false;
             for( Sobject tempsObjectRec : processRecords ) {
                    
                    Boolean isHeaderLocation = true;
                    Sobject sourceLocationSObject = null;
                    Sobject targetLocationSObject = null;
                    Sobject productSobject = null;
                    String  recordName = '';
                    
                   if(String.isNotEmpty(inventoryProcess.Number_of_locations))
                   { 
                    if( inventoryProcess.Is_Source_Location_From_Header ) {
                        
                        if( inventoryProcess.Is_Multiline_Transaction ) {
                            
                            Sobject parent = tempsObjectRec.getSObject(inventoryProcess.RelationShip_Name_To_Parent);
                            sourceLocationSObject = parent.getSObject(inventoryProcess.RelationShip_to_Source_Location);
                            recordName = (String) parent.get('Name');
                        } else {
                            sourceLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Source_Location);
                            recordName = (String) tempsObjectRec.get('Name');
                        }
                    } else if( inventoryProcess.Is_Multiline_Transaction ) {
                        
                        sourceLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Source_Location);
                        recordName = (String) tempsObjectRec.get('Name');
                        isHeaderLocation = false;
                    } else {
                        // Wrong Configuration ?
                    }
                    
                    if( inventoryProcess.Number_of_locations.ToUpperCase() == 'TWO' ) {
                        
                        if( inventoryProcess.Is_Target_Location_From_Header ) {
                            
                            if( inventoryProcess.Is_Multiline_Transaction ) {
                                
                                Sobject parent = tempsObjectRec.getSObject(inventoryProcess.RelationShip_Name_To_Parent);
                                targetLocationSObject = parent.getSObject(inventoryProcess.RelationShip_to_Target_Location);
                            } else {
                                targetLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Target_Location);
                            }
                        } else if( inventoryProcess.Is_Multiline_Transaction ) {
                            
                            targetLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Target_Location);
                            isHeaderLocation = false;
                        } else {
                            // Wrong Configuration ?
                        }
                    }
                    System.debug('isHeaderLocation: '+ isHeaderLocation);
                    if( ( sourceLocationSObject != null && inventoryProcess.Is_Source_Location_Stockable && !((Boolean)sourceLocationSObject.get('SVMXC__Stocking_Location__c')))
                       || (sourceLocationSObject == null && inventoryProcess.Is_Source_Location_Stockable ) ) {
                           
                  
                           if(isHeaderLocation)
                           {
                               if(!headerSourceValidationComplete)
                               {
                                   headerSourceValidationComplete = true;
                                   INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                                   invt_error.error = isHeaderLocation ? comm_svmxc_utils3.getTAG033() : comm_svmxc_utils3.getTAG034();
                                   invt_error.entityName = recordName; 
                                   invt_errorList.add(invt_error);
                               }
                           }else
                           {
                               INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                               invt_error.error = isHeaderLocation ? comm_svmxc_utils3.getTAG033() : comm_svmxc_utils3.getTAG034();
                               invt_error.entityName = (String) tempsObjectRec.get('Name');
                               invt_errorList.add(invt_error);
                           }

                           
                           
                       }
                    
                    if( inventoryProcess.Number_of_locations.ToUpperCase() == 'TWO' && ( ( targetLocationSObject != null && inventoryProcess.Is_Target_Location_Stockable && !((Boolean)targetLocationSObject.get('SVMXC__Stocking_Location__c')))
                       || (targetLocationSObject == null && inventoryProcess.Is_Target_Location_Stockable ) ) ){
                           
                           
                           if(isHeaderLocation)
                           {
                               if(!headerTargetValidatioCompleted)
                               {
                                   headerTargetValidatioCompleted = true;
                                   INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                                   invt_error.error = isHeaderLocation ? comm_svmxc_utils3.getTAG035() : comm_svmxc_utils3.getTAG036();
                                   invt_error.entityName = recordName; 
                                   invt_errorList.add(invt_error);
                               }
                           }else
                           {
                               INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                               invt_error.error = isHeaderLocation ? comm_svmxc_utils3.getTAG035() : comm_svmxc_utils3.getTAG036();
                               invt_error.entityName = (String) tempsObjectRec.get('Name'); 
                               invt_errorList.add(invt_error);
                           }
 
                           
                           
                       }
                    }
                    productSobject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_Name_to_Product);
                    
                    if(productSObject == null) {
                        
                        INVT_Structure.INVT_Error invt_error = new INVT_Structure.INVT_Error();
                        invt_error.error = comm_svmxc_utils3.getTAG051() ;
                        invt_error.entityName = (String) tempsObjectRec.get('Name'); 
                        
                        invt_errorList.add(invt_error);
                    }
                    
                    
                }
            
            
        }
        
        catch(Exception e) {
            System.debug( LoggingLevel.ERROR, 'Exception: ' + e.getStackTraceString() );
            System.debug(LoggingLevel.DEBUG, 'Exception: '+ e.getMessage());
            
            throw e;
        }
        
        finally {
            
        }
        
        return invt_errorList;
    }
    
    private string getFieldString(Schema.sObjectType St)
    {
        boolean isNameFieldAdded = false;
        string strFields = '';
        try
        {
            if(St != null)
            {
                Schema.DescribeSObjectResult r = St.getDescribe();
                
                Map<String,Schema.SObjectField> objfieldMap = r.fields.getMap();  
              
               
                if(objfieldMap != null)
                {
                    for (String fieldKey : objfieldMap.keySet()) 
                    {
                        Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                        Schema.DescribeFieldResult f = fsObj.getDescribe();
                        
                        if( strFields.length() > 0)
                            strFields += ', ';
                        strFields += f.getName();
                    }
                }
            }
        }
        catch(exception ex)
        {
            system.debug('asdf'+ ex);
        }
        return strFields;
    }
    @testVisible private List<Sobject> getAllSourceTargetLocations(COMM_Inventory_Classes.InventoryProcess inventoryProcess, List<Sobject> processRecords) {
        List<Sobject> sourceTargetLocations = new List<Sobject>();
        try {
            
            
            Sobject sourceLocationSObject = null;
            Sobject targetLocationSObject = null;
            
            if(String.isNotEmpty(inventoryProcess.Number_of_locations))
            {
                for(Sobject tempsObjectRec : processRecords )
                {
                    if( inventoryProcess.Is_Source_Location_From_Header ) {
                        
                        if( inventoryProcess.Is_Multiline_Transaction ) {
                            
                            Sobject parent = tempsObjectRec.getSObject(inventoryProcess.RelationShip_Name_To_Parent);
                            sourceLocationSObject = parent.getSObject(inventoryProcess.RelationShip_to_Source_Location);
                        } else {
                            sourceLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Source_Location);
                        }
                    } else if( inventoryProcess.Is_Multiline_Transaction ) {
                        
                        sourceLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Source_Location);
                    } else {
                        // Wrong Configuration ?
                    }
                    
                    if( inventoryProcess.Number_of_locations.ToUpperCase() == 'TWO' ) {
                        
                        if( inventoryProcess.Is_Target_Location_From_Header ) {
                            
                            if( inventoryProcess.Is_Multiline_Transaction ) {
                                
                                Sobject parent = tempsObjectRec.getSObject(inventoryProcess.RelationShip_Name_To_Parent);
                                targetLocationSObject = parent.getSObject(inventoryProcess.RelationShip_to_Target_Location);
                            } else {
                                targetLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Target_Location);
                            }
                        } else if( inventoryProcess.Is_Multiline_Transaction ) {
                            
                            targetLocationSObject = tempsObjectRec.getSObject(inventoryProcess.RelationShip_to_Target_Location);
                        } else {
                            // Wrong Configuration ?
                        }
                    }
                    
                    if(sourceLocationSObject!= null)
                    {
                      sourceTargetLocations.add(sourceLocationSObject);     
                    }
                    if(targetLocationSObject != null)
                    {
                      sourceTargetLocations.add(targetLocationSObject);
                    }
                        
                }
            }
            
        }
        
        catch(Exception e) {
            System.debug( LoggingLevel.ERROR, 'Exception: ' + e.getStackTraceString() );
            System.debug(LoggingLevel.DEBUG, 'Exception: '+ e.getMessage());
            
            throw e;
        }
        return sourceTargetLocations;   
        
    }
        //This method will return non-stocking location set
    @testVisible Set<String> getNonStockingLocation(List<Sobject> sourceTargetLocations )
    {
        Set<String> nonStockinglocationSet = new Set<String>();
        Boolean isStockingLocation = true;
        for(Sobject location: sourceTargetLocations)
        {
            isStockingLocation = (Boolean) location.get('SVMXC__Stocking_Location__c');
            if(!isStockingLocation)
            {
                nonStockinglocationSet.add((String) location.get('Id'));
            }
        }
        
        return nonStockinglocationSet;
    }
    private void init() {
        
        try {
            
            Map<String, Map<String,String>> settingsMap = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList( new List<String>{'INVT001'} );
            
            if( settingsMap != null && settingsMap.containskey('INVT001') ) {
                
                Map<String, String> inventory001SettingsMap = settingsMap.get('INVT001');
                if(inventory001SettingsMap != null && inventory001SettingsMap.containskey('SET002') && inventory001SettingsMap.get('SET002') != null ) {
                    respectActiveProductSerial = Boolean.valueof( inventory001SettingsMap.get('SET002') );
                }
            }
        }
        
        catch( Exception e ) {
            throw e;
        }
        
        finally {
            
        }
    }
    public INVT_Structure.INVT_Response retrieveInventoryTags()
    {
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        response.data = comm_svmxc_utils3.tagTextMap;
        response.success = true;
        response.message = 'request processed successfully';
        return response;
    }

}