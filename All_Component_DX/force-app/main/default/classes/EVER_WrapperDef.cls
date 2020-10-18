/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The EVER_WrapperDef is a wrapper class for wrapping the data retrieved from the Service class which 
 * is used during the Manual Entitlement Process of Work Order/Product Serviced Lines
 * 
 *
 * @author Sachin S
 * @version 
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Sachin S               01 Mar 2016     Created.
 *****************************************************************************************************/
public with sharing class EVER_WrapperDef {

    public class EVER_Settings{

        public String showFutureEntitlement ;
        public String showExpiredEntitlement ;
        public String entitleUsingAccountOrProduct ;
        public String matchAccount ;
        public String matchContact ;
        public String sLAandValidityLevels ; 
        public String coverageOnParentProduct ;
        public String coverageOnTopLevelProduct ;
        public String coverageOnChildProduct ;
        public String coverageOnPartProduct ;
        public String coverageOnProductFamily ;
        public String coverageOnProductLine ;
        public String noOfChildLevelItr ;
        public String allowEntitlementFilters ;
        public String setBillingType ;
        public String matchLocation ; 
        public String effectiveDateForEntitlement ;
        public String serviceBasedEntitlement;
        public String showAllServices;
        public String showAllLines;
        public String recordViewPage;
        public String entitlementSupportOnLines ;
        public String entUsingWarrantyOrSC;
        public String considerCountersOrDates;
        public EVER_Settings(){

        }
    }

    public class EVER_Request {
        public String headerId ;
        public List<String> detailLineIDs ;
        public EVER_Settings entitlementSettings ;
        public List<EVER_InfoMap> entitlementInfoMap ;
        public EVER_Request(){
           
        }
    }

    public class EVER_InfoMap {
        public String recordID ;
        public EVER_EntitlementInfo entitlementInfo ;
        public EVER_InfoMap(){

        }
    }

    public class EVER_EntitlementInfo{
        public String warrantyOrScon ;
        public String recordId ;
        public String recordName ;
        public String coveredBy ;
        public String uniqueID ; //Introduced for distinguishing same Scons covered by different entities
        public String startDate ;
        public String endDate ;
        public String installedBaseName;
        public String sLARecordId ;
        public String sLARecordName ;
        public String entitlementNotes ; //New
        public List<Ever_CoveredService> coveredService ; //New
        public String warrantyTermId ; //New
        public String warrantyTermName ; //New
        public EVER_EntitlementInfo(){

        }
    }

    public class Ever_CoveredService{
        public Boolean selected;
        public Boolean isQualified;
        public String recordID;
        public String serviceName;
        public String allowedUnits; 
        public String consumedUnits;
        public String availableUnits;
        public String tracked;
        public Ever_CoveredService(){
        }
    }

    public class EVER_DetailRecord {
        public String recordID;
        public String recordName;
        public String installedBaseName;
        public String installedBaseId;
        public String productName;
        public List<EVER_EntitlementInfo> listEntitlementInfo ;
        //public Serial no.
        public EVER_EntitlementInfo selectedEntitlementInfo ; //New
        public String description ; //New
        public boolean entitlementPerformed;
        public EVER_DetailRecord(){        }
        
        /*public EVER_DetailRecord(String recordID){
            this.recordID = recordID;
        }*/
    }

    public class EVER_HeaderRecord{
        public String recordID ;
        public String recordName ;
        public String installedBaseName ;
        public String installedBaseId ;
        public String accountName ;
        public String contactName ;
        public boolean entitlementPerformed;
        public String productName;
        public EVER_EntitlementInfo selectedEntitlementInfo; //New
        // Add Serial Number
        public List<EVER_DetailRecord> listDetailRecords ; 
        public List<EVER_EntitlementInfo> listEntitlementInfo ;
        public Map<String,List<EVER_EntitlementHistory>> entitlementHistoryMap;

        public EVER_HeaderRecord(){}
        

    }

    public class EVER_Response {
        
        public Boolean success ;
        public Boolean warning ;
        public List<String> messageList ;  
        public EVER_HeaderRecord headerRecord ;
        public EVER_Settings entitlementSettings;
        public EVER_Response(){ 
            messageList = new List<String>();
        }
    }

    // BAC - 12 : Entitlement History related Wrapper - Anush 5/18/2016
    public class EVER_EntitlementHistory {
        public string recordName;
        public string recordId;
        public string startDate;
        public string endDate;
        public string dateOfEntitlement;
        public string coveredBy;
        public string daysToWarrantyExpiry;
        public boolean entitledWithinThreshold;
        public string exchangeType;
        public string inactiveDate;
        //public string productWarrantID;
        //public string productWarrantyName;
        //public string serviceContractID;
        //public string serviceContractName;
        public string slaTermID;
        public string slaTermName;
        public string entitledByContact;
        public string entitledByIB;
        public string entitledByService;
        public string entitledBySite;
        public string warrantyOrSconName;
        public string warrantyOrSconId;
        public EVER_EntitlementHistory() {

        }
    }

}