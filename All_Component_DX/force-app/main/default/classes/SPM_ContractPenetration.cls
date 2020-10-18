/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The class SPM_MeanTimeToRepair which extends SPM_AbstractBatch abstract class. 
 * This class implementats all the SPM_AbstractBatch class abstract methods. 
 *
 * @author Anchal Sharma
 * @version 15.59101
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal Sharma           13 Oct 2015     Created.
 *              Ramachandra Mohan       02 Nov 2015     Updated to populate some more fields.
 *              Ramachandra Mohan       06 Nov 2015     Data model change.
 *              Ramachandra Mohan       31 Mar 2016     Security fixes.
 *             	Soumyaranjan Pati      10th Nov 2017    Attach rate - Trending(ANA-1379)
 *****************************************************************************************************/

global with sharing class SPM_ContractPenetration extends SPM_AbstractBatch {
    
     /**
      * 
      */
    public SVMXC__ServiceMax_Config_Data__c scheduleConfigData;
	public Datetime currentBatchRunDatetime;
    
    /**
     * 
     */
    global SPM_ContractPenetration( SVMXC__ServiceMax_Config_Data__c scheduleData ) {
        
        super(SPM_Schema.Report.ContractPenetration, scheduleData);  
        this.scheduleConfigData = scheduleData;
    }
    
    /**
     * 
     */ 
    global override void initBatchConfiguration() {
        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - enter' );
        //Added Soumyaranjan for Trending
         currentBatchRunDatetime=System.now();
         
        Integer numberOfDays = getNumberOfDaysToQualifyRecords();
        if( numberOfDays == null ) numberOfDays = 365;
        
        if( scheduleConfigData != null ) {
            
            if(scheduleConfigData.SVMXC__Enter_Date__c == null){
                scheduleConfigData.SVMXC__Enter_Date__c = System.today();
            }
            numberOfDays += scheduleConfigData.SVMXC__Enter_Date__c.daysBetween(System.today());
            /*if(scheduleConfigData.SVMXC__Previous_Execution_Completed_On__c != null && scheduleConfigData.SVMXC__Enter_Date__c != null){
                numberOfDays += scheduleConfigData.SVMXC__Enter_Date__c.daysBetween(scheduleConfigData.SVMXC__Previous_Execution_Completed_On__c.Date());
            }*/
        }        
        
        Datetime previousExecution = System.now().addDays( (numberOfDays * -1) );
        
        String entryCriteria = 'CreatedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
        
        //if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Started_On__c != null ) {
            
            //previousExecution = scheduleData.SVMXC__Previous_Execution_Started_On__c;
            //entryCriteria = entryCriteria + ' AND LastModifiedDate >= ' + previousExecution.format( SPM_Consts.DEFAULT_DATETIME_FORMAT );
        //}
        
        setWhereClause( entryCriteria );
        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - exit' );
    }
    
    /**
     * 
     */
    global override void handleRecords( List<SObject> records ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - enter; records: ' + records.size() );
        
        Set<Id> setIBIds = (new Map<Id,SObject>(records)).keySet();
        System.debug( LoggingLevel.DEBUG, 'setIBIds - '+ setIBIds);
        
        Map<Id,List<Id>> installedProductServiceContractListMap = new Map<Id,List<Id>>();
        
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Service_Contract__c', 'SVMXC__Installed_Product__c' };
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Contract_Products__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        //Criteria to load the Covered Products.
        String criteria = getExpressionCriteria(SPM_Schema.ExpressionType.FilterCriteria);
        System.debug( LoggingLevel.DEBUG, 'criteria - '+ criteria);
        
        String query ='SELECT Id, SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Installed_Product__c FROM '+
                    'SVMXC__Service_Contract_Products__c WHERE SVMXC__Installed_Product__c IN : setIBIds AND SVMXC__Service_Contract__c != null '+
                    'AND SVMXC__Service_Contract__r.SVMXC__Active__c = true AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= TODAY AND '+
                    'SVMXC__Service_Contract__r.SVMXC__End_Date__c >= TODAY ';
        
        if(criteria != null && criteria != '') {
           query = query +' AND (' + criteria + ') ';
        }
        query = query + ' ORDER BY SVMXC__Service_Contract__r.SVMXC__End_Date__c';
        System.debug( LoggingLevel.DEBUG, 'Query - '+ query);
        List<SVMXC__Service_Contract_Products__c> lstCoveredProducts = Database.query(query);
        System.debug( LoggingLevel.DEBUG, 'Loaded Covered-Products count - ' + lstCoveredProducts.size());
        
        for( SVMXC__Service_Contract_Products__c contractProducts: lstCoveredProducts) {    
            if( !installedProductServiceContractListMap.containsKey( contractProducts.SVMXC__Installed_Product__c ) ) {
                installedProductServiceContractListMap.put( contractProducts.SVMXC__Installed_Product__c, new List<Id>() );
            }
            installedProductServiceContractListMap.get( contractProducts.SVMXC__Installed_Product__c ).add( contractProducts.SVMXC__Service_Contract__c );
        }
        
        Map<Id, SVMXC__SPM_Contract_Penetration__c> contractPenetrationMap = new Map<Id, SVMXC__SPM_Contract_Penetration__c>();
        
        Set<Id> installedProductIdSet = new Set<Id>();
        for( SObject record : records ) {
             installedProductIdSet.add( (Id) getSourceObjectFieldValue( record, SPM_Schema.Field.Id ) );
        }
        
        queryFields = new List<String> {'Id', 'SVMXC__Installed_Product__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Contract_Penetration__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        if(getTrendingEnabledValue()){
		
				for( SObject record : records ) {
				
				String installedProductName = (String) getSourceObjectFieldValue( record, SPM_Schema.Field.Name );
				
				//addInfo('Processing Installed Product : ' + installedProductName );
				SVMXC__Installed_Product__c IBRec = (SVMXC__Installed_Product__c) record;
				
				List <SVMXC__Warranty__c> coveredByWarranty =   IBRec.SVMXC__Warranty__r;
				List <Id> coveredSCList = installedProductServiceContractListMap.get( IBRec.Id );
				
				Integer coveredByWarrantySize = coveredByWarranty.size();
				Integer coveredBySCSize = ( coveredSCList != null ) ? coveredSCList.size() : 0;
				
				Integer loopSize = (coveredByWarrantySize > coveredBySCSize) ? coveredByWarrantySize : coveredBySCSize; 
				
				
				//Added Soumyaranjan for Trending
				//SVMXC__SPM_Contract_Penetration__c contractPenetration = contractPenetrationMap.get( IBRec.ID );
				SVMXC__SPM_Contract_Penetration__c contractPenetration = new SVMXC__SPM_Contract_Penetration__c();
				contractPenetration.SVMXC__Installed_Product__c = IBRec.ID;
				contractPenetration.SVMXC__Account__c = (ID) getSourceObjectFieldValue( record, SPM_Schema.Field.Account );            
				contractPenetration.SVMXC__Covered_By__c = 'Not Covered';
				contractPenetration.SVMXC__Product_Warranty__c = null;
				contractPenetration.SVMXC__Service_Contract__c = null;
				contractPenetration.SVMXC__Configuration_Name__c = getConfigurationName();
				contractPenetration.SVMXC__Calculation_Method__c = getCalculationMethodName();
				contractPenetration.SVMXC__Run_On__c=currentBatchRunDatetime;
				
				contractPenetration.SVMXC__Processed_On__c = System.today();
				
				for(integer i = 0 ; i < loopSize ; i++) {
					
					if( coveredByWarranty != null && i < coveredByWarranty.size() ) {
						
						contractPenetration.SVMXC__Product_Warranty__c = coveredByWarranty.get(i).Id;
											
						if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Not Covered') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Warranty';
						} else if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Contract') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Warranty and Contract';
						}
					}
									
					if(coveredSCList != null && i < coveredSCList.size() ) {
						
						contractPenetration.SVMXC__Service_Contract__c = coveredSCList.get(i);
											
						if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Not Covered') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Contract';
						} else if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Warranty') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Warranty and Contract';
						}
					}
				}
				//
				//if( !contractPenetrationMap.containsKey( IBRec.ID ) ) {
					contractPenetrationMap.put( IBRec.ID, contractPenetration );
			   // }
				//
			}
        }else{
			for( SVMXC__SPM_Contract_Penetration__c contractPenetration : [SELECT Id, SVMXC__Installed_Product__c FROM SVMXC__SPM_Contract_Penetration__c WHERE SVMXC__Installed_Product__c IN :installedProductIdSet AND (SVMXC__Configuration_Name__c = :getConfigurationName() OR SVMXC__Configuration_Name__c = '' ) ] ) {
				contractPenetrationMap.put( contractPenetration.SVMXC__Installed_Product__c, contractPenetration );
			}
        
			for( SObject record : records ) {
				
				String installedProductName = (String) getSourceObjectFieldValue( record, SPM_Schema.Field.Name );
				
				//addInfo('Processing Installed Product : ' + installedProductName );
				SVMXC__Installed_Product__c IBRec = (SVMXC__Installed_Product__c) record;
				
				List <SVMXC__Warranty__c> coveredByWarranty =   IBRec.SVMXC__Warranty__r;
				List <Id> coveredSCList = installedProductServiceContractListMap.get( IBRec.Id );
				
				Integer coveredByWarrantySize = coveredByWarranty.size();
				Integer coveredBySCSize = ( coveredSCList != null ) ? coveredSCList.size() : 0;
				
				Integer loopSize = (coveredByWarrantySize > coveredBySCSize) ? coveredByWarrantySize : coveredBySCSize; 
				
				if( !contractPenetrationMap.containsKey( IBRec.ID ) ) {
					contractPenetrationMap.put( IBRec.ID, new SVMXC__SPM_Contract_Penetration__c() );
				}
				
				SVMXC__SPM_Contract_Penetration__c contractPenetration = contractPenetrationMap.get( IBRec.ID );
				contractPenetration.SVMXC__Installed_Product__c = IBRec.ID;
				contractPenetration.SVMXC__Account__c = (ID) getSourceObjectFieldValue( record, SPM_Schema.Field.Account );            
				contractPenetration.SVMXC__Covered_By__c = 'Not Covered';
				contractPenetration.SVMXC__Product_Warranty__c = null;
				contractPenetration.SVMXC__Service_Contract__c = null;
				contractPenetration.SVMXC__Configuration_Name__c = getConfigurationName();
				contractPenetration.SVMXC__Calculation_Method__c = getCalculationMethodName();
				
				contractPenetration.SVMXC__Processed_On__c = System.today();
				
				for(integer i = 0 ; i < loopSize ; i++) {
					
					if( coveredByWarranty != null && i < coveredByWarranty.size() ) {
						
						contractPenetration.SVMXC__Product_Warranty__c = coveredByWarranty.get(i).Id;
											
						if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Not Covered') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Warranty';
						} else if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Contract') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Warranty and Contract';
						}
					}
									
					if(coveredSCList != null && i < coveredSCList.size() ) {
						
						contractPenetration.SVMXC__Service_Contract__c = coveredSCList.get(i);
											
						if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Not Covered') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Contract';
						} else if( contractPenetration.SVMXC__Covered_By__c.equalsIgnoreCase('Warranty') ) {
							contractPenetration.SVMXC__Covered_By__c = 'Warranty and Contract';
						}
					}
				}
			}
        }
        if( !contractPenetrationMap.isEmpty() ) {
            
            performFieldMapping( records, contractPenetrationMap.values() );
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( contractPenetrationMap.values(), COMM_SecurityUtils.Access.Createable ) ) {
                upsert contractPenetrationMap.values();
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - exit' );
    }
    
    /**
     * 
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, 'onFinishComplete()' );
    }
}