/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class contains request & response wrapper structure.
 *
 * @author Ramachandra Mohan
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       29 Jan 2020     Created.
 *              Jaysukh Patel           18th AUG 2020   Modified and Implimented for invetory
 *****************************************************************************************************/
public class INVT_Structure {
    
    public class INVT_Request {
        
        public InventoryProcessInfo inventoryProcessInfo;
        
        public INVT_Request(){}
    }
    
    public class INVT_Response {
        
        public Boolean success;
        public String message;
        public Object data;
        public Object errordata;
        public INVT_Response(){}
    }
    public class INVT_LineInfo {
        
        public String id;
        public String name;
        public String partName;
        public Double originalQuantity;
        public String productId;
        public Boolean isStockable = false;
        public Boolean isSerializedTracked = false;
        public Boolean isBatchLotTracked = false;
        public String fromLocationId;
        public String fromLocationName;
        public String toLocationId;
        public String toLocationName;
        public String sourceStatus;
        public String targetStatus;
        public Double actualQuantity;// new added , manually user can enter quantity value
        public Boolean closeLine = false;
        public List<INVT_ProductSerialInfo> sourceSerialList;
        public List<INVT_ProductSerialInfo> targetSerialList;
        
        public INVT_LineInfo(){}
    }
    
    public class INVT_Error
    {
        public String error;
        public String entityName;
        
    }
    
    public class INVT_ProductSerialInfo {
        
        public String productStockId;
        public String serialName;
        public String productSerialId;
        
        //for batch/lot 
        public Double batchLotQuantity;
        public String batchLotName;
        public String batchLotId;
        public Double batchLotTargetQuantity;
        public INVT_ProductSerialInfo(){}
    }
    public class INVT_ConfigInfo {
        public Boolean disableUsrToEnterQty = true;
        public Boolean allowPartialClose = false;
        public Boolean isLocationInvolved = false;
        public Boolean isSerialSelectionEnabled = false;
        public String actualyQuantityLabel;
        public String originalQuantityLabel;
        public String productLabel;
        public String serialUniquenessType;
    }
    public class InventoryProcessInfo {
        
        public String headerRecordId;
        public String lineRecordId;
        public String processId;
        public String headerRecordName;
        public String processName;
            
        public List<INVT_LineInfo> lineInfoList;
        public INVT_ConfigInfo invtConfigInfo;
        public InventoryProcessInfo(){}
    }
}